class_name B3D_Room extends B3D_Object

var doors        : Array

var col_planes   : Array #collisionPlane, 12
var col_curves   : Array #collisionCurve, 20
var col_polygons : Array #collisionPolys, 23

var col_shapes   : Array
var viewer       : Node
var neighbours   : Array

var collisions_container : Node3D

var doorStructs : Array

class doorStruct:
	var doorPosition : Vector3
	var doorRadius   : float
	var targetRoom   : Node3D

func initialize() -> void:
	pass
	#collisions_container = Node3D.new()
	#collisions_container.name = 'hit_%s' % self.name
	#self.add_child(collisions_container)
	#
	#for col : Node3D in collisions:
		#var temp_obj : Node3D = col.get_child(0)
		#col.remove_child(temp_obj)
		#collisions_container.add_child(temp_obj)
		#col_shapes.append(temp_obj.get_child(0))
			
	#for door : B3D_Type30 in doors:
	#	if !door.room_node:
	#		return
	#	var str : doorStruct = doorStruct.new()
	#	str.doorPosition = door.door_pos
	#	str.doorRadius   = door.door_w
	#	str.targetRoom   = door.room_node
	#pass
	#for door : B3D_Type30 in doors:
	#	var other_room : Node = sceneRoot.get_node(door.door_room)
	#	if !other_room:
	#		return
	#	var str : doorStruct = doorStruct.new()
	#	str.doorPosition = door.door_pos
	#	str.doorRadius   = door.door_w
	#	str.targetRoom   = other_room
