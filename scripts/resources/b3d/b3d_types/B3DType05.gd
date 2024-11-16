extends Node3D

var type : int = 5
var scene_root : Node
var LoaderUtils : Node

#var object_position : Vector3
#var str_child_object : String

var need_to_be_imported : bool = true
var is_copy : bool = false

func LoadFromB3D(B3DFile) -> void:
	B3DFile.seek(B3DFile.get_position() + 52) #all data
	
	#object_position = LoaderUtils.getVector3(B3DFile)
	#B3DFile.seek(B3DFile.get_position() + 4) #Vector4(xyzw) #4
	#B3DFile.seek(B3DFile.get_position() + 32) #str32
	#str_child_object = LoaderUtils.getStr32_no_prefix(B3DFile)
	#B3DFile.seek(B3DFile.get_position() + 4) #int32 subblocks_num

func get_copy() -> Node:
	var func_exec_time : int = Time.get_ticks_msec()
	var node : Node3D = Node3D.new()
	node.name = self.name + "_copy"
	node.script = self.script
	node.is_copy = true
	
	for child in self.get_children():
		var new_child : Node = child.get_copy()
		node.add_child(new_child)

	node.scene_root = self.scene_root
	node.visible = self.visible
	scene_root.time_get_copy += (Time.get_ticks_msec() - func_exec_time) / 1000.0
	return node
