class_name B3D_Type29 extends B3D_SwitchContainer #B3D_Object

var LOD_position : Vector3
var LOD_radius : float
var viewer : Node3D

#var groups     : Array
#var groups_num : int
#var switcher_state : int
var groups_render_distances : PackedFloat32Array

#взято из плагинов LabKaVars для Blender
#это настраиваемый LOD
func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 29
	is_switcher = true
	
	buffer.seek(buffer.get_position() + 16) #Vector4(xyzw)
	
	groupsNum = buffer.get_32()
	switchState = buffer.get_32()
	
	LOD_position = VectorUtils.LoadXZYVec3FromBuffer(buffer)
	LOD_radius = buffer.get_float()
	
	for _i in range(groupsNum):
		groups_render_distances.append(buffer.get_float())

	buffer.seek(buffer.get_position() + 4) #int32 subblocks_num
	
	self.resizeGroupsArray()
	#groups.resize(groupsNum)
	#for _i in range(groupsNum):
	#	groups.append([])
		
	#scene_root.switchers_array.append(self)
func _process(_delta: float) -> void:
	self.setSwitch(0)
