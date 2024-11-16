extends Node3D

var type : int = 30
var scene_root : Node
var LoaderUtils : Node

var object_position : Vector3
var object_radius : float

var str_target_room : String
var portal_point1 : Vector3
var portal_point2 : Vector3

var portal_center : Vector3
var portal_radius : float
var internal_room : bool #комната текущего модуля или другого

var portal_normal : Vector3

var visibility_checker : VisibleOnScreenNotifier3D = VisibleOnScreenNotifier3D.new()

var need_to_be_imported : bool = true
var is_copy : bool = false

var Viewer : Node
var ScenesNode : Node

var test_mesh : MeshInstance3D = MeshInstance3D.new()

var distance_to_viewer : float
var viewer_pos : Vector2 #= LoaderUtils.vec3to2D(Viewer.position)
var portal_pos : Vector2 #= LoaderUtils.vec3to2D(portal_center)
var portal_nrm : Vector2 #= LoaderUtils.vec3to2D(portal_normal)
var vec_test : Vector2

func GetDoorNormal() -> void:
	#получение нормали
	var stool : SurfaceTool = SurfaceTool.new()
		
	stool.begin(Mesh.PRIMITIVE_TRIANGLES)

	stool.add_vertex(portal_point1)
	stool.add_vertex(Vector3(portal_point1.x, portal_point2.y, portal_point1.z))
	stool.add_vertex(portal_point2)
	stool.generate_normals()

	var data : Array = stool.commit_to_arrays()
	portal_normal = data[1][0]

func LoadFromB3D(B3DFile) -> void:
	object_position = LoaderUtils.getVector3Pos(B3DFile)
	object_radius = B3DFile.get_float()
	
	str_target_room = LoaderUtils.getStr32_no_prefix(B3DFile)
	portal_point1 = LoaderUtils.getVector3Pos(B3DFile) #LoaderUtils.getVector3(B3DFile)
	portal_point2 = LoaderUtils.getVector3Pos(B3DFile) #LoaderUtils.getVector3(B3DFile)
	
	scene_root.rooms_array[-1].room_doors.append(self)
	
	portal_center = (portal_point1 + portal_point2) / 2.0
	portal_center.y = portal_point1.y
	portal_radius = abs(portal_point1.distance_to(portal_point2)) / 2.0 #* 0.9

	#test_point1 = LoaderUtils.vec3to2D(portal_point1)
	#test_point2 = LoaderUtils.vec3to2D(portal_point2)

	#portal_rotation = cos(((portal_point1.x * portal_point2.x) + (portal_point1.y * portal_point2.y) + (portal_point1.z * portal_point2.z)) / (portal_point1.length() * portal_point2.length()))
	#portal_rotation = cos((test_point1.dot(test_point2)) / (test_point1.length() * test_point2.length()))
	#portal_rotation = rad_to_deg(portal_rotation)

	#print(test_point1.dot(test_point2))
	#print(test_point1.length() * test_point2.length())

	if (!str_target_room.contains(':')):
		internal_room = true
	else:
		internal_room = false
	
	#self.position = object_position
	#self.global_position = object_position
	self.add_child(visibility_checker)
	#visibility_checker.global_position = (portal_point1 + portal_point2) / 2.0
	#visibility_checker.aabb.size = Vector3(object_radius, object_radius, object_radius)
	#visibility_checker.aabb.position = visibility_checker.aabb.size / 2.0
	
	visibility_checker.global_position = portal_center
	visibility_checker.aabb.size = Vector3(portal_radius, portal_radius, portal_radius)
	visibility_checker.aabb.position = visibility_checker.aabb.size / -2.0
	
	Viewer = scene_root.Viewer
	ScenesNode = scene_root.get_parent()
	
	GetDoorNormal()
	
	portal_pos = LoaderUtils.vec3to2D(portal_center)
	portal_nrm  = LoaderUtils.vec3to2D(portal_normal)
	
	if (false):
		self.add_child(test_mesh)
		# x--1
		# |  |
		# 0--x
			
		var v1 : Vector3 = portal_point1
		var v2 : Vector3 = Vector3(portal_point1.x, portal_point2.y, portal_point1.z)
		var v3 : Vector3 = portal_point2
		var v4 : Vector3 = Vector3(portal_point2.x, portal_point1.y, portal_point2.z)

		var st : SurfaceTool = SurfaceTool.new()
			
		st.begin(Mesh.PRIMITIVE_TRIANGLES)

		st.add_vertex(v1)
		st.add_vertex(v2)
		st.add_vertex(v3)
			
		st.add_vertex(v3)
		st.add_vertex(v4)
		st.add_vertex(v1)
			
		#st.commit()
			
		st.set_material(StandardMaterial3D.new())
		test_mesh.mesh = st.commit()
			
		#test_mesh.global_position = Vector3(0, 0, 0)

var room_visible_distance : float #= portal_radius * 55 #250
var target_room : Node

func processDoor() -> void:
	#print('%s %f' % [self.name, object_radius])
	#if scene_root.VWIVersion == 1:
	#	room_visible_distance = portal_radius * 2 #1.5
	#else:
	room_visible_distance = portal_radius * 2 #1.5
	
	if visibility_checker.is_on_screen():
		viewer_pos = LoaderUtils.vec3to2D(Viewer.position)
		vec_test = (viewer_pos - portal_pos).normalized()
		distance_to_viewer = portal_center.distance_to(Viewer.position)
		
		#if portal_nrm.dot(vec_test) > 0.0 and distance_to_viewer < room_visible_distance:
		if portal_nrm.dot(vec_test) > 0.01 and distance_to_viewer < room_visible_distance:
			if internal_room:
				target_room = scene_root.get_node(str_target_room)
				target_room.addQueryToShow() #visible = true
		else:
			if distance_to_viewer <= portal_radius: # * 1.1:
				if internal_room:
					target_room = scene_root.get_node(str_target_room)
					ScenesNode.updateActiveRoom(target_room)
				#scene_root.get_parent().getViewerRoom().is_room_active = false
				#target_room.is_room_active = true
	
		#if self.name == "object_443924": #to_047
		#	if distance_to_viewer <= portal_radius:
		#		print("viewer_in_portal")
		#	else:
		#		print("no.")
	#else:
	#	scene_root.get_node(str_target_room).addQueryToHide() #visible = false
	
	#print(visibility_checker.is_on_screen())
	#if self.name == "object_443924": #to_047
	#if self.name == "object_444040": #to_049
	#	if distance_to_viewer <= portal_radius:
	#		print("viewer_in_portal")
	#	else:
	#		print("no.")
		#print(test_point1)
		#print(test_point2)
		#print(portal_rotation)
		
		#работает!
		#var viewer_pos : Vector2 = LoaderUtils.vec3to2D(Viewer.position)
		#var portal_pos : Vector2 = LoaderUtils.vec3to2D(portal_center)
		#var portal_nrm : Vector2 = LoaderUtils.vec3to2D(portal_normal)
		#var vec_test : Vector2 = (viewer_pos - portal_pos).normalized()
		#https://answers.unity.com/questions/503934/chow-to-check-if-an-object-is-facing-another.html
		#print("dot=%s" % [portal_nrm.dot(vec_test)])
		
		#print(test_point1.length() * test_point2.length())
	#	#print(portal_point1_2d.cross(portal_point2_2d))
	#	direction_to_viewer = portal_center.direction_to(Viewer.position)
	#	if direction_to_viewer.dot(portal_normal) > 0:
	#		print("A sees P!")
	#	else:
	#		print("none")
		#print('%s' % [portal_normal])
		#print('%s' % [portal_normal])
		#print('%f' % [portal_center.dot(Viewer.position)])
	#	print('%s %s' % [self.name, visibility_checker.is_on_screen()])
	#pass

func get_copy() -> Node:
	var func_exec_time : int = Time.get_ticks_msec()
	
	var node : Node3D = Node3D.new()
	node.name = self.name + "_copy"
	node.script = self.script

	node.str_target_room = self.str_target_room
	node.portal_point1 = self.portal_point1
	node.portal_point2 = self.portal_point2
	
	node.global_position = self.object_position
	node.visibility_checker = self.visibility_checker
	node.add_child(node.visibility_checker)
	
	node.portal_center = self.portal_center
	node.portal_radius = self.portal_radius
	node.internal_room = self.internal_room
	
	node.is_copy = true
	
	for child in self.get_children():
		if child != test_mesh:
			var new_child : Node = child.get_copy()
			node.add_child(new_child)
	
	node.scene_root = self.scene_root
	node.visible = self.visible
	scene_root.time_get_copy += (Time.get_ticks_msec() - func_exec_time) / 1000.0
	return node
