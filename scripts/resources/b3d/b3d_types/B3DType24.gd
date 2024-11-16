extends Node3D

var type : int = 24
var scene_root : Node
var LoaderUtils : Node

var original_matrix_v1 : Vector3
var original_matrix_v2 : Vector3
var original_matrix_v3 : Vector3
var original_position : Vector3

var switcher_state : int #в 24 есть переключатель как в 21

var need_to_be_imported : bool = true
var is_copy : bool = false

func applyOriginalMatrix() -> void:
	#-v1, v2, v3 одно работает, другое не работает
	self.transform.basis.x = original_matrix_v1
	self.transform.basis.y = original_matrix_v2
	self.transform.basis.z = original_matrix_v3
	
	var temp_rot : Vector3 = self.rotation_degrees
	var temp_scl : Vector3 = self.scale
	
	#проверка, является ли данный локатор салонным
	if self.name.contains("RuleSpace") or self.name.contains("SpeedSpace") or self.name.contains("TachoSpace"):
		self.rotation_degrees = Vector3(-temp_rot.x, temp_rot.z, temp_rot.y)
	else:
		self.rotation_degrees = Vector3(temp_rot.x, temp_rot.z, temp_rot.y)
	self.scale = Vector3(temp_scl.x, temp_scl.z, temp_scl.y)
	
func applyOriginalPosition() -> void:
	#self.position = original_position
	#self.position = Vector3(-position[0], position[2], position[1]
	self.transform.origin = original_position

func _process(_delta):
	applyOriginalMatrix()
	applyOriginalPosition()

func LoadFromB3D(B3DFile) -> void:
	original_matrix_v1 = LoaderUtils.getVector3(B3DFile)
	original_matrix_v2 = LoaderUtils.getVector3(B3DFile)
	original_matrix_v3 = LoaderUtils.getVector3(B3DFile)
	original_position  = LoaderUtils.getVector3Pos(B3DFile)
	
	switcher_state = B3DFile.get_32()
	B3DFile.seek(B3DFile.get_position() + 4) #int32 subblocks_num
	
	applyOriginalMatrix()
	applyOriginalPosition()

func get_copy() -> Node:
	var func_exec_time : int = Time.get_ticks_msec()
	var node : Node3D = Node3D.new()
	node.name = self.name + "_copy"
	node.script = self.script
	node.transform = self.transform
	node.is_copy = true
	
	for child in self.get_children():
		var new_child : Node = child.get_copy()
		node.add_child(new_child)
	
	node.scene_root = self.scene_root
	node.visible = self.visible
	scene_root.time_get_copy += (Time.get_ticks_msec() - func_exec_time) / 1000.0
	return node
