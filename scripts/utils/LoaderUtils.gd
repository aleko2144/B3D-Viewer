extends Node

func getStr32(BinFile : StreamPeerBuffer) -> String:
	var str_array : PackedByteArray = BinFile.data_array.slice(BinFile.get_position(), BinFile.get_position() + 32)
	BinFile.seek(BinFile.get_position() + 32)
	var result : String = str_array.get_string_from_utf8()
	if result.is_empty():
		return "object_%d" % [BinFile.get_position() - 40]
	return result
	
func getStr32_no_prefix(BinFile : StreamPeerBuffer) -> String:
	var str_array : PackedByteArray = BinFile.data_array.slice(BinFile.get_position(), BinFile.get_position() + 32)
	BinFile.seek(BinFile.get_position() + 32)
	var result : String = str_array.get_string_from_utf8()
	if result.is_empty():
		return ""
	return result

func getStr(BinFile : StreamPeerBuffer) -> String:
	# warning-ignore:unassigned_variable
	var str_array : PackedByteArray = []

	while (true):
		var temp_byte : int = BinFile.get_8()
		str_array.append(temp_byte)
		if !temp_byte:
			break
		
	var result : String = str_array.get_string_from_utf8()
	return result
	
func getVector3(BinFile : StreamPeerBuffer) -> Vector3:
	return Vector3(BinFile.get_float(), BinFile.get_float(), BinFile.get_float())
	
func getVector3Pos(BinFile : StreamPeerBuffer) -> Vector3:
	var result : Vector3
	result = Vector3(BinFile.get_float(), BinFile.get_float(), BinFile.get_float())
	return Vector3(-result.x, result.z, result.y)

func getVector2(BinFile : StreamPeerBuffer) -> Vector2:
	return Vector2(BinFile.get_float(), BinFile.get_float())
	
func vec3to2D(vec : Vector3) -> Vector2:
	return Vector2(vec.x, vec.z)
	
func getColor(BinFile : StreamPeerBuffer) -> Color:
	var color_str : PackedStringArray = getStr(BinFile).split(" ", false)
	if (len(color_str) == 3): #MTB/TB.res
		#breakpoint
		return Color(float(color_str[0]),float(color_str[1]),float(color_str[2]))
	else:
		return Color(1,1,1)
		
func getColorStr(color_string : String):
	var color_str : PackedStringArray = color_string.split(" ", false)
	if (len(color_str) == 3):
		return Color(float(color_str[0]), float(color_str[1]), float(color_str[2]))
	else:
		return null #Color(1,1,1)
		
func getColorInt8(BinFile : StreamPeerBuffer) -> Color:
	@warning_ignore("unassigned_variable")
	var result : Color
	
	#result = Color(BinFile.get_u8(), BinFile.get_u8(), BinFile.get_u8())
	result.r8 = BinFile.get_u8()
	result.g8 = BinFile.get_u8()
	result.b8 = BinFile.get_u8()
	#print(result)
	#breakpoint
	#var temp_byte : int
	
	#for _i in range(3):
	#	if temp_byte = BinFile.get_8()
	#		R = 255 + R_dat
	#	else:
	#		R = R_dat
	
	return result
	
func getRGB(BinFile : StreamPeerBuffer) -> Color:
	return Color(BinFile.get_float(), BinFile.get_float(), BinFile.get_float())

func compareColors(col1 : Color, col2 : Color, accuracy : float) -> bool:
	return abs(col1.r - col2.r) <= accuracy or abs(col1.g - col2.g) <= accuracy or abs(col1.b - col2.b) <= accuracy

func compareColorsByColor(col1 : Color, col2 : Color, accuracy : Color) -> bool:
	return abs(col1.r - col2.r) <= accuracy.r or abs(col1.g - col2.g) <= accuracy.g or abs(col1.b - col2.b) <= accuracy.b

func getMTLcolor(color : Color) -> String:
	return '%f %f %f' % [color.r, color.g, color.b]

func getNameFromPath(string : String, withFormat : bool) -> String:
	var file_name : String = string.split("/")[-1]
	
	if !withFormat:
		var file_format : String = '.' + file_name.split(".")[-1]
		return file_name.left(len(file_name) - len(file_format))
	else:
		return file_name

func getNameFromPath_res(string : String, withFormat : bool) -> String:
	var file_name : String = string.split("\\")[-1]
	
	if !withFormat:
		var file_format : String = '.' + file_name.split(".")[-1]
		return file_name.left(len(file_name) - len(file_format))
	else:
		return file_name

func getPathWithoutFile(path : String) -> String:
	return path.get_base_dir()
		
func isFileExists(path : String) -> bool:
	#var dir_temp : DirAccess
	#print(path)
	#return dir_temp.file_exists(path)
	return FileAccess.file_exists(path)

func getFilesFromDir(path : String, extension : String) -> Array:
	var result : Array = []
	var dir : DirAccess = DirAccess.open(path)
	if (dir):
		dir.list_dir_begin()
		var file : String = dir.get_next()
		while (!file.is_empty()):
			if (!dir.current_is_dir()):
				if file.ends_with(extension):
					#print(path + file)
					result.append(path + file)
			#print(file)
			file = dir.get_next()
	return result
	
func getFilesCountInDir(path : String, extension : String) -> int:
	var result : int
	var dir : DirAccess = DirAccess.open(path)
	if (dir):
		dir.list_dir_begin()
		var file : String = dir.get_next()
		while (!file.is_empty()):
			if (!dir.current_is_dir()):
				if (extension == ""):
					result += 1
				elif file.ends_with(extension):
					result += 1
			#print(file)
			file = dir.get_next()
	return result
	
func get_object_child_copy(object_old : Node, object_new : Node) -> void:# -> Node:
	var new_child : Node
	for child in object_old.get_children():
		#if !child.script or child.is_copy:
		#if not child.is_class("OmniLight3D") and not child.name.contains("_copy"):
		#проверка меньше 41 для типов 301 и 331
		if child.type < 41 and !child.is_copy: #!child.is_class("OmniLight3D"):
			new_child = child.get_copy()
			get_object_child_copy(child, new_child)
			#new_child = child.get_copy()
			object_new.add_child(new_child)

func get_object_copy(object : Node) -> Node:
	var result : Node = object.get_copy()
	get_object_child_copy(object, result)
	return result
