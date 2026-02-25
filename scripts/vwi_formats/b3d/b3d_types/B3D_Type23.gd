class_name B3D_Type23 extends B3D_Object

var collision_type : int
var vertices       : PackedVector3Array
var indices        : PackedInt32Array

var collision_verts      : PackedVector3Array

func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 23
	is_col_poly = true
	#print('%s->%s' % [self.name, buffer.get_position() - 4])
	buffer.seek(buffer.get_position() + 4)
	collision_type = buffer.get_u32()
	var bytes_skip : int = buffer.get_u32()
	buffer.seek(buffer.get_position() + (bytes_skip * 4))
	
	var facesCount : int = buffer.get_u32()
	var vertIdx    : int = 0
	
	
	for i in range(facesCount):
		var vertsCount : int = buffer.get_u32()
		var vertexBase : int = vertIdx
		var vertsLocal : Array
		
		for j in range(vertsCount):
			vertices.append(VectorUtils.LoadXZYVec3FromBuffer(buffer))
		
		match vertsCount:
			3:
				indices.append_array([vertIdx + 2, vertIdx + 1, vertIdx])
			4:
				indices.append_array([vertIdx + 2, vertIdx + 1, vertIdx, vertIdx + 3, vertIdx + 2, vertIdx])
			5:
				indices.append_array([vertIdx + 2, vertIdx + 1, vertIdx, vertIdx + 3, vertIdx + 2, vertIdx, vertIdx + 4, vertIdx + 3, vertIdx])
			_:
				breakpoint
			
		vertIdx += vertsCount
	
	for j in range(len(indices)):
		collision_verts.append(vertices[indices[j]])
	
	#ConstructCollision()
	#ConstructCollisionMesh()
	
func ConstructCollision() -> void:
	var static_body : StaticBody3D = StaticBody3D.new()
	var collision_shape     : CollisionShape3D = CollisionShape3D.new()
	var collision_geometry  : ConcavePolygonShape3D = ConcavePolygonShape3D.new()
	
	collision_geometry.set_faces(collision_verts)
	collision_shape.set_shape(collision_geometry)
	#collision_shape.disabled = true
	#collision_container.set_shape(collision_geometry)
	static_body.add_child(collision_shape)
	self.add_child(static_body)
	
func ConstructCollisionMesh() -> void:
	var mesh_node  : Node = MeshInstance3D.new()
	self.add_child(mesh_node)
	
	mesh_node.mesh = ArrayMesh.new()
	
	var normals : PackedVector3Array
	normals.resize(len(vertices))
	
	for k in range(len(indices) - 3):
		var vec_1 : Vector3 = vertices[indices[k+2]]
		var vec_2 : Vector3 = vertices[indices[k+1]]
		var vec_3 : Vector3 = vertices[indices[k]]
				
		var normal_vec2 : Vector3 = VectorUtils.get_triangle_normal(vec_1, vec_2, vec_3)
				
		normals[indices[k+2]] = normal_vec2
		normals[indices[k+1]] = normal_vec2
		normals[indices[k]] = normal_vec2
		
		k += 3
	
	var surface_data : Array
	surface_data.resize(Mesh.ARRAY_MAX)
	surface_data[Mesh.ARRAY_VERTEX] = vertices
	surface_data[Mesh.ARRAY_NORMAL] = normals
	
	#indices.reverse()
	surface_data[Mesh.ARRAY_INDEX]  = indices
			
	#print(verts_node.name)
	#breakpoint
	mesh_node.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_data)
	
