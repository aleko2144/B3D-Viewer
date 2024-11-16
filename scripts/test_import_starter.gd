extends Node3D
var LogWriter : Node
var LoaderUtils : Node
var Viewer : Node
var Scenes : Node

var str_AppVersion : String = "v 1.0 2024.11.16"
var str_RootDir : String = "./"

@export var config_file_path : String = "viewer.ini"
var config_file : ConfigFile = ConfigFile.new()

var scenes_load_list : Array

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
#var imported : bool = false
#func import():
#	if imported:
#		return
	
#	imported = true

#func deleteLogs():
	#var temp : Directory = Directory.new()
	# warning-ignore:return_value_discarded
	#temp.remove(str_RootDir + 'stats.log')
#	DirAccess.remove_absolute(str_RootDir + 'stats.log')

func _ready():
	LogWriter = $LogWriter
	LoaderUtils = $LoaderUtils
	Viewer = $Viewer
	Scenes = $Scenes
	
	var err = config_file.load(config_file_path)
	
	if err != OK:
		OS.alert('Config file "%s" not found! Starting aborted.' % [config_file_path], 'Critical error')
		get_tree().quit()
		return
		
	$Viewer.screenshots_path = config_file.get_value("screenshots", "path", "./screenshots")
	$Viewer.screenshots_format = config_file.get_value("screenshots", "format", "png")
	$Viewer.screenshots_quality = float(config_file.get_value("screenshots", "quality", "0.9"))

	$LogWriter.reload()
	$SceneImporter.reload()
	$Scenes.reload()
	
	#var scene_path : String = "h:/d2/Dev/Viewer_2023/test_res/MTB_72/TB.ALL.B3D"
	#var scene_path : String = "h:/d2/Dev/Viewer_2023/test_res/MTB_72/TB.B3D"
	#var scene_path : String = "h:/d2/Dev/Viewer_2023/test_res/MENV_72/DR.B3D"
	#var scene_path : String = "h:/d2/Dev/Viewer_2023/test_res/MENV_72/dr_8_tex_mod.B3D"
	#var scene_path : String = "h:/d2/Dev/Viewer_2023/test_res/MENV_test/DR.B3D"
	
	$SceneImporter.VWIVersion = int(config_file.get_value("common", "VWIVersion", "1"))
	#1 - ДБ-1 и старые программы, 2 - ДБ-2
	
	$SceneImporter.ViewMode = int(config_file.get_value("common", "ViewMode", "1"))
	#1 - просмотр одного *.b3d, 2 - просмотр всего игрового мира
	
	$SceneImporter.DisableLOD = true #bool(config_file.get_value("common", "DisableLOD", "1"))
	#работать ли блокам типа 10

	#удаление старого log-файла
	DirAccess.remove_absolute(str_RootDir + 'stats.log')
	
	LogWriter.writeToLog(" *** Обозреватель B3D запущен %s %s ***" % [LogWriter.getDateFormated(), LogWriter.getTimeFormated()], "stats.log")
	LogWriter.writeToLog(" *** Версия %s ***" % str_AppVersion, "stats.log")
	LogWriter.writeToLog("Параметры:", "stats.log")
	LogWriter.writeToLog("	-> VWIVersion = %d" % $SceneImporter.VWIVersion, "stats.log")
	LogWriter.writeToLog("	-> scenes_file = %s" % config_file.get_value("common", "scenes_file", "scenes.lst"), "stats.log")
	LogWriter.writeToLog("	-> screenshots_dir = %s" % $Viewer.screenshots_path, "stats.log")
	LogWriter.writeToLog("	-> screenshots_format = %s" % $Viewer.screenshots_format, "stats.log")
	LogWriter.writeToLog("	-> screenshots_quality = %.2f" % $Viewer.screenshots_quality, "stats.log")
	LogWriter.writeToLog('\n', 'stats.log')
	
	$Viewer/window_About/lbl_AppVersion.text = str_AppVersion

func fixWinPos() -> void:
	var win_res : Vector2i = DisplayServer.window_get_size() #Vector2i(1280, 720)
	var screen_size = DisplayServer.screen_get_size()
	
	var win_x : int = (screen_size.x/2) - (win_res.x/2)
	var win_y : int = (screen_size.y/2) - (win_res.y/2)

	#get_window().set_size(win_res)
	get_window().set_position(Vector2i(win_x, win_y))
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


var is_loading_started : bool = false
var are_scenes_loaded : bool = false
var is_screen_fixed : bool = false
var tick_start : int

func _physics_process(delta):
	if (!tick_start):
		$Viewer/ViewerGUI.visible = false
		tick_start = Time.get_ticks_msec()
		
		get_window().set_size(Vector2i(512, 85))
		fixWinPos()
		
		load_scenes_list()
		
		#OS.set_borderless_window(true)
		#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, 0)

	#if (!are_scenes_loaded):
	if (!is_loading_started):
		if (Time.get_ticks_msec() - tick_start > 500):
			
			load_scenes()
			
			#Thread.new().start(load_scenes)
			#Thread.new().call_thread_group("load_scenes")
			
			is_loading_started = true
			
	if (!are_scenes_loaded):
		pass
		#if ($SceneImporter/B3DImporter.load_percent):
		#	print($SceneImporter/B3DImporter.load_percent)

	if (!is_screen_fixed and are_scenes_loaded):
		if (Time.get_ticks_msec() - tick_start > 500):
			#tick_start = Time.get_ticks_msec()

			get_window().set_size(Vector2i(1280, 720))
			fixWinPos()
			
			$LoadScr.visible = false
			$Viewer/ViewerGUI.visible = true
			
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, 0)
			
			is_screen_fixed = true


func load_scenes() -> void:
	for scn in scenes_load_list:
		#print("%s %s" % [scn[0], scn[1]])
		#var thr = Thread.new()
		#thr.start($SceneImporter.ImportScene.bind(scn[0], scn[1]))
		
		$SceneImporter.ImportScene(scn[0], scn[1])
		
		#scenes_load_list.append([loading_scene_name, loading_scene_hide])
	
	#tick_start = Time.get_ticks_msec()
	are_scenes_loaded = true
	scenes_load_list.clear()

func load_scenes_list() -> void:
	var loading_scene_name : String
	var loading_scene_hide : bool

	var scenes_file : FileAccess = FileAccess.open(config_file.get_value("common", "scenes_file", "scenes.lst"), FileAccess.READ)
		
	var scene_line : String
	var scenes_file_len : int = scenes_file.get_length()
	var temp_str : PackedStringArray
	
	while (scenes_file.get_position() < scenes_file_len):
		scene_line = scenes_file.get_line().dedent()

		#проверка, 1) пустая ли строка,
		#          2) является ли она комментарием,
		#          3) и есть ли в начале "[scene:"
		if (scene_line.is_empty() or scene_line[0] == ";"):
			continue
		
		temp_str = scene_line.split(":", false) 
		#print(temp_str)
		loading_scene_name = temp_str[1].strip_edges() #.dedent()
		#[0] - scene, [1] - path, [2] - hide (опционально)
		
		if (temp_str[0] == "scene"):
			if (len(temp_str) > 2): #есть ли параметр hide
				loading_scene_hide = true
			
			#$SceneImporter.ImportScene(loading_scene_name, loading_scene_hide)
			scenes_load_list.append([loading_scene_name, loading_scene_hide])
			
		elif (temp_str[0] == "dir"):
			#loadFromDir(loading_scene_name)
			var modules_list : Array = LoaderUtils.getFilesFromDir(loading_scene_name, "b3d")
			for module in modules_list:
				#$SceneImporter.ImportScene(module, false)
				scenes_load_list.append([module, false])
	
	scenes_file.close()
	#emit_signal.call_deferred("all_scenes_imported")
	
var wireframe : bool
var unshaded : bool
var background_mode : int #0 - b3d, 1 - custom color, 2 - sky

func updateBackground() -> void:
	var WorldEnv : WorldEnvironment = $WorldEnvironment
	match background_mode:
		0:
			if ($Scenes.get_child(0).prepareBackground()):
				$Viewer/ViewerGUI/Label_BackgroundMode.text = "background=b3d"
			else:
				background_mode = 1
				updateBackground()
			$DirectionalLight3D.visible = false
		1:
			WorldEnv.environment.background_mode = Environment.BG_COLOR
			WorldEnv.environment.background_color = Color("808080")
			WorldEnv.environment.ambient_light_color = Color("FFFFFF")
			$Viewer/ViewerGUI/Label_BackgroundMode.text = "background=color"
			$DirectionalLight3D.visible = false
		2:
			WorldEnv.environment.background_mode = Environment.BG_SKY
			var sky : Sky = Sky.new()
			var sky_mtl : ProceduralSkyMaterial = ProceduralSkyMaterial.new()
			#sky_mtl.sky_energy_multiplier = 5
			sky.sky_material = sky_mtl
			WorldEnv.environment.background_sky = sky
			$Viewer/ViewerGUI/Label_BackgroundMode.text = "background=sky"
			$DirectionalLight3D.visible = false

#отрисовка сетки
func _init():
	RenderingServer.set_debug_generate_wireframes(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if $Viewer.lock_input:
		return
	
	if (Input.is_action_just_pressed("render_wireframe")):
		wireframe = !wireframe
		if (wireframe):
			get_viewport().set_debug_draw(SubViewport.DEBUG_DRAW_WIREFRAME)
			$Viewer/ViewerGUI/Label_DrawMode.text = "DrawMode=wireframe"
		else:
			get_viewport().set_debug_draw(SubViewport.DEBUG_DRAW_DISABLED)
			$Viewer/ViewerGUI/Label_DrawMode.text = "DrawMode=normal"
	
	if (Input.is_action_just_pressed("render_unshaded")):
		unshaded = !unshaded
		if (unshaded):
			get_viewport().set_debug_draw(SubViewport.DEBUG_DRAW_UNSHADED)
			$Viewer/ViewerGUI/Label_DrawMode.text = "DrawMode=unshaded"
		else:
			get_viewport().set_debug_draw(SubViewport.DEBUG_DRAW_DISABLED)
			$Viewer/ViewerGUI/Label_DrawMode.text = "DrawMode=normal"
			
	if (Input.is_action_just_pressed("render_change_background")):
		if background_mode < 3:
			background_mode += 1
		else:
			background_mode = 0
			
		updateBackground()
	
	if (Input.is_action_just_pressed("render_switch_light")):
		$DirectionalLight3D.visible = !$DirectionalLight3D.visible

func loadFromDir(path : String) -> void:
	var modules_list : Array = LoaderUtils.getFilesFromDir(path, "b3d")
	for module in modules_list:
		$SceneImporter.ImportScene(module, false)
