class_name B3D_Type07 extends B3D_Object

var pos : Vector4
var linkedObjName  : String

var numVerts : int
#var vertices : Array
var vertices : PackedVector3Array
var normals  : PackedVector3Array
var UV       : PackedVector2Array

func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 7
	pos = VectorUtils.LoadXZYVec4FromBuffer(buffer)
	linkedObjName = LoaderUtils.readString32(buffer, false)
	
	numVerts = buffer.get_u32()
	for _i in range(numVerts):
		#var vertex : VWIVertex = VWIVertex.new()
		#vertex.position = VectorUtils.LoadXZYVec3FromBuffer(buffer)
		#vertex.UV       = VectorUtils.LoadVec2FromBuffer(buffer)
		#vertices.append(vertex)
		vertices.append(VectorUtils.LoadXZYVec3FromBuffer(buffer))
		#normals.append(vertices[-1])
		normals.append(Vector3(0, 0, 0))
		UV.append(VectorUtils.LoadVec2FromBuffer(buffer))
	
	buffer.seek(buffer.get_position() + 4) #child obj cnt
