extends Node

var Root : Node
var LogWriter : Node
var LoaderUtils : Node

var materials_array : Array
var link_to : Node

func reload():
	Root = get_tree().get_root().get_child(0)
	LogWriter = Root.LogWriter
	LoaderUtils = Root.LoaderUtils
	materials_array.clear()
	link_to = null

func LoadMTL_AddToArrayBin(buffer : StreamPeerBuffer, importing_scene_root : Node) -> void:
	materials_array.append(LoaderUtils.getStr(buffer).split(" ", false))
	link_to = importing_scene_root

func LoadMTL_AddToArrayStr(mtl : String, importing_scene_root : Node) -> void:
	materials_array.append(mtl.split(" ", false))
	link_to = importing_scene_root

func LoadMTL_FromBuffer() -> void:
	#var material_data : Array = LoaderUtils.getStr(buffer).split(" ", false)
	for material_data in materials_array:
		var texture_index : int = 0
		var texture_std : bool
		var texture_ttx : bool
		var color_index : int = 0
		
		#var material : ShaderMaterial = ShaderMaterial.new()
		#material.set_shader(load("res://shaders/VWIMaterialShader.gdshader"))
		var material : StandardMaterial3D = StandardMaterial3D.new()
		#material.flags_vertex_lighting = true #затенение а-ля ДБ-2
		
		material.resource_name = material_data[0] #имя материала
		
		for j in range(len(material_data)):
			if material_data[j] == "tex":# or material_data[j] == "ttx" or material_data[j] == "itx":
				texture_index = material_data[j+1].to_int()
				texture_std = true
				#print(texture_index)
			
			elif material_data[j] == "ttx":
				texture_index = material_data[j+1].to_int()
				texture_ttx = true
			
			elif material_data[j] == "col":
				color_index = material_data[j+1].to_int()
				#print(material_data)

		if (texture_std):
			var txr_file : Image = get_parent().SetImageTexture(texture_index, link_to)
			var txr : ImageTexture = ImageTexture.create_from_image(txr_file)
			txr.set_name(txr_file.get_name())
			if (txr):
				#material.set_shader_parameter('albedo_texture', txr)
				material.albedo_texture = txr
				#material.resource_name += '|' + txr.resource_name
				#if txr.detect_alpha():
				#print(txr.get_format())
				if txr.get_format() == Image.FORMAT_RGBA4444:
					material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				else:
					material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
				#if txr.get_format() != Image.FORMAT_RGB8:
				#if txr.get_format() != Image.FORMAT_RGB8 or txr.get_format() != Image.FORMAT_RGBA8:
				if txr.get_format() == Image.FORMAT_RGBAF:
					material.albedo_texture_force_srgb = true
				
				#BaseMaterial3D.TRANSPARENCY_ALPHA
		
		elif (texture_ttx):
			var txr_file : Image = get_parent().SetImageTexture(texture_index, link_to)
			#txr_file.convert(Image.FORMAT_RGBA4444)
			
			if (color_index):
				txr_file = get_parent().MakeImageTransparent(txr_file, get_parent().SetColor(color_index, link_to))
			else:
				txr_file = get_parent().MakeImageTransparent(txr_file, Color(0, 0, 0))
			
			var txr : ImageTexture = ImageTexture.create_from_image(txr_file)
			txr.set_name(txr_file.get_name())
			
			if (txr):
				#material.resource_name += '|' + txr.resource_name
				material.albedo_texture = txr #BaseMaterial3D.TRANSPARENCY_ALPHA
				#material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
				material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
				
				#if txr.get_format() != Image.FORMAT_RGB8:
				if txr.get_format() == Image.FORMAT_RGBAF:
					material.albedo_texture_force_srgb = true
				#material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
			#material.set_shader_parameter('transparent_by_color', true)
			#if (color_index):
			#	material.set_shader_parameter('transparent_color', get_parent().SetColor(color_index, link_to))
		
		elif (color_index): #если есть текстура, то цвет присваивать не нужно
			#print(color_index)
			#print(get_parent().SetColor(color_index, link_to))
			material.albedo_color = get_parent().SetColor(color_index, link_to)
			#material.set_shader_parameter('use_albedo_color', true)
			#material.set_shader_parameter('albedo_color', get_parent().SetColor(color_index, link_to))
		
		#material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		link_to.materials_array.append(material)

	materials_array.clear()
	link_to = null
