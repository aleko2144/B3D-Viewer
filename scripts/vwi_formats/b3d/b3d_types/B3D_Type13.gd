class_name B3D_Type13 extends B3D_Object

var triggerType : int
var numParams   : int

func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 13
	
	buffer.seek(buffer.get_position() + 16) #XYZW
	triggerType = buffer.get_u32()
	buffer.seek(buffer.get_position() + 4) #some param
	numParams = buffer.get_u32()

	buffer.seek(buffer.get_position() + (4 * numParams)) #child obj cnt
