class_name B3D_Type24 extends B3D_Object

func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 24
	
	var m0_0 : Vector3 = VectorUtils.LoadVec3FromBuffer(buffer)
	var m1_0 : Vector3 = VectorUtils.LoadVec3FromBuffer(buffer)
	var m2_0 : Vector3 = VectorUtils.LoadVec3FromBuffer(buffer)

	var mtx : Transform3D = Transform3D(Vector3(m0_0.x, m0_0.y, m0_0.z),
					  Vector3(m1_0.x, m1_0.y, m1_0.z),
					  Vector3(m2_0.x, m2_0.y, m2_0.z),
					  Vector3(0, 0, 0))

	var pos : Vector3 = VectorUtils.LoadXZYVec3FromBuffer(buffer)
	
	self.set_transform(mtx)
	
	var old_rot : Vector3 = self.rotation_degrees
	self.rotation_degrees.x =   old_rot.x
	self.rotation_degrees.y =  -old_rot.z
	self.rotation_degrees.z =  -old_rot.y
	
	self.set_position(pos)
	
	buffer.seek(buffer.get_position() + 4) #display child idx ?
	buffer.seek(buffer.get_position() + 4) #child cnt
