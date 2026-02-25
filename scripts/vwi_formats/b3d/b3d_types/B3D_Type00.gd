class_name B3D_Type00 extends B3D_Object

func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 0
	buffer.seek(buffer.get_position() + 44)
