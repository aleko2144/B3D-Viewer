extends Node3D

var type : int = 14
var scene_root : Node
var LoaderUtils : Node

var need_to_be_imported : bool = false
var is_copy : bool = false

func LoadFromB3D(B3DFile) -> void:
	#B3DFile.seek(B3DFile.get_position() + 44)
	#Vec4 pos, Vec4 event_pos?, int event_type, int var5, int var6
	
	B3DFile.seek(B3DFile.get_position() + 16) #Vector4(xyzw)
	B3DFile.seek(B3DFile.get_position() + 16) #Vector4(event xyzw?)
	
	var _event_type : int = B3DFile.get_32()
	
	var _v1 : int = B3DFile.get_32()
	var v2 : int = B3DFile.get_32()
	
	B3DFile.seek(B3DFile.get_position() + (v2 * 4))
	
func get_copy() -> Node:
	var func_exec_time : int = Time.get_ticks_msec()
	var node : Node3D = Node3D.new()
	node.name = self.name + "_copy"
	node.script = self.script
	node.is_copy = true
	node.scene_root = self.scene_root
	node.visible = self.visible
	scene_root.time_get_copy += (Time.get_ticks_msec() - func_exec_time) / 1000.0
	return node
