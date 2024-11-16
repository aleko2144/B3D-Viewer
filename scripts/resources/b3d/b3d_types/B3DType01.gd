extends Node3D

var type : int = 1
var scene_root : Node
var LoaderUtils : Node

var str_space_object : String
var str_room_object : String

var obj_space : Node
var obj_room : Node

var need_to_be_imported : bool = true
var is_copy : bool = false

func LoadFromB3D(B3DFile) -> void:
	str_space_object = LoaderUtils.getStr32_no_prefix(B3DFile)
	str_room_object = LoaderUtils.getStr32_no_prefix(B3DFile)
	
	scene_root.observer_node = self
	#scene_root.dynamic_objects_array.append(self)
	scene_root.dependent_object_array.append(self)

func set_external_node(obj : Node) -> void:
	if obj.name == str_space_object:
		obj_space = obj
	else:
		obj_room = obj

func make_search_query() -> void:
	if (str_space_object):
		scene_root.addQueryForSearch(self, str_space_object)

	if (str_room_object):
		#проверка на случай параметра вида "db:room_db_012"
		if (str_room_object.contains(":")):
			return
		scene_root.addQueryForSearch(self, str_room_object)
	
func getObserverTransform():
	if obj_space:
		return obj_space.get_global_transform()
	else:
		return null
	
func get_copy() -> Node:

	var func_exec_time : int = Time.get_ticks_msec()

	var node : Node3D = Node3D.new()
	node.name = self.name + "_copy"
	node.script = self.script
	
	node.scene_root = self.scene_root
	node.LoaderUtils = self.LoaderUtils
	
	node.str_space_object = self.str_space_object
	node.str_room_object = self.str_room_object

	#scene_root.dynamic_objects_array.append(node)
	scene_root.dependent_object_array.append(node)

	node.is_copy = true
	node.visible = self.visible
	scene_root.time_get_copy += (Time.get_ticks_msec() - func_exec_time) / 1000.0
	return node
