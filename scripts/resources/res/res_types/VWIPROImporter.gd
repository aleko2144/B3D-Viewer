extends Node

var Root : Node
var LogWriter : Node
var LoaderUtils : Node

var TXRLoader : Node
var MSKLoader : Node
var MTLLoader : Node
var PLMLoader : Node
var WAVLoader : Node

var importing_scene_root : Node
var file_data : Array
var file_path : String

func reload():
	Root = get_tree().get_root().get_child(0)
	LogWriter = Root.LogWriter
	LoaderUtils = Root.LoaderUtils

	TXRLoader = get_parent().get_node("TXRLoader")
	MSKLoader = get_parent().get_node("MSKLoader")
	MTLLoader = get_parent().get_node("MTLLoader")
	PLMLoader = get_parent().get_node("PLMLoader")
	WAVLoader = get_parent().get_node("WAVLoader")
	
	file_data.clear()

func loadTXR(path : String) -> void:
	path = file_path + '/' + path.replace("\\", "/") #+ '.png'
	
	if LoaderUtils.isFileExists(path):
		var txr = TXRLoader.LoadTXR_FromFile(path)
		importing_scene_root.textures_array.append(txr)
		
	else:
		LogWriter.writeErrorLogAndExit('Критическая ошибка при импорте файла "%s."' % [path], 'Файл не найден!\nFile is not found!', "error.log")

func loadTXR_background(path : String) -> void:
	path = file_path + '/' + path.replace("\\", "/") #+ '.png'
	
	if LoaderUtils.isFileExists(path):
		var txr = TXRLoader.LoadTXR_FromFile(path)
		importing_scene_root.backfiles_array.append(txr)
		
	else:
		LogWriter.writeErrorLogAndExit('Критическая ошибка при импорте файла "%s."' % [path], 'Файл не найден!\nFile is not found!', "error.log")

func loadMTL(data : String) -> void:
	var material_data : Array = data.split(" ", false)
	#var material_name : String = material_data[0]
	var texture_index : int = 0
	
	for j in range(len(material_data)):
		if material_data[j] == "tex" or material_data[j] == "ttx" or material_data[j] == "itx":
			texture_index = material_data[j+1].to_int()
			
	var material : StandardMaterial3D = StandardMaterial3D.new()
	#material.flags_vertex_lighting = true #затенение а-ля ДБ-2
	material.albedo_texture = get_parent().SetImageTexture(texture_index, importing_scene_root)
	importing_scene_root.materials_array.append(material)

func ParsePRO() -> void:
	var line : String
	var items_count : int = 0 #кол-во элементов (текстур/материалов/звуков)
	
	for i in range(len(file_data)):
		line = file_data[i]
		
		get_parent().load_percent = float(i) / len(file_data)
		
		if line.left(12) == 'PALETTEFILES':
			items_count = line.to_int()
			#print(items_count)
			for k in range(items_count):
				var path : String = file_path + '/' + file_data[i+k+1].replace("\\", "/")
				PLMLoader.LoadPLM_FromFile(path, importing_scene_root)
			i += items_count
			
		elif line.left(9) == 'BACKFILES':
			items_count = line.to_int()
			for k in range(items_count):
				loadTXR_background(file_data[i+k+1].split(" ")[0])
			i += items_count

		elif line.left(12) == 'TEXTUREFILES':
			items_count = line.to_int()
			for k in range(items_count):
				loadTXR(file_data[i+k+1].split(" ")[0])
			i += items_count
			
		elif line.left(6) == 'COLORS':
			items_count = line.to_int()
			for k in range(items_count):
				var color = LoaderUtils.getColorStr(file_data[i+k+1])
				if color:
					importing_scene_root.colors_array.append(color)
			i += items_count
			
		elif line.left(9) == 'MATERIALS':
			items_count = line.to_int()
			for k in range(items_count):
				MTLLoader.LoadMTL_AddToArrayStr(file_data[i+k+1], importing_scene_root)
			i += items_count
		
		#добавить PALETTEFILES
		
	#только после загрузки создание материалов, на случай если палитра идёт после них
	MTLLoader.LoadMTL_FromBuffer()

func ImportResources(path : String, file : String, link_to : Node) -> void:
	var pro_file : FileAccess = FileAccess.open(file, FileAccess.READ)
	while not pro_file.eof_reached():
		file_data.append(pro_file.get_line())
	pro_file.close()
	importing_scene_root = link_to
	file_path = path
	ParsePRO()
