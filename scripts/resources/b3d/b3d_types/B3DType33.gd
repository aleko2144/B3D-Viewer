extends Node3D

var type : int = 33
var scene_root : Node
var LoaderUtils : Node

var light_object : OmniLight3D = OmniLight3D.new()

var object_position : Vector3
var lamp_enabled : bool
var lamp_radius : float
var lamp_intensity : float
var lamp_color : Color

var need_to_be_imported : bool = true
var is_copy : bool = false

func LoadFromB3D(B3DFile) -> void:
	B3DFile.seek(B3DFile.get_position() + 16) #Vector4(xyzw)
	lamp_enabled = B3DFile.get_32()
	B3DFile.seek(B3DFile.get_position() + 8)  #var2, type
	
	object_position = LoaderUtils.getVector3Pos(B3DFile)
	B3DFile.seek(B3DFile.get_position() + 20) #var4 - 8, all_lights_state

	lamp_radius = B3DFile.get_float()
	lamp_intensity = B3DFile.get_float()
	
	B3DFile.seek(B3DFile.get_position() + 8)  #var11, var12
	
	lamp_color = LoaderUtils.getRGB(B3DFile)
	
	B3DFile.seek(B3DFile.get_position() + 4) #int32 subblocks_num
	
	#self.position = Vector3(-object_position.x, object_position.z, object_position.y)
	
	light_object.position = object_position
	light_object.script = load('res://scripts/resources/b3d/b3d_types/B3DType33_Object.gd')
	
	#light_energy = 0 #отладка
	#shadow_enabled = true
	
	light_object.light_color = lamp_color
	if (lamp_radius):
		light_object.omni_range = 0.25 / lamp_radius #0.1 в Godot 3.6
	if (light_object.omni_range > 100):
		light_object.omni_range = 100
	
	#print(self.name.left(4))
	if (self.name.left(4) == "lamp"):
		light_object.visible = false
		
	self.add_child(light_object)

func get_copy() -> Node:
	var func_exec_time : int = Time.get_ticks_msec()

	var node : Node3D = Node3D.new()
	node.name = self.name + "_copy"
	node.script = self.script
	
	node.light_object = self.light_object.duplicate()
	node.light_object.name = self.light_object.name + "_copy"
	node.light_object.script = self.light_object.script

	node.light_object.position = self.object_position

	if (self.name.left(4) == "lamp"):
		node.light_object.visible = false
		
	node.add_child(node.light_object)
	
	node.is_copy = true
	
	for child in self.get_children():
		if child != light_object:
			var new_child : Node = child.get_copy()
			node.add_child(new_child)
	
	node.scene_root = self.scene_root
	node.visible = self.visible
	scene_root.time_get_copy += (Time.get_ticks_msec() - func_exec_time) / 1000.0
	return node
