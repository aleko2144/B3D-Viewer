extends Node3D

#var position2D : Vector2

var lock_input : bool

var start_room : String = "room_ap_048"
var current_room : Node
var temp_room : Node

var room_view : bool
@onready var ScenesNode : Node = get_parent().get_node('Scenes')

func prepare():
	$dialog_ObjectSwitcher.visible = false

# Called when the node enters the scene tree for the first time.
func _ready():
	prepare()
	
	"""ограничение FPS"""
	#Engine.set_target_fps(60)

var screenshots_path : String = "./screenshots"
var screenshots_format : String = "png"
var screenshots_quality : float = 0.9

func make_screenshot():
	#https://github.com/godotengine/godot-demo-projects/blob/master/viewport/screen_capture/screen_capture.gd
	
	var dir_access : DirAccess = DirAccess.open(".")
	var path_check : bool = dir_access.dir_exists(screenshots_path)
	var screenshot_name : String
	
	if (!path_check):
		dir_access.make_dir(screenshots_path)
	
	var screenshot_count : int = 1 + get_parent().LoaderUtils.getFilesCountInDir(screenshots_path, "")
	
	var image : Image = get_viewport().get_texture().get_image()
	#var image_tex : ImageTexture = ImageTexture.create_from_image(image)

	if (screenshot_count <= 9):
		screenshot_name = "%s/photo00%d.%s" % [screenshots_path, screenshot_count, screenshots_format]
	elif (screenshot_count >= 10 and screenshot_count <= 99):
		screenshot_name = "%s/photo0%d.%s" % [screenshots_path, screenshot_count, screenshots_format]
	else:
		screenshot_name = "%s/photo%d.%s" % [screenshots_path, screenshot_count, screenshots_format]
	
	match screenshots_format:
		"png":
			image.save_png(screenshot_name)
		"jpg":
			image.save_jpg(screenshot_name, screenshots_quality)
	
func prepare_FileDialog():
	#for scene in ScenesNode.get_children():
	#importing_scene_root.exportAsGLTF('h:/d2/Dev/Viewer_2023/test_export/')
	#$dialog_File.position.x = (get_viewport().get_window().size.x - $FileDialog.size.x) / 2
	#$dialog_File.position.y = (get_viewport().get_window().size.y - $FileDialog.size.y) / 2
	##$FileDialog.current_path = 'h:/d2/Dev/Viewer_2023/test_export/'
	
	$dialog_File.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	$dialog_File.title = "Select a folder to save *.gltf"
	
	$dialog_File.show()
	

func _process(_delta):
	#position2D.x = self.position.x
	#position2D.y = self.position.z
	
	#lock_input = $dialog_ObjectSwitcher.visible or $dialog_File.visible or $dialog_SwitchersList.visible
	lock_input = $dialog_ObjectSwitcher.visible or $dialog_File.visible or $window_About.visible
	
	if (Input.is_action_just_pressed("ui_screenshot")):
		make_screenshot()
		
	if lock_input:
		return
		
	if (Input.is_action_just_pressed("ui_scenes_menu")):
		$window_ScenesList.reset()
		$window_ScenesList.show()
		
	if (Input.is_action_just_pressed("ui_about_screen")):
		$window_About.show()
		
	if (Input.is_action_just_pressed("ui_switchers_menu")):
		$dialog_SwitchersList.reset()
		$dialog_SwitchersList.show()
	
	if (Input.is_action_just_pressed("ui_objects_menu")):
		$dialog_ObjectSwitcher.reset()
		$dialog_ObjectSwitcher.show()
		#lock_input = $dialog_ObjectSwitcher.visible
		
	if (Input.is_action_just_pressed("viewer_switch_ui")):
		$ViewerGUI.visible = !$ViewerGUI.visible

	if (Input.is_action_just_pressed("viewer_export_scene")):
		prepare_FileDialog() #для экспорта
		
	if room_view:
		temp_room = ScenesNode.getViewerRoom()
		if (temp_room):
			current_room = temp_room 

func Viewer_SetTransform(target : Transform3D) -> void:
	if (target):
		self.set_transform(target)
		
func Viewer_SetPosition(target : Vector3) -> void:
	#if (target):
	self.set_position(target)

#func _on_file_dialog_confirmed():
#	var export_path : String = $FileDialog.current_path
#	print(export_path)
	#var filename = await($FileDialog, "file_selected")
	#print(filename)
	#for scene in ScenesNode.get_children():
	#	scene.exportAsGLTF(export_path)
		#scene.exportAsGLTF('h:/d2/Dev/Viewer_2023/test_export/')

func _on_file_dialog_dir_selected(dir):
	var export_path : String = dir + '/'
	#print(export_path)
	for scene in ScenesNode.get_children():
		scene.exportAsGLTF(export_path)
