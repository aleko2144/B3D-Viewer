extends Node3D

var type : int = 18
var scene_root : Node
var LoaderUtils : Node

var str_space_object : String
var str_linked_object : String

var obj_space : Node
var obj_linked : Node

var need_to_be_imported : bool = true
var is_copy : bool = false

var is_prepared : bool = false
var apply_space : bool = false

func LoadFromB3D(B3DFile) -> void:
	B3DFile.seek(B3DFile.get_position() + 16) #Vector4(xyzw)
	str_space_object = LoaderUtils.getStr32_no_prefix(B3DFile)
	str_linked_object = LoaderUtils.getStr32_no_prefix(B3DFile)
	
	if (str_space_object == '$$world'):
		str_space_object = ''
	
	scene_root.linkers_array.append(self)

func set_external_node(obj : Node) -> void:
	if obj.name == str_space_object:
		obj_space = obj
	else:
		obj_linked = obj

func make_search_query() -> void:
	if (str_space_object):
		scene_root.addQueryForSearch(self, str_space_object)
	if (str_linked_object):
		scene_root.addQueryForSearch(self, str_linked_object)

func prepare() -> void:
	if (obj_space):
		#self.set_global_transform(obj_space.get_global_transform())
		self.set_transform(obj_space.get_transform())
		apply_space = true
	
	if (obj_linked):
		self.add_child(obj_linked.get_copy())
		self.get_child(0).visible = true
	
	is_prepared = true
	
	#if (obj_space):
	#	self.set_transform(obj_space.get_transform())

func _process(_delta):
	if (apply_space):
		self.transform = obj_space.transform
	
#	if (obj_space):
#		self.transform = obj_space.transform
#		#print("%s -> %s" % [self.global_transform, obj_space.global_transform])
#		#self.set_global_transform(obj_space.get_global_transform())

func get_copy() -> Node:
	var func_exec_time : int = Time.get_ticks_msec()

	var node : Node3D = Node3D.new()
	node.name = self.name + "_copy"
	node.script = self.script

	node.scene_root = self.scene_root
	node.LoaderUtils = self.LoaderUtils

	
	node.str_space_object = self.str_space_object
	node.str_linked_object = self.str_linked_object

	node.obj_space = self.obj_space
	node.obj_linked = self.obj_linked

	#node.set_global_transform(self.get_global_transform())
	node.is_copy = true
	
	if !is_prepared:
		prepare()
		
	node.is_prepared = is_prepared
	node.apply_space = apply_space
	
	#var is_have_child : bool = false
	for child in self.get_children():
		var new_child : Node = child.get_copy()
		node.add_child(new_child)
		#is_have_child = true
		
	#переделать
	#if !is_have_child and len(str_linked_object): #!self.get_child_count():
	#	#print(self.name)
	#	scene_root.linkers_array2.append(node)
	#слетели позиции объектов, странно
	
	node.visible = self.visible
	scene_root.time_get_copy += (Time.get_ticks_msec() - func_exec_time) / 1000.0
	return node
