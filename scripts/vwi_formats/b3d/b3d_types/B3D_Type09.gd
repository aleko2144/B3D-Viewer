class_name B3D_Type09 extends B3D_Object

var pos : Vector4
var triggerVector : Vector4

func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 9
	pos = VectorUtils.LoadXZYVec4FromBuffer(buffer)
	triggerVector = VectorUtils.LoadVec4FromBuffer(buffer)
	buffer.seek(buffer.get_position() + 4) #child obj cnt
