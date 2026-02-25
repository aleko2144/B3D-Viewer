class_name B3D_Type12 extends B3D_Object

var collisionXYZW : Vector4
var collisionDir  : Vector3
var collisionLen  : float
var collisionType : int

func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 12
	
	is_col_plane = true
	
	#buffer.seek(buffer.get_position() + 16) #XYZW
	collisionXYZW = VectorUtils.LoadXZYVec4FromBuffer(buffer)
	collisionDir  = VectorUtils.LoadXZYVec3FromBuffer(buffer)
	collisionLen  = buffer.get_float()
	buffer.seek(buffer.get_position() + 4) #some param
	collisionType = buffer.get_u32()
	buffer.seek(buffer.get_position() + 4) #child cnt

	#var test : Node = MeshInstance3D.new()
	#test.mesh = CylinderMesh.new()
	#self.add_child(test)
	#ConstructCollision()
	#ConstructCollisionMesh()
	
func ConstructCollision() -> void:
	var static_body        : StaticBody3D         = StaticBody3D.new()
	var collision_shape    : CollisionShape3D     = CollisionShape3D.new()
	var collision_geometry : WorldBoundaryShape3D = WorldBoundaryShape3D.new()
	
	collision_geometry.plane.normal =  collisionDir
	collision_geometry.plane.d      = -collisionLen
	
	collision_shape.set_shape(collision_geometry)

	static_body.add_child(collision_shape)
	self.add_child(static_body)
	
#получается безконечная НИЧЕМ не ограниченная коллизия, не то
#в оригинале безконечная коллизия отсекается ограничениями с другими коллизиями
func ConstructInfiniteNonCullCollision() -> void:
	var static_body        : StaticBody3D         = StaticBody3D.new()
	var collision_shape    : CollisionShape3D     = CollisionShape3D.new()
	var collision_geometry : WorldBoundaryShape3D = WorldBoundaryShape3D.new()
	
	collision_geometry.plane.normal =  collisionDir
	collision_geometry.plane.d      = -collisionLen
	
	collision_shape.set_shape(collision_geometry)

	static_body.add_child(collision_shape)
	self.add_child(static_body)
