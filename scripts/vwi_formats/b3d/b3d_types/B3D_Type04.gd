class_name B3D_Type04 extends B3D_Object

var pos : Vector4
var parentObjName  : String
var linkedObjName  : String

func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 4
	pos = VectorUtils.LoadXZYVec4FromBuffer(buffer)
	parentObjName = LoaderUtils.readString32(buffer, false)
	linkedObjName = LoaderUtils.readString32(buffer, false)
	buffer.seek(buffer.get_position() + 4) #child obj cnt
