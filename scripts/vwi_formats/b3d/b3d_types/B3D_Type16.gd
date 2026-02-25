class_name B3D_Type16 extends B3D_Object

func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 16
	
	buffer.seek(buffer.get_position() + 60) 
