extends Node3D

var type : int = 29
var scene_root : Node
var LoaderUtils : Node

var LOD_position : Vector3
var LOD_radius : float

var groups_num : int
var switcher_state : int
var groups_render_distances : Array

var need_to_be_imported : bool = true
var is_copy : bool = false

var groups : Array
var current_importing_group : int

var disable_LOD : bool

#взято из плагинов LabKaVars для Blender
#UPD. это настраиваемый LOD
func LoadFromB3D(B3DFile) -> void:
	B3DFile.seek(B3DFile.get_position() + 16) #Vector4(xyzw)
	
	groups_num = B3DFile.get_32()
	switcher_state = B3DFile.get_32()
	
	LOD_position = LoaderUtils.getVector3Pos(B3DFile)
	LOD_radius = B3DFile.get_float()
	
	for _i in range(groups_num):
		groups_render_distances.append(B3DFile.get_float())
	
	#print(num_vectors)
	#print(num_skip)

	#B3DFile.seek(B3DFile.get_position() + (num_skip * 4)) #int
	B3DFile.seek(B3DFile.get_position() + 4) #int32 subblocks_num
	
	for _i in range(groups_num):
		groups.append([])
		
	scene_root.switchers_array.append(self)
	
func addToGroup() -> void:
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

	switcher_state = switch_target
	
func setSwitch_safe(switch_target : int) -> void:
	if switch_target > -1 and switch_target < 2:
		setSwitch(switch_target)

func prepare() -> void:
	#for child in self.get_children():
	#	child.visible = false
	setSwitch(groups_num - 1)
	#setSwitch(switcher_state)
	disable_LOD = !scene_root.DisableLOD
	
func get_copy() -> Node:
	var func_exec_time : int = Time.get_ticks_msec()
	var node : Node3D = Node3D.new()
	node.name = self.name + "_copy"
	node.script = self.script
	node.is_copy = true
	
	node.LOD_position = self.LOD_position
	node.LOD_radius = self.LOD_radius

	node.groups_num = self.groups_num
	node.switcher_state = self.switcher_state
	
	node.groups = self.groups
	node.disable_LOD = self.disable_LOD
	
	scene_root.switchers_array.append(node)
	node.is_copy = true
	
	for child in self.get_children():
		var new_child : Node = child.get_copy()
		node.add_child(new_child)
	
	node.scene_root = self.scene_root
	node.visible = self.visible
	scene_root.time_get_copy += (Time.get_ticks_msec() - func_exec_time) / 1000.0
	return node
