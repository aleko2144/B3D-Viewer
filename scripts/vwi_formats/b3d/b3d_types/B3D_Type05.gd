class_name B3D_Type05 extends B3D_Object

var pos : Vector4
var linkedObjName  : String

func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 5
	pos = VectorUtils.LoadXZYVec4FromBuffer(buffer)
	linkedObjName = LoaderUtils.readString32(buffer, false)
	buffer.seek(buffer.get_position() + 4) #child obj cnt
