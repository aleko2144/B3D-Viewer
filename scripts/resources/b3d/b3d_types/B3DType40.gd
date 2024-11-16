extends Node3D

var type : int = 40
var scene_root : Node
var LoaderUtils : Node

var need_to_be_imported : bool = true
var is_copy : bool = false

func LoadFromB3D(B3DFile) -> void:
	B3DFile.seek(B3DFile.get_position() + 88)
	var bytes_skip : int = B3DFile.get_32()
	#print(test)
	#print(test * 4)
	#breakpoint
	
	B3DFile.seek(B3DFile.get_position() + (bytes_skip * 4))

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