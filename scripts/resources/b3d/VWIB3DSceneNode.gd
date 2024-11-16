extends Node

var type : int = 32767
var B3DImporter : Node

var hide_scene : bool

var colors_array : Array
var palette_data_array : Array
var backfiles_array : Array
var textures_array : Array
var materials_array : Array
var sounds_array : Array
var objects_array : Array

var dynamic_objects_array : Array
var linkers_array : Array
var dependent_object_array : Array #блоки, у которых есть родительский блок
var switchers_array : Array
var rooms_array : Array

#для экспорта в obj
var meshes_array : Array
var mtl_names_array : Array
var txr_names_array : Array
var txr_indexes_array : Array

var observer_node : Node

var VWIVersion : int
var ViewMode : int
var DisableLOD : bool

@onready var Root : Node = get_tree().get_root().get_child(0) 
@onready var LogWriter : Node
@onready var Viewer : Node = Root.Viewer
@onready var Scenes : Node = Root.Scenes

var SwitchInfo : Node

var time_get_copy : float
#var transparent_mesh_index : int

var search_queries : Array #запросы на поиск блоков
var empty_search_queries : Array #невыполненные запросы на поиск блоков

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func hideUnnecessaryObjects() -> void: #прячет всё, кроме 19-х блоков
	#$MirAndKvant.visible = true
	#print("%s: scene has no rooms" % [self.name])
	#если есть observer и указана комната, то скрыть всё, кроме неё
	if observer_node:
		if observer_node.obj_room:
			#если режим просмотра комнат или комнат нет, то показать
			#объект, указанный в Observer
			if ViewMode == 2 or !(len(rooms_array)):
				observer_node.obj_room.visible = true
				#for child in self.get_children():
				#	if child != observer_node.obj_room:
				#		child.visible = false
				return
				#иначе будет отображение комнат
	if ViewMode == 1:
		for room in rooms_array:
			room.visible = true
	else:
		for room in rooms_array:
			if room.name == Viewer.start_room:
				room.visible = true
			else:
				room.visible = false
	
	if !len(rooms_array) and !hide_scene:
		for child in self.get_children():
			child.visible = true
	
	#for child in self.get_children():
	#	if child.type == 19:
	#		child.visible = true
	

var print_debug_info : bool
func prepareObjects() -> void: #подготавливает блоки 18
	var time_start : int = Time.get_ticks_msec()
	var linkers_array_prepare_time : float 
	var objects_search_time : float 
	var dependent_object_array_prepare_time : float 
	var dynamic_objects_array_prepare_time : float
	var switchers_array_prepare_time : float
	var rooms_array_prepare_time : float
	
	for object in linkers_array:
		object.make_search_query()
		
	searchBlocks()
		
	for object in linkers_array:
		object.prepare()
		
	#linkers_array_prepare_time = (Time.get_ticks_msec() - time_start) / 1000.0
	#print("linkers_array.prepare()=%f" % [(Time.get_ticks_msec() - time_start) / 1000.0])
	
	#time_start = Time.get_ticks_msec()
	
	for object in dependent_object_array:
		object.make_search_query()
	
	dependent_object_array_prepare_time = (Time.get_ticks_msec() - time_start) / 1000.0
	
	
	time_start = Time.get_ticks_msec()
	
	searchBlocks()
	
	objects_search_time = (Time.get_ticks_msec() - time_start) / 1000.0
	
	#time_start = Time.get_ticks_msec()
	
	#for object in linkers_array:
	#	object.prepare()
		
	#linkers_array_prepare_time = (Time.get_ticks_msec() - time_start) / 1000.0

	
	time_start = Time.get_ticks_msec()
	
	for object in dynamic_objects_array:
		object.prepare()
		
	dynamic_objects_array_prepare_time = (Time.get_ticks_msec() - time_start) / 1000.0
	#print("dynamic_objects_array.prepare()=%f" % [(Time.get_ticks_msec() - time_start) / 1000.0])
	
	time_start = Time.get_ticks_msec()
	
	for object in switchers_array:
		object.prepare()
	
	switchers_array_prepare_time = (Time.get_ticks_msec() - time_start) / 1000.0
	#print("switchers_array.prepare()=%f" % [(Time.get_ticks_msec() - time_start) / 1000.0])
	
	time_start = Time.get_ticks_msec()
	
	for object in rooms_array:
		object.prepare()
		object.process_room = ViewMode != 1
		
	rooms_array_prepare_time = (Time.get_ticks_msec() - time_start) / 1000.0
	#print("rooms_array.prepare()=%f" % [(Time.get_ticks_msec() - time_start) / 1000.0])
	if (print_debug_info):
		print("linkers_array.prepare()=%f" % [linkers_array_prepare_time])
		print("dependent_object_array.prepare()=%f" % [dependent_object_array_prepare_time])
		print("objects_search_time=%f" % [objects_search_time])
		print("dynamic_objects_array.prepare()=%f" % [dynamic_objects_array_prepare_time])
		print("switchers_array.prepare()=%f" % [switchers_array_prepare_time])
		print("rooms_array.prepare()=%f" % [rooms_array_prepare_time])
		print("time_get_copy=%f" % [time_get_copy])

func getObserverTransform(): #получение Transform объекта Observer
	if (observer_node):
		#var obs_transform : Transform3D = observer_node.getObserverTransform()
		var obs_transform = observer_node.getObserverTransform()
		if (obs_transform):
			#Root.get_node("Viewer").set_global_transform(obs_transform)
			#Viewer.Viewer_SetTransform(obs_transform)
			return obs_transform
			
	#print(Root.get_node("Viewer").position)
			
func getClosestRoomToViewer():
	#if (VWIVersion == 1 and observer_node):
	#	var obs_transform = observer_node.getObserverTransform()
	#	if (obs_transform):
	#		return obs_transform.origin
	
	var temp_distance : float
	var min_distance : float = 3276700
	var target_translation : Vector3
	for room in rooms_array:
		temp_distance = room.getDistanceToViewer()
		if (temp_distance < min_distance):
			min_distance = temp_distance
			target_translation = room.room_center
	
	#print(min_distance)
	#print(target_translation)
	return target_translation
		
func prepareBackground() -> bool:
	if (len(backfiles_array)):
		var WorldEnv : WorldEnvironment = Root.get_node("WorldEnvironment")
		var sky : Sky = Sky.new()
		sky.sky_material = PanoramaSkyMaterial.new()
		
		#WorldEnv.environment.background_mode = Environment.BG_SKY
		#var sky : Sky = Sky.new()
		#sky.sky_material = ProceduralSkyMaterial.new()
		#WorldEnv.environment.background_sky = sky
		#$Viewer/Label_BackgroundMode.text = "background=sky"
		
		var imgIndex : int
		var imgHeight : int
		
		#поиск картинки с наибольшей высотой
		for i in range(len(backfiles_array)):
			if backfiles_array[i].get_height() > imgHeight:
				imgHeight = backfiles_array[i].get_height()
				imgIndex = i
		
		var back_txr : ImageTexture = ImageTexture.create_from_image(backfiles_array[imgIndex])
		
		sky.sky_material.panorama = back_txr #backfiles_array[imgIndex]
		
		WorldEnv.environment.background_mode = Environment.BG_SKY
		WorldEnv.environment.background_sky = sky
		#WorldEnv.environment.background_color = Color(1, 1, 1, 1)
		#Root.background_mode = 0
		return true
	else: #поиск в viewer.ini данных о цветах
		var WorldEnv : WorldEnvironment = Root.get_node("WorldEnvironment")
		WorldEnv.environment.background_mode = 1

		var color_str : Array = Root.config_file.get_value("backgrounds", self.name, "none").dedent().split(" ", false)
		
		if (color_str[0] == "none"):
			return false
		
		#print(color_str)
		var background_color : Color = Color(int(color_str[0]) / 255.0, int(color_str[1]) / 255.0, int(color_str[2]) / 255.0)
		#print(background_color)
		WorldEnv.environment.background_color = background_color
		WorldEnv.environment.ambient_light_source = 2
		WorldEnv.environment.ambient_light_color = Color(1, 1, 1)
		
		return true
	return false
	
func initScene() -> void:
	var time_start : int = Time.get_ticks_msec()
	#return (Time.get_ticks_msec() - timeStart) / 1000.0
	prepareObjects()
	#print("prepareObjects=%f" % [(Time.get_ticks_msec() - time_start) / 1000.0])
	
	time_start = Time.get_ticks_msec()
	hideUnnecessaryObjects()
	#print("hideUnnecessaryObjects=%f" % [(Time.get_ticks_msec() - time_start) / 1000.0])
	
	
	#for child in self.get_children():
	#	if child.name != "zil": #if child.name != "ZilCab":
	#		child.queue_free()
		
	#prepareLinkerObjects()
	#prepareSwitchersObjects()
	##prepareDependentObjects()
	#prepareRooms()
	##prepareBackground()
	Root.updateBackground()
	#prepareObserverNode()
	#placeObserver()
	
#func getVertsNode() -> Node:
#	return B3DImporter.getVertsNode()

#поиск блока вершин на случай 7/37->21->много 8/35
func getVertsNode(obj : Node) -> Node:
	if obj.type == 37 or obj.type == 36 or obj.type == 7 or obj.type == 6:
		return obj
	elif obj.type == 32767:
		return null
	else:
		return getVertsNode(obj.get_parent())
	
#поиск либо в своём b3d, либо в common.b3d
#func getSceneObject_(scene : Node, parent : Node, object_name : String) -> Object:
func getSceneObject_(scene : Node, object_name : String) -> Object:
	var result : Node = null
	
	#if (object_name == "$$world" or object_name == "db:room_db_012"):
	#	return null
			
	#if (object_name.contains("object_")):
	#	breakpoint
			
	for obj in scene.objects_array:
		if obj[0] == object_name:
			result = obj[1]

	return result
	
func getSceneObject(_parent : Node, object_name : String) -> Object:
	#var result : Node = getSceneObject_(self, parent, object_name)
	var result : Node = getSceneObject_(self, object_name)
	
	if !result and VWIVersion == 2: #если ДБ-2, то поиск в common
		#result = getSceneObject_(Scenes.get_child(0), parent, object_name)
		result = getSceneObject_(Scenes.get_child(0), object_name)
	
	if !result:
		#LogWriter.writeErrorLog("getSceneObject(%s)" % [object_name], "Объект не найден!\nObject not found!", "error.log")
		LogWriter.writeToLog("getSceneObject() %s == null" % [object_name], "error.log")
		return null
		
	return result
	
func searchBlocks() -> void:
	for obj in objects_array:
		for query in search_queries:
			if obj[0] == query[0]:
				query[1].set_external_node(obj[1])
				query[2] = true
				#учёта внешних блоков (из common) нет
			
	if VWIVersion == 2: #если ДБ2, то поиск в common
		for query in search_queries:
			if query[2] == false:
				empty_search_queries.append(query)
				
		var module_common : Node = get_parent().get_node("common")
		if module_common:
			for obj in module_common.objects_array:
				for query in empty_search_queries:
					if obj[0] == query[0]:
						query[1].set_external_node(obj[1])
				
	search_queries.clear()
	empty_search_queries.clear()
	
func addQueryForSearch(target : Node, object_name : String) -> void:
	search_queries.append([object_name, target, false])

func getMaterial(index : int):
	if (len(materials_array) and index <= len(materials_array)):
		return materials_array[index]
	else:
		return StandardMaterial3D.new()
	#var result : Spat
	#result = link_to.textures_array[image_index - 1]
		
	#if (result):
	#	return result
	#else:
	#	LogWriter.writeErrorLog('FATAL ERROR: RESImporter::setImageTexture(%d)' % [image_index], 'There is NO "%d" image in module "%s"!' % [image_index, link_to.name], "error.log")

func switchObjectRender(_name : String) -> void:
	var test_obj : Node = self.get_node(_name)
	if (test_obj):
		test_obj.visible = !test_obj.visible

#var test_obj : String = "ZilR"
#func _process(_delta):
	#pass
	#if (Input.is_action_just_pressed("viewer_show_test_object")):
		#self.get_node(test_obj).visible = !self.get_node(test_obj).visible
		#$ZilR.visible = true
		#$Zil.visible = true
		#$kamaz.visible = true
		#$zil.visible = true
		#$ZilCab.visible = true
		
#https://github.com/godotengine/godot-proposals/issues/3273#issuecomment-958655897
func exportAsGLTF(export_path : String) -> void:
	var gltf : GLTFDocument = GLTFDocument.new()
	var gltf_state : GLTFState = GLTFState.new()

	gltf.append_from_scene(self, gltf_state)

	var file_name : String = '%s.gltf' % self.name
	export_path += file_name
	
	gltf.write_to_filesystem(gltf_state, export_path)
