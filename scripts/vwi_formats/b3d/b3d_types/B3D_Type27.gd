class_name B3D_Type27 extends B3D_Object

#RACES_D1.B3D, pos = 0x5B28
func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 27

	buffer.seek(buffer.get_position() + 16) #XYZW
	buffer.seek(buffer.get_position() + 4) #some int 1
	buffer.seek(buffer.get_position() + 12) #some vector3
	buffer.seek(buffer.get_position() + 4) #some int 2
