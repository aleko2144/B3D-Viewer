class_name B3D_Type02 extends B3D_Object

var pos : Vector4
var dir : Vector4

func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 2
	pos = VectorUtils.LoadXZYVec4FromBuffer(buffer)
	dir = VectorUtils.LoadXZYVec4FromBuffer(buffer)
	buffer.seek(buffer.get_position() + 4) #child obj cnt
