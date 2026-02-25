class_name VWIB3DLoader
var b3d_path : String
var sceneObj : VWISceneContainer
var root     : Node
var viewer   : Node

var current_level  : int   #текущая глубина вложенности
var lastNodesArray : Array #массив узлов по уровням (array[i] - последний узел уровня i)

var all_nodes : Array

func FromBytes(buffer : StreamPeerBuffer, file_size : int, path : String, target : VWISceneContainer) -> void:
	b3d_path = path
	sceneObj = target
	
	root = sceneObj.get_tree().get_root().get_child(0)
	viewer = root.get_node('Viewer')
	sceneObj.viewer = viewer
	
	lastNodesArray.resize(128)
	lastNodesArray[0] = sceneObj
	
	var load_start_time : int = Time.get_ticks_msec()
	var temp_start_time : int
	
	read_B3DHeader(buffer)
	
	while (buffer.get_position() < file_size):
		read_B3DCase(buffer)

	var total_import_time : float = (Time.get_ticks_msec() - load_start_time) / 1000.0
	LogWriter.writeOutputLog('B3D imported in %.3fs' % [total_import_time])


func read_B3DHeader(buffer : StreamPeerBuffer) -> void:
	var tag : int = buffer.get_u32()
	#6566754 - b3d #4469570 - B3D
	if (tag != 6566754 and tag != 4469570):
		LogWriter.writeErrorLog('Указанный файл не является форматом b3d!/Not *.b3d! (%s)' % [b3d_path], true)
	buffer.seek(buffer.get_position() + 20)
	var mtl_count : int = buffer.get_u32()
	buffer.seek(buffer.get_position() + (mtl_count * 32))
	#for _i in range(mtl_count):
	#	sceneObj.b3d_mtl_names.append(LoaderUtils.readString32(buffer, false))
	#sceneObj.b3d_mtl_count = mtl_count

func read_B3DNode(buffer : StreamPeerBuffer) -> Node:
	var offset : int = buffer.get_position() - 4
	var offset_hex : String = '0x' + ("%x" % offset).to_upper()
	
	var name : String = LoaderUtils.readString32(buffer, true)
	var tag  : int    = buffer.get_32()
	
	var node : Node
	
	match tag:
		0:  #?
			node = B3D_Type00.new()
		1:  #observer
			node = B3D_Type01.new()
			sceneObj.viewerObject = node
		2:  #container event?
			node = B3D_Type02.new()
		3:  #container
			node = B3D_Type03.new()
		4:  #container
			node = B3D_Type04.new()
		5:  #container
			node = B3D_Type05.new()
		7:  #verts container
			node = B3D_Type07.new()
		8:  #faces container
			node = B3D_Type08.new()
		9:  #trigger border (single vector4)
			node = B3D_Type09.new()
		10: #switcher (by distance to viewer)
			node = B3D_Type10.new()
			node.viewer = viewer
		11: #some container
			node = B3D_Type11.new()
		12: #plane (vector4) collision
			node = B3D_Type12.new()
		13: #trigger
			node = B3D_Type13.new()
		14: #event
			node = B3D_Type14.new()
		16: #event ? (16 and 17 are the same)
			node = B3D_Type16.new()
		17: #event ?
			node = B3D_Type17.new()
		18: #object linker
			node = B3D_Type18.new()
		19: #room container
			node = B3D_Type19.new()
			node.viewer = viewer
			sceneObj.rooms.append(node)
		20: #curve
			node = B3D_Type20.new()
		21: #switcher
			node = B3D_Type21.new()
		23: #3D collision
			node = B3D_Type23.new()
		24: #space
			node = B3D_Type24.new()
		25: #sound source
			node = B3D_Type25.new()
		25: #sound source
			node = B3D_Type25.new()
		27: #unknown
			node = B3D_Type27.new()
		28: #3D sprite
			node = B3D_Type28.new()
		29: #parametrized LOD
			node = B3D_Type29.new()
			node.viewer = viewer
		30: #door
			node = B3D_Type30.new()
		31: #3D mask sprite?
			node = B3D_Type31.new()
		_:
			LogWriter.writeErrorLog('Неизвестный тип блока / Unknown type (%d, %s, pos = %s)' % [tag, b3d_path, offset_hex], true)
	
	node.name   = name
	node.offset = offset
	node.offset_hex = ("%x" % offset).to_upper()
		
	var obj_parent : Node = lastNodesArray[current_level - 1]
	obj_parent.add_child(node)
			
	#if (!current_level):
	#	lastNodesArray[current_level - 1].add_child(node)
	#	obj_parent = lastNodesArray[current_level - 1]
	#else:
	#	sceneObj.add_child(node)
	#	obj_parent = sceneObj
	#	node.visible = false
			
	lastNodesArray[current_level] = node
	
	#if obj_parent.switcher:
	#	obj_parent.addToGroup(node)
	
	#if node.tag != 23:
	#	node.visible = false
	#else:
	#	node.visible = true
	
		
	#print("type=%d, pos=%s" % [tag, node.offset_hex])

	#active_scene.nodes_list.append(node)
	node.sceneRoot = sceneObj
	node.FromBytes(buffer)
	
	if obj_parent.is_switcher:
		obj_parent.addToGroup(node)
	
	#obj:  is_col_poly, is_col_plane, is_col_curve
	#room: col_planes,  col_curves, col_polygons 
	if lastNodesArray[1].is_room:
		if node.is_door:
			lastNodesArray[1].doors.append(node)
		elif node.is_col_plane:
			lastNodesArray[1].col_planes.append(node)
		elif node.is_col_curve:
			lastNodesArray[1].col_curves.append(node)
		elif node.is_col_poly:
			lastNodesArray[1].col_polygons.append(node)
	
	if (current_level == 1):
		node.visible = false
		if (node.tag == 19):
			node.visible = true
		#else:
		#	node.visible = false
	
	all_nodes.append(node)
	
	return node
	
func read_B3DCase(buffer : StreamPeerBuffer) -> void:
	var case    : int = buffer.get_u32()
	match case:
		111: #o... \ nodes data start
			pass
		222: #Ю... \ nodes data end
			buffer.seek(buffer.get_size())
		333: #M .. \ node start
			current_level += 1
			read_B3DNode(buffer)
			#B3D_ReadSingleNode(B3DFile, B3DScene)
			#return
		444: #j .. \ group separator
			pass
			#если 444, то отправить в 21-й блок сигнал об
			#окончании заполнения активной группы
			var obj : Node = lastNodesArray[current_level]
			#if obj and (obj.type == 29 or obj.type == 21 or obj.type == 10):
			#if (obj.type == 29 or obj.type == 21 or obj.type == 10):
			if obj.is_switcher:
				obj.finishGroup()
		555: #+_.. \ node end
			current_level -= 1
		_:
			var offset : int = buffer.get_position()
			var offset_hex : String = '0x' + ("%x" % offset).to_upper()
			LogWriter.writeErrorLog('Ошибка чтения файла (ожидалась скобка, получено неожиданное значение %d)/ File read error (expected case, but got %d)(%s, pos = %s)' % [case, case, b3d_path, offset_hex], true)
		
func initialize() -> void:
	for node in all_nodes:
		node.initialize()
