class_name B3D_Type25 extends B3D_Object

var pos : Vector4
var linkedObjName  : String

func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 25
	buffer.seek(buffer.get_position() + 88)
