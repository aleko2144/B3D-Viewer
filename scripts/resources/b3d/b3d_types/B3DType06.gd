extends Node3D

var type : int = 6
var scene_root : Node
var LoaderUtils : Node

#var object_position : Vector3
#var object_radius : float

var str_parent_object : String
#var str_child_object : String

var obj_parent : Node

var need_to_be_imported : bool = true
var is_copy : bool = false

var vertsCount : int #количество вершин

#добавить доп. массивы под финальный вариант с учётом UV из 35/8?
var vertex_data : PackedVector3Array
var normals_data : PackedVector3Array
var uv_data : PackedVector2Array

var print_debug_info : bool = false

func read_Vertex(B3DFile) -> void:
	vertex_data.append(LoaderUtils.getVector3Pos(B3DFile))
	uv_data.append(LoaderUtils.getVector2(B3DFile))

	normals_data.append(Vector3(1.0, 1.0, 1.0))

func LoadFromB3D(B3DFile) -> void:
	#print('%s->%s' % [self.name, B3DFile.get_position() - 4])
	#object_position = LoaderUtils.getVector3(B3DFile)
	#object_radius = B3DFile.get_float()
	
	B3DFile.seek(B3DFile.get_position() + 16) #Vector4(xyzw)

	str_parent_object = LoaderUtils.getStr32_no_prefix(B3DFile)
	B3DFile.seek(B3DFile.get_position() + 32) #str_child_object
	
	#str_child_object = LoaderUtils.getStr32_no_prefix(B3DFile)
	
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

	
func _process(_delta):
	if (obj_parent):
		self.set_global_transform(obj_parent.get_global_transform())
	
func get_copy() -> Node:
	var func_exec_time : int = Time.get_ticks_msec()
	
	var node : Node3D = Node3D.new()
	node.name = self.name + "_copy"
	node.script = self.script

	node.scene_root = self.scene_root
	node.LoaderUtils = self.LoaderUtils

	node.str_parent_object = self.str_parent_object
	
	if (self.str_parent_object):
		scene_root.dynamic_objects_array.append(node)
		scene_root.dependent_object_array.append(node)
	
	node.is_copy = true
	
	for child in self.get_children():
		var new_child : Node = child.get_copy()
		node.add_child(new_child)
	
	node.visible = self.visible
	scene_root.time_get_copy += (Time.get_ticks_msec() - func_exec_time) / 1000.0
	return node
