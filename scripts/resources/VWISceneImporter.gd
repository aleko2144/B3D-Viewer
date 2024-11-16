extends Node

var Root : Node
var VideoManager : Node
var LogWriter : Node
var LoaderUtils : Node

var importing_scene_root : Node

var VWIVersion : int #1 - ДБ-1 и старые программы, 2 - ДБ-2
var ViewMode : int #1 - просмотр одного *.b3d, 2 - просмотр всего игрового мира
var DisableLOD : bool #работать ли блокам типа 10

var ENV_path : String #для ДБ-2 - папка к модулям игрового мира

var scene_loading : bool

func reload():
	Root = get_tree().get_root().get_child(0)
	LogWriter = Root.LogWriter
	LoaderUtils = Root.LoaderUtils
	Root.Scenes.VWIVersion = VWIVersion
	Root.Scenes.ViewMode = ViewMode
	$B3DImporter.reload()
	$RESImporter.reload()

#func _process(delta):
	#if (scene_loading):
		#print($B3DImporter.load_percent)

func ImportScene(scene_path : String, hide_scene : bool) -> void:
	reload()
	scene_loading = true
	#print("VWISceneLoader::ImportScene(%s)" % [scene_path])
	
	if !LoaderUtils.isFileExists(scene_path):
		LogWriter.writeErrorLogAndExit('Критическая ошибка при импорте файла "%s."' % [scene_path], 'Файл не существует!\nFile is not exists!', "error.log")
	
	var timeStart : int = Time.get_ticks_msec()
	var b3d_name : String = LoaderUtils.getNameFromPath(scene_path, false).to_lower()
	
	importing_scene_root = Node3D.new()
	importing_scene_root.name = b3d_name
	importing_scene_root.script = load('res://scripts/resources/b3d/VWIB3DSceneNode.gd')
	importing_scene_root.LogWriter = LogWriter
	importing_scene_root.B3DImporter = $B3DImporter
	importing_scene_root.hide_scene = hide_scene
	
	importing_scene_root.VWIVersion = VWIVersion
	importing_scene_root.ViewMode = ViewMode
	importing_scene_root.DisableLOD = DisableLOD
	
	Root.Scenes.add_child(importing_scene_root)
	
	var res_load_time : float = $RESImporter.ImportRES(scene_path, importing_scene_root)
	var b3d_load_time : float = $B3DImporter.ImportB3D(scene_path, importing_scene_root)
	var b3d_init_time : float = $B3DImporter.InitB3D(importing_scene_root)
	var total_time : float = (Time.get_ticks_msec() - timeStart) / 1000.0
	
	LogWriter.writeToLog('"%s" загрузка в сек: res=%.1f | b3d=%.1f | init=%.1f | total=%.1f' % [b3d_name, res_load_time, b3d_load_time, b3d_init_time, total_time], "stats.log")
	
	#importing_scene_root.exportAsGLTF('h:/d2/Dev/Viewer_2023/test_export/')
	
	if (ViewMode == 1):
		Root.Scenes.resetViewerPosition()
		Root.Viewer.room_view = false
	else:
		Root.Scenes.placeViewerToStartRoom()
		Root.Viewer.room_view = true
	
	#importing_scene_root.scale = Vector3(0.0001, 0.00001, 0.0001)
	
	if (false):
		#для теста текстур
		$RESImporter/TXRLoader.reload()
		var testMesh_fon : Node = MeshInstance3D.new()
		testMesh_fon.mesh = PlaneMesh.new()
		testMesh_fon.scale *= 1.5
		testMesh_fon.position.z = 1.6
		
		testMesh_fon.rotation_degrees.x = 90
		testMesh_fon.rotation_degrees.y = 180
		
		var testMTL_fon : StandardMaterial3D = StandardMaterial3D.new()
		testMTL_fon.flags_unshaded = 1
		testMTL_fon.albedo_color = Color8(128, 128, 255)
		testMesh_fon.material_override = testMTL_fon
		
		importing_scene_root.add_child(testMesh_fon)
		
		var testMesh : Node = MeshInstance3D.new()
		testMesh.mesh = PlaneMesh.new()
		#testMesh.rotation_degrees.x = -90
		testMesh.rotation_degrees.x = 90
		testMesh.rotation_degrees.y = 180
		testMesh.position.z = 1.5
		
		#для сравнения текстур
		testMesh.position.x = 0.5
		testMesh.scale *= 0.5
		
		var testMTL : StandardMaterial3D = StandardMaterial3D.new()
		testMTL.flags_unshaded = 1
		#testMTL.albedo_texture = $RESImporter/TXRLoader.LoadTXR_FromFile("h:/d2/Dev/Viewer_2023/test_res/res_test/txr/MIR1.TXR")
		
		#var test_txr : NoiseTexture2D = NoiseTexture2D.new()
		#test_txr.noise = FastNoiseLite.new()
		
		var test_txr : Image
		var tex_m : Node = $RESImporter/TXRLoader
		var path : String = "h:/d2/Dev/Viewer_2023/test_res/res_test/txr/"
		#test_txr = tex_m.LoadTXR_FromFile(path + "can_back.txr")
		#test_txr = tex_m.LoadTXR_FromFile(path + "grass2.txr")
		test_txr = tex_m.LoadTXR_FromFile(path + "forest1.txr")
		#test_txr = tex_m.LoadTXR_FromFile(path + "refl_r.txr")
		#test_txr = tex_m.LoadTXR_FromFile(path + "sky2.txr")
		#test_txr = tex_m.LoadTXR_FromFile(path + "moon0.txr")
		#test_txr = tex_m.LoadTXR_FromFile(path + "crpart1.txr")
		#test_txr = tex_m.LoadTXR_FromFile(path + "tb_ball.txr")
		#test_txr = tex_m.LoadTXR_FromFile(path + "CabBMW_Rule.txr")
		#test_txr = tex_m.LoadTXR_FromFile(path + "BackInfo_m15.txr")
		#test_txr = tex_m.LoadTXR_FromFile(path + "BackInfo_m16.txr")
		#test_txr = tex_m.LoadTXR_FromFile(path + "CabZil_08.txr")
		#test_txr = tex_m.LoadTXR_FromFile(path + "pribor.txr")
		
		#testMTL.albedo_texture = $RESImporter/TXRLoader.LoadTXR_FromFile("h:/d2/Dev/Viewer_2023/test_res/res_test/txr/can_back.txr")
		#testMTL.albedo_texture = $RESImporter/TXRLoader.LoadTXR_FromFile("h:/d2/Dev/Viewer_2023/test_res/res_test/txr/tb_forest.txr")
		#testMTL.albedo_texture = $RESImporter/TXRLoader.LoadTXR_FromFile("h:/d2/Dev/Viewer_2023/test_res/res_test/txr/tb_ball.txr")
		#testMTL.albedo_texture = $RESImporter/TXRLoader.LoadTXR_FromFile("h:/d2/Dev/Viewer_2023/test_res/res_test/txr/grass2.txr")
		#testMTL.albedo_texture = $RESImporter/TXRLoader.LoadTXR_FromFile("h:/d2/Dev/Viewer_2023/test_res/res_test/txr/refl_r.txr")
		
		var test_img : ImageTexture = ImageTexture.create_from_image(test_txr)
		#testMTL.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		testMTL.albedo_texture = test_img
		testMTL.albedo_texture_force_srgb = true
		testMesh.material_override = testMTL
		importing_scene_root.add_child(testMesh)

	#LogWriter.writeToLog('Модуль "%s" был загружен за %.1f сек.' % [b3d_name, (Time.get_ticks_msec() - timeStart) / 1000.0], "stats.log")

	importing_scene_root = null
	scene_loading = false
