class_name B3D_Type10 extends B3D_SwitchContainer

var pos  : Vector3
var radius : float
var viewer : Node3D

func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 10
	is_switcher = true
	
	buffer.seek(buffer.get_position() + 16) #XYZW
	pos = VectorUtils.LoadXZYVec3FromBuffer(buffer)
	radius = buffer.get_float()
	buffer.seek(buffer.get_position() + 4) #child obj cnt

	groupsNum = 2
	switchState = 0
	
	self.resizeGroupsArray()
	
func _process(_delta: float) -> void:
	if pos.distance_to(viewer.position) > radius:
		self.visible = false
	else:
		self.visible = true
