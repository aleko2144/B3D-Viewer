class_name VWIModuleLoader

func ImportScene(target_node : Node, scn_path : String, b3d_name : String, res_name : String) -> void:
	var b3d_root : Node = Node3D.new()
	b3d_root.script = load("res://scripts/vwi_formats/b3d/VWISceneContainer.gd")
	b3d_root.name = b3d_name.split('.')[0]
	target_node.add_child(b3d_root)
	
	#var thread : Thread
	#thread = Thread.new()
	#thread.start(ProcessImport.bind(b3d_root, scn_path, b3d_name, res_name), Thread.PRIORITY_NORMAL)
	#thread.wait_to_finish()
	ProcessImport(b3d_root, scn_path, b3d_name, res_name)

func ProcessImport(target_node : Node, scn_path : String, b3d_name : String, res_name : String) -> void:
	
	var b3d_path : String = '%s%s' % [scn_path, b3d_name]
	var res_path : String = '%s%s' % [scn_path, res_name]
	
	var res_buffer : StreamPeerBuffer = LoaderUtils.File2Buffer(res_path)
	var res_file : VWIResourcesContainer = VWIResourcesContainer.new()
	res_file.FromBytes(res_buffer, res_buffer.get_size())
	res_buffer.clear()
	
	target_node.resources = res_file
	
	var b3d_buffer : StreamPeerBuffer = LoaderUtils.File2Buffer(b3d_path)
	var b3d_file : VWIB3DLoader = VWIB3DLoader.new()
	b3d_file.b3d_path = b3d_path
	b3d_file.FromBytes(b3d_buffer, b3d_buffer.get_size(), b3d_path, target_node)
	b3d_buffer.clear()
	
	b3d_file.initialize()
	target_node.initialize()
	#var salo : NodePath 
	#for child in target_node.get_children():
	#	if child.tag != 19:
	#		child.visible = false
