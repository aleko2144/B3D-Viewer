extends Node

var Root : Node
var Scenes : Node
var LogWriter : Node
var LoaderUtils : Node

var importing_file_path : String
var importing_scene_root : Node

var read_error : bool = false
var file_size : int = 0

var current_level : int #текущая глубина вложенности
var lastNodesArray : Array #массив узлов по уровням (array[i] - последний узел уровня i)

var load_percent : float #насколько прочитан файл

func reload():
	Root = get_tree().get_root().get_child(0)
	Scenes = Root.Scenes
	LogWriter = Root.LogWriter
	LoaderUtils = Root.LoaderUtils
	current_level = 0
	
	lastNodesArray.clear()
	lastNodesArray.resize(128) #128
	#lastNodesArray.resize(32767) #128
	#lastNodesArray.resize(2048) #128
	#lastNodesArray.resize(512) #128
	#lastNodesArray.resize(128) #64
	
#func _getVertsNode(level : int) -> Node:
#	var result : Node
#	result = meshesArray[level]
#	if result:
#		return result
#	else:
#		return _getVertsNode(level - 1)

#поиск блока вершин на случай 7/37->21->много 8/35
#func getVertsNode() -> Node:
#	return _getVertsNode(current_level - 1)

func B3D_ReadHeader(B3DFile : StreamPeerBuffer, _B3DScene : Node):
	B3DFile.seek(B3DFile.get_position() + 20) #пропуск заголовка
	var materials_count : int = B3DFile.get_32()
	#для ускорения загрузки можно вообще пропускать материалы, они же в res/pro продублированы
	B3DFile.seek(B3DFile.get_position() + (32 * materials_count)) #пропуск материалов
	#for i in range(materials_count):
	#	print(LoaderUtils.getStr32(B3DFile))

func B3D_ReadFile(B3DFile : StreamPeerBuffer, B3DScene : Node):
	var case : int = B3DFile.get_32()
	#var percent : float = float(B3DFile.get_position()) / file_size
	#Root.Viewer.get_node("dialog_Loader").get_node("ProgressBar").value = 100 * percent
	#print(case)
	
	load_percent = float(B3DFile.get_position()) / file_size
	
	#чтение скобок
	match case:
		111: #o... \ nodes data start
			pass
			#return
		
		222: #Ю... \ nodes data end
			B3DFile.seek(file_size)
			#pass
			#return
				
		333: #M .. \ node start
			current_level += 1
			B3D_ReadSingleNode(B3DFile, B3DScene)
			#return
			
		444: #j .. \ group separator
			#если 444, то отправить в 21-й блок сигнал об
			#окончании заполнения активной группы
			var obj : Node = lastNodesArray[current_level]
			if obj and (obj.type == 29 or obj.type == 21 or obj.type == 10):
				obj.finishGroup()
				#print(obj.name)
				#print(lastNodesArray[current_level+1])
				#pass
			#print(lastNodesArray[current_level+1]) - оно
			#print(importing_scene_root.objects_array[-1][0])
			#pass
			#return
			
		555: #+_.. \ node end
			current_level -= 1
			#return
			
		_:
			LogWriter.writeErrorLogAndExit('Критическая ошибка при импорте файла "%s".' % [importing_file_path], 'Ошибка при чтении файла. Позиция: %s.\nFailed to read file. Position: %s.' % [B3DFile.get_position() - 4, B3DFile.get_position() - 4], "error.log")
			read_error = true

func B3D_ReadSingleNode(B3DFile : StreamPeerBuffer, B3DScene : Node):
	var node : Node
	var node_name : String  = LoaderUtils.getStr32(B3DFile)
	var node_type : int = B3DFile.get_32()
		
	var str_object_script : String
		
	#чтение информации блока
	
	if node_type < 10:
		str_object_script = "B3DType0%d" % node_type
	else:
		str_object_script = "B3DType%d" % node_type
	
	var script_path : String = 'res://scripts/resources/b3d/b3d_types/%s.gd' % str_object_script
	#var script : GDScript = load(script_path)
	#print(LoaderUtils.isFileExists(script_path))
	
	#if (!LoaderUtils.isFileExists(script_path)):
	
	#неизвестные типы блоков b3d, под которые нет кода загрузки
	var invalid_types : Array = [15, 22, 26, 32, 38]
	
	if (invalid_types.has(node_type) or node_type > 40):
		#print(script_path)
		LogWriter.writeErrorLogAndExit('Критическая ошибка при импорте файла "%s".' % [importing_file_path], 'Неизвестный тип блока %s, позиция в файле %s.\nUnknown type %s, position %s.' % [node_type, B3DFile.get_position() - 40, node_type, B3DFile.get_position() - 40], "error.log")
		#var section_size = B3DFile.get_32()
		#B3DFile.seek(B3DFile.get_position() - 4 + section_size)
		read_error = true
		return
		
	if node_type == 35 or node_type == 8:
		node = MeshInstance3D.new()
	else:
		node = Node3D.new()
		
	node.script = load(script_path) #script
	node.scene_root = importing_scene_root
	node.LoaderUtils = LoaderUtils
	
	#node = LoadBlockFromB3D(B3DFile, str_object_type, str_object_script)
	#lastNodesArray[current_level] = node
	
	#если контейнер/визуальный объект, то добавить в сцену,
	#иначе прочитать из b3d и не добавлять
	#if node.need_to_be_imported:
	#if node.need_to_be_imported:
	if true:
		var obj_parent : Node
			
		if current_level > 1:
			lastNodesArray[current_level - 1].add_child(node)
			obj_parent = lastNodesArray[current_level - 1]
		else:
			B3DScene.add_child(node)
			obj_parent = B3DScene
			node.visible = false
			
		lastNodesArray[current_level] = node
		
		node.name = node_name
		importing_scene_root.objects_array.append([node.name, node])
		#importing_scene_root.objects_array.append([node.name, obj_parent.name, node])
		#Scenes.objects_array.append([node.name, obj_parent.name, node])
		#importing_scene_root.objects_array.append([node.name, obj_parent.name, node])
	
		#если родительский блок - 21-й, то добавить новый блок в группу переключения
		if obj_parent.type == 29 or obj_parent.type == 21 or obj_parent.type == 10:
			obj_parent.addToGroup()
		
		#if node.type == 29 or node.type == 21 or node.type == 10:
		if node.type == 21:
			node.original_name = node_name
	else:
		importing_scene_root.objects_array.append([node.name, null])
	
	#прятать всё, что в корне
	#print('%s->%s' % [node.name, B3DFile.get_position() - 40])
	#print('%s->%d' % [node.name, current_level])
	#LogWriter.writeToLog('%s->%s' % [node.name, B3DFile.get_position() - 40], "test.log")
	node.LoadFromB3D(B3DFile)
	
	#lastNodesArray[current_level] = node

func ImportB3D(scene_path : String, link_to : Node) -> float:
	#print("VWIB3DLoader::ImportB3D(%s)" % [scene_name])
	
	var timeStart : int = Time.get_ticks_msec()
	
	var b3d_file : FileAccess = FileAccess.open(scene_path, FileAccess.READ)
	
	importing_scene_root = link_to
	
	importing_file_path = scene_path
	
	#получение размера файла
	b3d_file.seek_end(0)
	file_size = b3d_file.get_position()
	b3d_file.seek(0)

	var buffer : StreamPeerBuffer = StreamPeerBuffer.new()
	buffer.set_data_array(b3d_file.get_buffer(file_size))
	b3d_file.close()
	
	if file_size > 0:
		var b3d_test : int = buffer.get_32()
		if (b3d_test == 6566754 or b3d_test == 4469570): #'b3d.'
			B3D_ReadHeader(buffer, importing_scene_root)
			while (buffer.get_position() < file_size and !read_error):
				B3D_ReadFile(buffer, importing_scene_root)
		else:
			#OS.Alert()
			LogWriter.writeErrorLogAndExit('Критическая ошибка при импорте файла "%s."' % [scene_path], 'Указанный файл - не B3D!\nFile is not B3D!', "error.log")
	else:
		LogWriter.writeErrorLogAndExit('Критическая ошибка при импорте файла "%s."' % [scene_path], 'Файл пустой!\nFile is empty!', "error.log")

	#var time_b3d_load : float = (Time.get_ticks_msec() - timeStart) / 1000.0

	#LogWriter.writeToLog('"%s.b3d" был загружен за %.1f сек.' % [scene_name, (Time.get_ticks_msec() - timeStart) / 1000.0], "stats.log")
	
	#инициализация сцены
	#timeStart = Time.get_ticks_msec()
	#importing_scene_root.initScene()
	#LogWriter.writeToLog('"%s.b3d" был инициализирован за %.1f сек.' % [scene_name, (Time.get_ticks_msec() - timeStart) / 1000.0], "stats.log")
	
	#var time_b3d_init : float = (Time.get_ticks_msec() - timeStart) / 1000.0
	
	#print(lastNodesArray[0])
	#print(lastNodesArray[1])
	#print(lastNodesArray[2])

	#if (process):
	#	importing_scene_root.initializeScene()
	
	return (Time.get_ticks_msec() - timeStart) / 1000.0
	
func InitB3D(link_to : Node) -> float:
	var timeStart : int = Time.get_ticks_msec()
	link_to.initScene()
	return (Time.get_ticks_msec() - timeStart) / 1000.0
