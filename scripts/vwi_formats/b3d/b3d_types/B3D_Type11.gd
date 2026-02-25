class_name B3D_Type11 extends B3D_Object

var pos : Vector4
var vec1 : Vector4
var vec2 : Vector4

#RACES_D1.B3D, pos = 0x28ACC
func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 11
	
	pos = VectorUtils.LoadXZYVec4FromBuffer(buffer)
	vec1 = VectorUtils.LoadXZYVec4FromBuffer(buffer)
	vec2 = VectorUtils.LoadXZYVec4FromBuffer(buffer)

	buffer.seek(buffer.get_position() + 4) #child obj cnt
