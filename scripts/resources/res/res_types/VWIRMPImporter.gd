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
var file_data : StreamPeerBuffer = StreamPeerBuffer.new()
var file_path : String
var file_size : int

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
	file_path = ""
	file_size = 0

func ReadRES() -> void:
	var line : String
	var items_count : int = 0 #кол-во элементов (текстур/материалов/звуков)
	#var iter : int = 0
	while (file_data.get_position() < file_size):
		line = LoaderUtils.getStr(file_data)
		
		get_parent().load_percent = float(file_data.get_position()) / file_size
		
		#print('"%s"' % [line])
		#print("str=%s" % [LoaderUtils.getStr(file_data)])
		#breakpoint
		
		#PALETTEFILES
		#SOUNDFILES
		#BACKFILES
		#MASKFILES
		#TEXTUREFILES
		#COLORS
		#MATERIALS
		
		if line.left(12) == 'PALETTEFILES':
			items_count = line.to_int()
			#print(items_count)
			for _k in range(items_count):
				PLMLoader.LoadPLM_FromBuffer(file_data, importing_scene_root)
				#var plm : ImageTexture = TXRLoader.LoadTXR_FromBuffer(file_data)
				#importing_scene_root.palettes_array.append(plm)
		
		elif line.left(10) == 'SOUNDFILES':
			items_count = line.to_int()
			for _k in range(items_count):
				WAVLoader.LoadWAV_FromBuffer(file_data)
				#var plm : ImageTexture = TXRLoader.LoadTXR_FromBuffer(file_data)
				#importing_scene_root.palettes_array.append(plm)
				
		elif line.left(9) == 'BACKFILES':
			items_count = line.to_int()
			#print(items_count)
			for _k in range(items_count):
				var txr : Image = TXRLoader.LoadTXR_FromBuffer(file_data)
				importing_scene_root.backfiles_array.append(txr)
				#TXRLoader.LoadTXR_FromBuffer(file_data)
		
		elif line.left(9) == 'MASKFILES':
			items_count = line.to_int()
			#print(items_count)
			for _k in range(items_count):
				MSKLoader.LoadMSK_FromBuffer(file_data)
				
		elif line.left(12) == 'TEXTUREFILES':
			items_count = line.to_int()
			#print(items_count)
			for _k in range(items_count):
				var txr : Image = TXRLoader.LoadTXR_FromBuffer(file_data)
				importing_scene_root.textures_array.append(txr)
				
		elif line.left(6) == 'COLORS':
			items_count = line.to_int()
			#print(items_count)
			#!!! если есть PLM, то эти цвета не использовать !!!
			for _k in range(items_count):
				var color = LoaderUtils.getColor(file_data)
				if color:
					importing_scene_root.colors_array.append(color)
				#importing_scene_root.colors_array.append(LoaderUtils.getColor(file_data))
			##если ДБ2, то пропуск секции цветов
			#if (get_parent().get_parent().VWIVersion == 2):
				#for _k in range(items_count):
					#LoaderUtils.getStr(file_data)
			#else:
				#for _k in range(items_count):
					#LoaderUtils.getStr(file_data)
					
		elif line.left(9) == 'MATERIALS':
			items_count = line.to_int()
			#print(items_count)
			for _k in range(items_count):
				#сначала сохранение данных о материалах в массив
				MTLLoader.LoadMTL_AddToArrayBin(file_data, importing_scene_root)
				#var mtl : StandardMaterial3D = MTLLoader.LoadMTL_FromBuffer(file_data, importing_scene_root)
				#importing_scene_root.materials_array.append(mtl)
		
		#iter += 1
		#if iter > 5:
		#	breakpoint
		
	#только после загрузки создание материалов, на случай если палитра идёт после них
	MTLLoader.LoadMTL_FromBuffer()
	
		

func ImportResources(path : String, link_to : Node) -> void:
	var res_file : FileAccess = FileAccess.open(path, FileAccess.READ)
	
	#получение размера файла
	res_file.seek_end(0)
	file_size = res_file.get_position()
	res_file.seek(0)

	file_data.set_data_array(res_file.get_buffer(file_size))
	res_file.close()
	
	importing_scene_root = link_to
	file_path = path
	
	if file_size > 0:
		ReadRES()
	else:
		LogWriter.writeErrorLogAndExit('Критическая ошибка при импорте файла "%s."' % [path], 'Файл пустой!\nFile is empty!', "error.log")

	file_size = 0
