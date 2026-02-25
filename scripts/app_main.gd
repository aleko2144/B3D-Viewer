extends Node3D

func _init():
	RenderingServer.set_debug_generate_wireframes(true)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	import_in_other_thread()
	pass

var render_mode : int = 0
func _process(delta: float) -> void:
	#if (Input.is_action_just_pressed("ui_screenshot")):
	#	make_screenshot()
	
	if (Input.is_action_just_pressed("render_mode_switch")):
		match render_mode:
			0:
				get_viewport().set_debug_draw(SubViewport.DEBUG_DRAW_DISABLED)
			1:
				get_viewport().set_debug_draw(SubViewport.DEBUG_DRAW_WIREFRAME)
			2:
				get_viewport().set_debug_draw(SubViewport.DEBUG_DRAW_UNSHADED)
		
		if (render_mode < 3):
			render_mode += 1
		else:
			render_mode = 0
		
func import_in_other_thread() -> void:

	var scene_importer : VWIModuleLoader
	scene_importer = VWIModuleLoader.new()
	#scene_importer.ImportScene($B3DScenes, '../old_demo/drivdemo/', 'SEOUL_.B3D', 'SEOUL_.RES')
	#scene_importer.ImportScene($B3DScenes, '../old_demo/cardemo/', 'RACES_D1.B3D', 'RACES_D1.RES')
	scene_importer.ImportScene($B3DScenes, '../CIRCUIT/', 'CIRC.B3D', 'CIRC.RMP')
	#scene_importer.ImportScene($B3DScenes, '../CIRCUIT/', 'CIRC2.B3D', 'CIRC3.RMP')

	#var mat = $B3DScene.resources.getMaterialByName('forest1')
	#$MeshInstance3D2.set_surface_override_material(0, mat)
	
	#var msk = $B3DScenes.get_child(0).resources.getMaskByName('msk\\zil_pan.msk')
	#$TextureRect.texture = msk
