extends Node

var Root : Node
var LogWriter : Node
var LoaderUtils : Node

var file_path : String
var file_size : int

func reload():
	Root = get_tree().get_root().get_child(0)
	LogWriter = Root.LogWriter
	LoaderUtils = Root.LoaderUtils
	
	file_size = 0
	
#https://docs.godotengine.org/en/3.6/classes/class_streampeer.html#class-streampeer-method-get-u8
#чтение unsigned int-ов
var use_mipmaps : bool
func LoadTXR_GetPRFM(file : StreamPeerBuffer) -> Array:
	var original_offset = file.get_position() + 12 #пропуск LOFF
	var id : int = file.get_32()
	var offset : int
	
	#LOFF
	if id != 1179012940:
		LogWriter.writeErrorLogAndExit('Критическая ошибка при импорте файла "%s."' % [file_path], 'Нет секции LOFF после заголовка TXR!\nLOFF section is not defined after TXR header!\n(%d)' % [id], "error.log")
	
	file.seek(file.get_position() + 4) #размер секции LOFF
	offset = file.get_32() #указатель в секции LOFF
	file.seek(offset)  #переход по "указателю"
	
	#LVMP/PFRM
	id = file.get_32()
	if (id == 1347245644): #LVMP
		offset = file.get_32() + 2
		file.seek(file.get_position() + offset + 4)
		use_mipmaps = true
		
	elif (id != 1297237584): #PFRM
		LogWriter.writeErrorLogAndExit('Критическая ошибка при импорте файла "%s."' % [file_path], 'Неизвестная секция в TXR!\nUnknown section in TXR!\n(%d)' % [id], "error.log")
	
	file.seek(file.get_position() + 4)
	#print(file.get_position()) #пропуск параметра длины PFRM
	var PFRM_data : Array = []
	
	for _i in range(4):
		PFRM_data.append(file.get_32())
		
	#проверка на неподдерживаемый формат
	if (offset > 0x10):
		PFRM_data.append(file.get_32())
		PFRM_data.append(file.get_32())
		
	file.seek(original_offset)

	return PFRM_data
	
#по базе BoPoH'а и заметкам из DC
#ReadTextureHeaderFromFile()
func LoadTXR_GetImageFormat(file : StreamPeerBuffer) -> int:
	var PRFM_data : Array = LoadTXR_GetPRFM(file)
	var mask_r : int = PRFM_data[0]
	var mask_g : int = PRFM_data[1]
	var mask_b : int = PRFM_data[2]
	var mask_a : int = PRFM_data[3]
	
	#print(PRFM_data)
		
	#var format : String
	#RGB_555, RGB_565, RGB_4444, RGB_888, RGB_8888
	if (mask_b == 0x1F):
		if (mask_g == 0x3E0):
			if (mask_r == 0x7C00 and !mask_a):
				return 555 #"RGB_555"
		elif (mask_g == 0x7E0 and mask_r == 0xF800 and !mask_a):
			return 565 #"RGB_565"
			
	elif (mask_b == 0xF):
		if (mask_g == 0xF0 and mask_r == 0xF00 and mask_a == 0xF000):
			return 4444 #"RGB_4444"
		
	elif (mask_b == 0xFF and mask_g == 0xFF00 and mask_r == 0xFF0000):
		if (!mask_a):
			return 888 #"RGB_888"
		if (mask_a == 0xFF000000):
			return 8888 #"RGB_8888"
			
	if (len(PRFM_data) > 4):
		if (PRFM_data[4] != 0xFF00 or PRFM_data[5] !=0xFF):
			LogWriter.writeErrorLogAndExit('Критическая ошибка при импорте файла "%s."' % [file_path], 'Формат текстуры не поддерживается/texture format is not supported', "error.log")
			return 0 #"unsupported"
		else:
			#bump 4444
			return 4444
		
	return 0 #"unsupported"
	#print(format)
	
func LoadTXR_LoadData(file : StreamPeerBuffer, _file_length : int) -> Image:
	#var image_start_offset : int = file.get_position()
	#var idSize : int = file.get_8()
	file.seek(12) #11

	#размер картинки
	var size_x : int = file.get_16()
	var size_y : int = file.get_16()
	#остальная информация
	var bit : int = file.get_8() #битность картинки
	
	file.seek(file.get_position() + 1)
	
	#print('%d;%d;%d' % [size_x, size_y, bit])
	#LogWriter.writeToLog('%d;%d;%d' % [size_x, size_y, bit], "txr.log")
	
	if !bit:
		breakpoint

	var image : Image = Image.new()
	
	if bit == 8:
		#var image :  Image = Image.new()
		#загрузить как обычный tga
		image.load_tga_from_buffer(file.data_array)
		#print(file.data_array)
		
		#var result : ImageTexture = ImageTexture.create_from_image(image)
		#result.create_from_image(image)
		#return result
			
	elif bit == 16:

		use_mipmaps = false
		var format_int : int = LoadTXR_GetImageFormat(file)

		
		#если 4444, то прочитать и создать своим кодом, иначе - встроенным в Годо
		if (format_int == 565):
			#var colors : PackedByteArray = file.data_array.slice(file.get_position(), file.get_position() + (size_x * size_y * 2))
			#image = Image.create_from_data(size_x, size_y, false, Image.FORMAT_RGB565, colors)
			image = Image.create(size_x, size_y, false, Image.FORMAT_RGBAF) #_RGBF
			var pixel : int
			var r : int
			var g : int
			var b : int
			for j in range(size_y):
				for i in range(size_x):
					pixel = file.get_16()
					r = 8 * (pixel & 0x1F)
					g = (pixel >> 3) & 0xFC
					b = (pixel >> 8) & 0xF8
					
					#48 56 16 в txr с параметрами - ttx col 256(50,59,18)
					#if (r > 40 and g > 45 and b > 12):
					#	r += 4 #2
					#	g += 4 #2
					#	b += 4 #2
					#актуально для ap/forest1 ttx col 256 -> common.plm
					
					image.set_pixel(i, j, Color8(b, g, r))
					#image.set_pixel(i, j, Color(b / 255.0, g / 255.0, r / 255.0))
					#image.set_pixel(i, j, Color(b, g, r))
					#var temp_color : Color = Color8(b, g, r)
					#var temp_color : Color = Color(b / 255.0, g / 255.0, r / 255.0)
				
					#temp_color.r *= 0.22
					#temp_color.g *= 0.21
					#temp_color.b *= 0.15
					
					#temp_color.r *= 0.458
					#temp_color.g *= 0.457
					#temp_color.b *= 0.324
					
					#temp_color.r *= 0.65
					#temp_color.g *= 0.65
					#temp_color.b *= 0.58
					
					#image.set_pixel(i, j, temp_color)
					#if (j == size_y - 1) and (i == size_x - 1):
						#print("%s %s" % [file_path, temp_color.to_html()])
					
		elif (format_int == 555):
			#image = Image.create(size_x, size_y, false, Image.FORMAT_RGB565)
			image = Image.create(size_x, size_y, false, Image.FORMAT_RGBAF) #_RGBF
			var pixel : int
			var r : int
			var g : int
			var b : int
			for j in range(size_y):
				for i in range(size_x):
					pixel = file.get_16()
					r = 8 * (pixel & 0x1F)
					g = (pixel >> 2) & 0xF8
					b = (pixel >> 7) & 0xF8
					#image.set_pixel(i, j, Color8(r, g, b))
					image.set_pixel(i, j, Color(b / 255.0, g / 255.0, r / 255.0))
				
		elif (format_int == 4444):
			image = Image.create(size_x, size_y, false, Image.FORMAT_RGBA4444)
			#image = Image.create(size_x, size_y, false, Image.FORMAT_RGBAF)
			var pixel : int
			var r : int
			var g : int
			var b : int
			var a : int
			for j in range(size_y):
				for i in range(size_x):
					pixel = file.get_16()
					r = 0x10 * (pixel & 0xF)
					g = pixel & 0xF0
					b = (pixel >> 4) & 0xF0
					a = (pixel >> 8) & 0xF0
					image.set_pixel(i, j, Color8(b, g, r, a))
		
		else:
			LogWriter.writeErrorLogAndExit('Критическая ошибка при импорте файла "%s."' % [file_path], 'Проверьте формат изображения!/Check image format!', "error.log")
			breakpoint


	else:
		LogWriter.writeErrorLogAndExit('Критическая ошибка при импорте файла "%s."' % [file_path], 'bit=%d не поддерживается/is not supported' % [bit], "error.log")
	
	#return null
	
	#image.srgb_to_linear()
	
	if image.is_empty():
		print("img=null")
		breakpoint
		
	#else:
	#	if file_path.contains('forest1.txr'):
	#		image.save_png("h:/d2/dev/Viewer_2023/forest1.png")
	#	if file_path.contains('grass1.txr'):
	#		image.save_png("h:/d2/dev/Viewer_2023/grass1.png")
	
	#image.fix_alpha_edges()
	
	#var result : ImageTexture = ImageTexture.create_from_image(image)
	#result.create_from_image(image)
	return image #result
	
	#var txr_data : PackedByteArray = file.data_array.subarray(file.get_position(), file_size-1)
	#image.create_from_data(size_x, size_y, false, format, txr_data)
	
	#var result : ImageTexture = ImageTexture.new()
	#result.create_from_image(image)
	#return result
	
func LoadTXR_FromBuffer(buffer : StreamPeerBuffer) -> Image:
	file_path = LoaderUtils.getStr(buffer) #для отладки
	file_size = buffer.get_32()  #пропуск размера файла
	
	#LogWriter.writeToLog("%s:%d -> %d" % [file_path, file_size, buffer.get_position()], "txr.log")
	#print(file_path)
	#print(file_size)
	#print(buffer.get_position())
	#breakpoint
	var file_buffer : StreamPeerBuffer = StreamPeerBuffer.new()
	
	var data_start : int = buffer.get_position()
	var data_end : int = data_start + file_size
	
	#очень обходная технология на случай если txr в конце файла, ибо если
	#делать subarray со вторым параметром, равным длине data_array,
	#то движок не создаёт новый массив, и далее вылет из-за пустого блока данных
	#для создания текстуры
	if (data_end == len(buffer.data_array)):
		file_buffer.set_data_array(buffer.data_array.slice(data_start, data_end - 1))
	else:
		file_buffer.set_data_array(buffer.data_array.slice(data_start, data_end))
	
	if !len(file_buffer.data_array):
		print(data_end)
		print(len(buffer.data_array))
		breakpoint
	
	buffer.seek(buffer.get_position() + file_size)
	#var tex_name : String = LoaderUtils.getNameFromPath_res(tex_full_name.split(" ")[0], false)
	#print(tex_full_name)
	#print(tex_name)
	#print(buffer.get_position())
	#LogWriter.writeToLog("%s %d" % [file_path, buffer.get_position()], "test.txt")
	#breakpoint
	return LoadTXR_LoadData(file_buffer, file_size)
	
func LoadTXR_FromFile(path : String) -> Image:
	var result : Image
	
	file_path = path
	
	var txr_file : FileAccess = FileAccess.open(path, FileAccess.READ)
	
	#получение размера файла
	file_size = txr_file.get_length()

	var file : StreamPeerBuffer = StreamPeerBuffer.new()
	file.set_data_array(txr_file.get_buffer(file_size))
	txr_file.close()
	
	if file_size > 0:
		result = LoadTXR_LoadData(file, file_size)
	else:
		LogWriter.writeErrorLogAndExit('Критическая ошибка при импорте файла "%s."' % [path], 'Файл пустой!\nFile is empty!', "error.log")

	file.clear()
	file_size = 0
	
	#result.resource_name = LoaderUtils.getNameFromPath(path, false) + '.png'
	#print(result.resource_name)
	result.set_name(LoaderUtils.getNameFromPath(path, false) + '.png')
	
	return result
