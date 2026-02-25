class_name B3D_Type17 extends B3D_Object

func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 17
	
	buffer.seek(buffer.get_position() + 60) 
