class_name VWIImageTXR

var tex_name : String
var tex_pixels : Array
var size       : Vector2i

var use_mipmaps : bool
var image   : Image
var texture : ImageTexture

func LoadTXR_GetPRFM(file : StreamPeerBuffer) -> Array:
	var original_offset = file.get_position() + 12 #пропуск LOFF
	var id : int = file.get_32()
	var offset : int
	
	#LOFF
	if id != 1179012940:
		LogWriter.writeErrorLog('Нет секции LOFF после заголовка TXR!\nLOFF section is not defined after TXR header!\n(%s -> %d)' % [tex_name, id], true)
	
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
		LogWriter.writeErrorLog('Неизвестная секция в TXR!\nUnknown section in TXR!\n(%s -> %d)' % [tex_name, id], true)
	
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
			LogWriter.writeErrorLog('Формат текстуры не поддерживается/texture format is not supported (%s)' % [tex_name], true)
			return 0 #"unsupported"
		else:
			#bump 4444
			return 4444
		
	return 0 #"unsupported"

var data_start : int 
var data_end   : int 

var LOFF_ptr   : int
var PRFM_ptr   : int
var LVMP_ptr   : int

func scanSections(buffer : StreamPeerBuffer) -> void:
	var start_pos : int = buffer.get_position()
	while (buffer.get_position() < data_end):
		var section_id : int = buffer.get_u32()
		#print(section_id)
		match section_id:
			1179012940: #LOFF
				LOFF_ptr = buffer.get_position()
				buffer.seek(buffer.get_position() + 4)
				buffer.seek(data_start + buffer.get_u32())
			1347245644: #LVMP
				LVMP_ptr = buffer.get_position()
				buffer.seek(buffer.get_position() + buffer.get_u32() + 2)
			1297237584: #PRFM
				PRFM_ptr = buffer.get_position()
				buffer.seek(buffer.get_position() + buffer.get_u32())
			_:
				break
	
	buffer.seek(start_pos)

func FromBytes(buffer : StreamPeerBuffer, file_size : int) -> void:
	data_start = buffer.get_position()
	data_end   = buffer.get_position() + file_size
	buffer.seek(buffer.get_position() + 12)
	#размер картинки
	size.x = buffer.get_u16()
	size.y = buffer.get_u16()
	
	#остальная информация
	var bit_depth : int = buffer.get_u8() #битность картинки
	buffer.seek(buffer.get_position() + 1)

	if !bit_depth:
		breakpoint

	var temp_image : Image = Image.new()
	scanSections(buffer)
	
	if bit_depth == 8:
		#загрузить как обычный tga
		temp_image.load_tga_from_buffer(buffer.data_array.slice(data_start, data_end))
		temp_image.srgb_to_linear()
		
		#if (tex_name == 'txr\\road_71.txr'):
		#	breakpoint
		
		if (LVMP_ptr):
			temp_image.generate_mipmaps()
			#print(tex_name)
		
	elif bit_depth == 16:
		#use_mipmaps = false
		var format_int : int = LoadTXR_GetImageFormat(buffer)

		#если 4444, то прочитать и создать своим кодом, иначе - встроенным в Годо
		if (format_int == 565):
			#temp_image = Image.create(size.x, size.y, false, Image.FORMAT_RGB565) #_RGBF
			temp_image = Image.create(size.x, size.y, use_mipmaps, Image.FORMAT_RGB565) #_RGBF
			var pixel : int
			var r : int
			var g : int
			var b : int
			for j in range(size.y):
				for i in range(size.x):
					pixel = buffer.get_u16()
					r = 8 * (pixel & 0x1F)
					g = (pixel >> 3) & 0xFC
					b = (pixel >> 8) & 0xF8
					
					tex_pixels.append(Vector4i(b, g, r, 255))
					temp_image.set_pixel(i, j, Color8(b, g, r))
					
		elif (format_int == 555):
			temp_image = Image.create(size.x, size.y, false, Image.FORMAT_RGB565)
			var pixel : int
			var r : int
			var g : int
			var b : int
			for j in range(size.y):
				for i in range(size.x):
					pixel = buffer.get_u16()
					r = 8 * (pixel & 0x1F)
					g = (pixel >> 2) & 0xF8
					b = (pixel >> 7) & 0xF8
					#image.set_pixel(i, j, Color8(r, g, b))
					tex_pixels.append(Vector4i(b, g, r, 255))
					temp_image.set_pixel(i, j, Color8(b, g, r))
				
		elif (format_int == 4444):
			temp_image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA4444)
			var pixel : int
			var r : int
			var g : int
			var b : int
			var a : int
			for j in range(size.y):
				for i in range(size.x):
					pixel = buffer.get_u16()
					r = 0x10 * (pixel & 0xF)
					g = pixel & 0xF0
					b = (pixel >> 4) & 0xF0
					a = (pixel >> 8) & 0xF0
					a += 15 #костыль
					tex_pixels.append(Vector4i(b, g, r, a))
					temp_image.set_pixel(i, j, Color8(b, g, r, a))
		else:
			LogWriter.writeErrorLog('Проверьте формат изображения!/Check image format! (%s)' % [tex_name], true)
	else:
		LogWriter.writeErrorLog('bit_depth=%d не поддерживается/is not supported (%s)' % [bit_depth, tex_name], true)
	
	if temp_image.is_empty():
		print("img=null")
		breakpoint
	#print(tex_pixels)
	image = temp_image
	texture = ImageTexture.create_from_image(image)
	#print(buffer.get_position())
	buffer.seek(data_end)
