class_name B3D_Type14 extends B3D_Object

var triggerType : int
var numParams   : int

func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 14
	
	buffer.seek(buffer.get_position() + 16) #Vector4(xyzw)
	buffer.seek(buffer.get_position() + 16) #Vector4(event xyzw?)
	
	var _event_type : int = buffer.get_32()
	
	var _v1 : int = buffer.get_32()
	var v2 : int = buffer.get_32()
	
	buffer.seek(buffer.get_position() + (v2 * 4))
