class_name B3D_Type03 extends B3D_Object

var pos : Vector4

func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 3
	pos = VectorUtils.LoadXZYVec4FromBuffer(buffer)
	buffer.seek(buffer.get_position() + 4) #child obj cnt
