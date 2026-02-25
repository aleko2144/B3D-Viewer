class_name VectorUtils

static func LoadDVec4FromBuffer(file : StreamPeerBuffer) -> Vector4:
	var x : float = file.get_double()
	var y : float = file.get_double()
	var z : float = file.get_double()
	var w : float = file.get_double()
	return Vector4(x, y, z, w)
	
static func LoadXZYDVec4FromBuffer(file : StreamPeerBuffer) -> Vector4:
	var x : float = file.get_double()
	var y : float = file.get_double()
	var z : float = file.get_double()
	var w : float = file.get_double()
	return Vector4(-x, z, y, w) #Godot xzy, VWI xyz

static func LoadDVec3FromBuffer(file : StreamPeerBuffer) -> Vector3:
	var x : float = file.get_double()
	var y : float = file.get_double()
	var z : float = file.get_double()
	return Vector3(x, y, z)
	
static func LoadXZYDVec3FromBuffer(file : StreamPeerBuffer) -> Vector3:
	var x : float = file.get_double()
	var y : float = file.get_double()
	var z : float = file.get_double()
	return Vector3(-x, z, y) #Godot xzy, VWI xyz

static func LoadVec2FromBuffer(file : StreamPeerBuffer) -> Vector2:
	var x : float = file.get_float()
	var y : float = file.get_float()
	return Vector2(x, y)

static func LoadVec3FromBuffer(file : StreamPeerBuffer) -> Vector3:
	var x : float = file.get_float()
	var y : float = file.get_float()
	var z : float = file.get_float()
	return Vector3(x, y, z)
	
static func LoadXZYVec3FromBuffer(file : StreamPeerBuffer) -> Vector3:
	var x : float = file.get_float()
	var y : float = file.get_float()
	var z : float = file.get_float()
	return Vector3(-x, z, y) 
	
static func LoadVec4FromBuffer(file : StreamPeerBuffer) -> Vector4:
	var x : float = file.get_float()
	var y : float = file.get_float()
	var z : float = file.get_float()
	var w : float = file.get_float()
	return Vector4(x, y, z, w)
	
static func LoadXZYVec4FromBuffer(file : StreamPeerBuffer) -> Vector4:
	var x : float = file.get_float()
	var y : float = file.get_float()
	var z : float = file.get_float()
	var w : float = file.get_float()
	return Vector4(-x, z, y, w)

#https://docs.godotengine.org/en/latest/tutorials/math/vector_math.html#cross-product
static func get_triangle_normal(a : Vector3, b : Vector3, c : Vector3) -> Vector3:
	# Find the surface normal given 3 vertices.
	var side1 : Vector3 = b - a
	var side2 : Vector3 = c - a
	var normal = side1.cross(side2)
	return normal
