extends Node3D

var type : int = 34
var scene_root : Node
var LoaderUtils : Node

var need_to_be_imported : bool = true
var is_copy : bool = false #?

func LoadFromB3D(B3DFile) -> void:
	B3DFile.seek(B3DFile.get_position() + 16) #Vector4(xyzw)
	B3DFile.seek(B3DFile.get_position() + 4)  #int v1
	
	var num_data : int = B3DFile.get_32()

	B3DFile.seek(B3DFile.get_position() + (num_data * 16)) #Vector3(xyz), int v4
	
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