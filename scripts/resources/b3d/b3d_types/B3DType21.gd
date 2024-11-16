extends Node3D

var type : int = 21
var scene_root : Node
var LoaderUtils : Node

var object_position : Vector3
var object_radius : float

var groups_num : int
var switcher_state : int
var default_state : int

var groups : Array
var current_importing_group : int

var need_to_be_imported : bool = true
var is_copy : bool = false

var original_name : String

func LoadFromB3D(B3DFile) -> void:
	object_position = LoaderUtils.getVector3(B3DFile)
	object_radius = B3DFile.get_float()

	groups_num = B3DFile.get_32()
	switcher_state = B3DFile.get_32()
	
	B3DFile.seek(B3DFile.get_position() + 4) #int32 subblocks_num
	
	for _i in range(groups_num):
		groups.append([])
		
	scene_root.switchers_array.append(self)
	#scene_root.dynamic_objects_array.append(self)
		
func addToGroup() -> void:
	#groups[current_importing_group].append(node)
	groups[current_importing_group].append(self.get_child_count() - 1)

func finishGroup() -> void:
	current_importing_group += 1
	
func setSwitch(switch_target : int) -> void:
	var i : int = 0
	for group in groups:
		for index in group:
			if i == switch_target:
				self.get_child(index).visible = true
			else:
				self.get_child(index).visible = false
		i += 1
		
	#for i in range(self.get_child_count()):
	#	if i in groups[switch_target]:
	#		self.get_child(i).visible = true
	#	else:
	#		self.get_child(i).visible = false
		
		
	#for i in range(len(groups)):
	#	for index in groups[i]:
	#		if switch_target == index:
	#			get_child(index).visible = true
	#		else:
	#			get_child(index).visible = false
		
		#print(groups[i])
		#for object in groups[i]:
		#	if switch_target == i:
		#		object.visible = true
		#	else:
		#		object.visible = false

	switcher_state = switch_target
	
func setSwitch_safe(switch_target : int) -> void:
	if switch_target > -1 and switch_target < groups_num:
		setSwitch(switch_target)

func prepare() -> void:
	if (self.name == "MineKey" or self.name == "PinKey" or self.name == "BenzoKey"):
		setSwitch(0)
	else:
		setSwitch(switcher_state)
		
	default_state = switcher_state
		
	scene_root.get_parent().addSwitcherToList(self)
	
#func _physics_process(_delta):
#	if (Input.is_action_just_pressed("ui_up")):
#		setSwitch_safe(switcher_state + 1)
#		#print(switcher_state)
#	if (Input.is_action_just_pressed("ui_down")):
#		setSwitch_safe(switcher_state - 1)
#		#print(switcher_state)

func get_copy() -> Node:
	var func_exec_time : int = Time.get_ticks_msec()

	var node : Node3D = Node3D.new()
	node.name = self.name + "_copy"
	node.script = self.script

	node.scene_root = self.scene_root
	node.LoaderUtils = self.LoaderUtils

	node.object_position = self.object_position
	node.object_radius = self.object_radius

	node.groups_num = self.groups_num
	node.switcher_state = self.switcher_state
	
	node.groups = self.groups
	
	scene_root.switchers_array.append(node)
	node.is_copy = true
	
	for child in self.get_children():
		var new_child : Node = child.get_copy()
		node.add_child(new_child)
	
	node.visible = self.visible
	
	node.original_name = self.original_name
	
	scene_root.get_parent().addSwitcherToList(node)
	
	scene_root.time_get_copy += (Time.get_ticks_msec() - func_exec_time) / 1000.0
	return node
