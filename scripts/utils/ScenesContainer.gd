extends Node3D

var Root : Node
var LogWriter : Node
var Viewer : Node

var VWIVersion : int
var ViewMode : int
var objects_array : Array
var switchers_array : Array

func reload() -> void:
	Root = get_tree().get_root().get_child(0)
	LogWriter = Root.LogWriter
	Viewer = Root.Viewer
	
	objects_array.clear()
	switchers_array.clear()
	
func addSwitcherToList(sw_object : Node) -> void:
	#switchers_array = [[имя группы][объекты с данным именем][state][default_state]]
	#var obj_name : String = sw_object.name.lstrip("refer_")
	var obj_name : String = sw_object.original_name.replace("refer_", "")#.replace("_copy", "")
	#var nums_str : PackedStringArray = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
	
	#отсеивание key2, key3 и т.п. (дубликаты)
	#for chr in nums_str:
	#	obj_name = obj_name.replace(chr, "")
	
	#obj_name = obj_name.split("Key", false)[0] + "Key"
	
	for group in switchers_array:
		if group[0][0] == obj_name:
			group[1].append(sw_object)
			return
	
	switchers_array.append([[obj_name], [sw_object], [sw_object.switcher_state], [sw_object.default_state]])
	#switchers_array[-1][1].append(sw_object)
	
func updateSwitchersState(group_index : int, state : int) -> void:
	#switchers_list.add_item(group[0][0])
	#switchers_states.append(group[2][0])
	#default_states.append(group[3][0])
	
	if (!state): #если 0, то default_state
		state = switchers_array[group_index][3][0]
	else: #если 1 или -1
		switchers_array[group_index][2][0] += state
		state = switchers_array[group_index][2][0]
			
	switchers_array[group_index][2][0] = state
	
	for obj in switchers_array[group_index][1]:
		obj.setSwitch_safe(state)

func placeViewerToObserverSpace() -> void:
	#var obs_transform : Transform3D = self.get_child(0).getObserverTransform()
	var obs_transform = self.get_child(0).getObserverTransform()
	if obs_transform != null:
		Viewer.Viewer_SetTransform(obs_transform)

func placeViewerToClosestRoom() -> void:
	var temp_distance : float
	var min_distance : float = 3276700
	var temp_translation : Vector3
	var result : Vector3
	
	for module in self.get_children():
		if module.name != "common":
			temp_translation = module.getClosestRoomToViewer()
			temp_distance = temp_translation.distance_to(Viewer.position)
			#print(temp_translation)
			#print(temp_distance)
			
			if (temp_distance < min_distance):
				min_distance = temp_distance
				result = temp_translation
				#print(temp_translation)
			
	#print(result)
	#print(Viewer.position)
	Viewer.Viewer_SetPosition(result)
	#Viewer.position = result
	
func placeViewerToActiveRoom() -> void:
	Viewer.Viewer_SetPosition(Viewer.current_room.room_center)
	
func placeViewerToStartRoom() -> void:
	if (VWIVersion == 1): #если ДБ-1, то начальная комната из объекта obs
		if self.get_child(0).observer_node:
			var room : Node = self.get_child(0).observer_node.obj_room
			Viewer.current_room = room
			room.is_room_active = true
	
	for module in self.get_children():
		if module.name != "common":
			for room in module.rooms_array:
				if (room.name == Viewer.start_room):
					room.visible = true
					room.is_room_active = true
					Viewer.current_room = room
					Viewer.Viewer_SetPosition(room.room_center)
				
func updateActiveRoom(new_room : Node) -> void:
	var prev_active_room : Node = getViewerRoom()
	if (prev_active_room):
		prev_active_room.is_room_active = false
		new_room.is_room_active = true
					
func getViewerRoom() -> Node:
	for module in self.get_children():
		if module.name != "common":
			for room in module.rooms_array:
				if (room.isViewerRoom()):
					print(room.name)
					return room
	return null
	
func resetViewerPosition():
	if (VWIVersion == 1): #если ДБ-1, то ставить в позицию obs
		placeViewerToObserverSpace()
	else: #если ДБ-2, то либо к ближайшей комнате, либо к активной
		if (ViewMode == 1):
			placeViewerToClosestRoom()
		else:
			placeViewerToActiveRoom()

#func _process(_delta):
#	if (Input.is_action_just_pressed("viewer_reset_transform")):
#		#pass
#		placeViewer()
