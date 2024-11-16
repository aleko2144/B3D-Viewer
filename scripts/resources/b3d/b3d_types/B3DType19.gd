extends Node3D

var type : int = 19
var scene_root : Node
var LoaderUtils : Node

var room_doors : Array = []
var room_center : Vector3
var room_radius : float

var need_to_be_imported : bool = true
var is_copy : bool = false

var Viewer : Node
var queriesToShow : int = 0 #запросы на отображение комнаты

var is_room_active : bool
var process_room : bool

func LoadFromB3D(B3DFile) -> void:
	B3DFile.seek(B3DFile.get_position() + 4) #int32 subblocks_num
	scene_root.rooms_array.append(self)
	#scene_root.dynamic_objects_array.append(self)
	Viewer = scene_root.Viewer

func prepare() -> void:
	#if self.name != "room_bg05":
	#	return
	#print(room_center)
	for door in room_doors:
		room_center += door.object_position
	#	print("door=%s" % [door.object_position])
	
	#print(room_center)
	room_center /= len(room_doors)
	
	for door in room_doors:
		room_radius += room_center.distance_to(door.object_position)
		
	room_radius /= len(room_doors)
	
	#print("%s %s %f" % [self.name, room_center, room_radius])
	#print("%s %s, %d" % [self.name, room_center, len(room_doors)])
	#print(Vector3(10, 20, 30) / Vector3(2, 5, 3)) # Prints "(5, 4, 10)"
	#print(Vector3(10, 20, 30) / 10) # Prints "(5, 4, 10)"

func getDistanceToViewer() -> float:
	return room_center.distance_to(scene_root.Viewer.position)
	
func isViewerRoom() -> bool:
	#print("%s %f %f %s" % [self.name, room_radius, room_center.distance_to(scene_root.Viewer.position), room_center.distance_to(scene_root.Viewer.position) < room_radius])
	#return room_center.distance_to(scene_root.Viewer.position) < room_radius
	return is_room_active

func addQueryToShow() -> void:
	queriesToShow += 1

func _process(_delta):
	if !process_room:
		return
	
	if self.visible:
		for door in room_doors:
			door.processDoor()
			
	if (queriesToShow) or (self == Viewer.current_room):
		self.visible = true
	else:
		self.visible = false
		
	queriesToShow = 0

func get_copy() -> Node:
	var func_exec_time : int = Time.get_ticks_msec()

	var node : Node3D = Node3D.new()
	node.name = self.name + "_copy"
	node.script = self.script

	node.scene_root = self.scene_root
	node.visible = self.visible

	node.room_doors = self.room_doors
	node.room_center = self.room_center
	
	scene_root.rooms_array.append(node)
	#scene_root.dynamic_objects_array.append(node)
	node.is_copy = true
	
	for child in self.get_children():
		var new_child : Node = child.get_copy()
		node.add_child(new_child)
	
	scene_root.time_get_copy += (Time.get_ticks_msec() - func_exec_time) / 1000.0
	return node
