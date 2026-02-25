class_name B3D_Type18 extends B3D_Object

var spaceObjectName  : String
var linkedObjectName : String

func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 18
	buffer.seek(buffer.get_position() + 16) #XYZW
	spaceObjectName  = LoaderUtils.readString32(buffer, false)
	linkedObjectName = LoaderUtils.readString32(buffer, false)
