extends Node3D

var type : int = 36
var scene_root : Node
var LoaderUtils : Node

var object_position : Vector3
var object_radius : float

var str_parent_object : String
var str_child_object : String

var need_to_be_imported : bool = true
var is_copy : bool = false

var obj_parent : Node

#флаги
var normals_type : int
var num_UV : int

var vertsCount : int #количество вершин

#добавить доп. массивы под финальный вариант с учётом UV из 35/8?
var vertex_data : PackedVector3Array
var normals_data : PackedVector3Array
var uv_data : PackedVector2Array
var uv2_data : PackedVector2Array

var print_debug_info : bool = false

func read_VertexFlags(B3DFile) -> void:
	normals_type  = B3DFile.get_8() #нормали
	num_UV        = B3DFile.get_8() #количество UV
	B3DFile.seek(B3DFile.get_position() + 2) #два пустых байта
	
	if (print_debug_info): #debug
		var normals_str : String = "" 
		var uv_str : String = ""
		
		if normals_type == 1 or normals_type == 2:
			normals_str = "NX NY NZ"
		elif normals_type == 3:
			normals_str = "NX"

		for i in range(num_UV):
			uv_str += "UV%d " % [i+2]
		
		print("XYZ UV %s %s" % [normals_str, uv_str])
	
func read_Vertex(B3DFile) -> void:
	vertex_data.append(LoaderUtils.getVector3Pos(B3DFile))
	uv_data.append(LoaderUtils.getVector2(B3DFile))
	#изначально были нормали, затем UV
	#но судя по объектам "Floor" из TB.B3D, сначала доп. UV, а потом нормали
	
	for j in range(num_UV):
		if j == 0:
			uv2_data.append(LoaderUtils.getVector2(B3DFile))
		else: #если больше, чем UV2, то пропуск слоя
			B3DFile.seek(B3DFile.get_position() + 8)
	
	if normals_type == 1 or normals_type == 2:
		normals_data.append(LoaderUtils.getVector3Pos(B3DFile))
	elif normals_type == 3:
		normals_data.append(Vector3(1.0, 1.0, 1.0))
		B3DFile.seek(B3DFile.get_position() + 4) #один float

func LoadFromB3D(B3DFile) -> void:
	#print('%s->%s' % [self.name, B3DFile.get_position() - 4])
	object_position = LoaderUtils.getVector3(B3DFile)
	object_radius = B3DFile.get_float()

	str_parent_object = LoaderUtils.getStr32_no_prefix(B3DFile)
	str_child_object = LoaderUtils.getStr32_no_prefix(B3DFile)
	
	read_VertexFlags(B3DFile)
	vertsCount = B3DFile.get_32()
	
	for _i in range(vertsCount):
		read_Vertex(B3DFile)

	B3DFile.seek(B3DFile.get_position() + 4) #int32 subblocks_num
	
	if (str_parent_object):
		scene_root.dynamic_objects_array.append(self)
		scene_root.dependent_object_array.append(self)
		
func set_external_node(obj : Node) -> void:
	obj_parent = obj

func make_search_query() -> void:
	scene_root.addQueryForSearch(self, str_parent_object)
	
	
func prepare() -> void:
	#obj_parent = scene_root.getSceneObject(null, str_parent_object)
		
	if obj_parent:
		self.set_transform(obj_parent.get_transform())

#func _process(_delta):
#	if (obj_parent):
#		self.set_global_transform(obj_parent.get_global_transform())
	
func get_copy() -> Node:
	var func_exec_time : int = Time.get_ticks_msec()

	var node : Node3D = Node3D.new()
	node.name = self.name + "_copy"
	node.script = self.script
	node.type = self.type
	node.scene_root = self.scene_root

	node.str_parent_object = self.str_parent_object

	node.vertsCount = self.vertsCount
	

	if (self.str_parent_object):
		scene_root.dynamic_objects_array.append(node)
		scene_root.dependent_object_array.append(node)
	
	node.is_copy = true
	
	for child in self.get_children():
		var new_child : Node = child.get_copy()
		node.add_child(new_child)
	
	node.scene_root = self.scene_root
	node.visible = self.visible
	scene_root.time_get_copy += (Time.get_ticks_msec() - func_exec_time) / 1000.0
	return node
