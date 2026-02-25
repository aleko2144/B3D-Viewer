class_name B3D_Type20 extends B3D_Object

var pos : Vector4
var parentObjName  : String
var linkedObjName  : String

var vectors : PackedVector3Array
#var height  : float

var vertices : PackedVector3Array
var indices  : PackedInt32Array

func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 20
	
	buffer.seek(buffer.get_position() + 16) #Vector4(xyzw)
	var vertsCount : int = buffer.get_32()
	buffer.seek(buffer.get_position() + 8) #var3, var4
	
	#height = buffer.get_float()
	var addItemsCnt : int = buffer.get_u32()
	
	for i in range(addItemsCnt): #float varX[var5]
		buffer.seek(buffer.get_position() + 4)
		#if i == 0:
		#	height = buffer.get_float()
		#else:
		#	buffer.seek(buffer.get_position() + 4)
	
	for _i in range(vertsCount):
		vectors.append(VectorUtils.LoadXZYVec3FromBuffer(buffer))
		#buffer.seek(buffer.get_position() + 12)
	
	#breakpoint
	if not ('way' in self.name):
		is_col_curve = true
		ConstructCollision()

	
func ConstructCollision() -> void:
	var static_body : StaticBody3D = StaticBody3D.new()
	var collision_shape     : CollisionShape3D = CollisionShape3D.new()
	var collision_geometry  : ConcavePolygonShape3D = ConcavePolygonShape3D.new()
	
	var collision_verts : PackedVector3Array
	
	for i in range(len(vectors)):
		vertices.append(vectors[i])
		vectors[i].y += 30
		vertices.append(vectors[i])
	
	var idx : int = 0
	for j in range(len(vertices) / 2 - 1):
		indices.append_array([idx+1, idx, idx+2, idx+2, idx+3, idx+1])
		idx += 2
	
	for j in range(len(indices)):
		collision_verts.append(vertices[indices[j]])
	
	collision_geometry.set_faces(collision_verts)
	collision_shape.set_shape(collision_geometry)
	collision_shape.disabled = true
	
	static_body.add_child(collision_shape)
	
	self.add_child(static_body)

func ConstructCollisionMesh() -> void:
	#точки задают вернхюю границу коллизии
	var mesh_node  : Node = MeshInstance3D.new()
	self.add_child(mesh_node)
	
	mesh_node.mesh = ArrayMesh.new()
	
	#var vertices : PackedVector3Array
	var normals  : PackedVector3Array
	#var indices  : PackedInt32Array
	
	for i in range(len(vectors)):
		vertices.append(vectors[i])
		#if (height):
		#	vectors[i].y += height
		#else:
		#	vectors[i].y -= 30
		vectors[i].y += 30
		vertices.append(vectors[i])
	
	var idx : int = 0
	for j in range(len(vertices) / 2 - 1):
		indices.append_array([idx+1, idx, idx+2, idx+2, idx+3, idx+1])
		idx += 2
	
	var surface_data : Array
	surface_data.resize(Mesh.ARRAY_MAX)
	surface_data[Mesh.ARRAY_VERTEX] = vertices
	#surface_data[Mesh.ARRAY_NORMAL] = normals
	surface_data[Mesh.ARRAY_INDEX]  = indices
	#mesh_node.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_data)
	mesh_node.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_POINTS, surface_data)
	
