extends Node

var Root : Node
var LogWriter : Node
var LoaderUtils : Node

var load_percent : float #насколько прочитан файл

func reload():
	Root = get_tree().get_root().get_child(0)
	LogWriter = Root.LogWriter
	LoaderUtils = Root.LoaderUtils
	$PROImporter.reload()
	$RMPImporter.reload()
	$TXRLoader.reload()
	$MSKLoader.reload()
	$MTLLoader.reload()
	$PLMLoader.reload()
	$WAVLoader.reload()
	
func MakeImageTransparent(image : Image, color : Color) -> Image:
	var size : Vector2i = image.get_size()
	var result : Image = image
	var color_converted : Color
	#var result : Image = Image.create(size.x, size.y, false, Image.FORMAT_RGBAH)
	#var result : Image = Image.create(size.x, size.y, false, Image.FORMAT_RGBAF)
	
	for i in range(size.y):
		for j in range(size.x):
			var img_pixel : Color = result.get_pixel(i, j)
			#if (img_pixel == color):
			
			#print("%s %s" % [color, img_pixel])
			##(0.1882, 0.2196, 0.0627, 1) (0.1961, 0.2314, 0.0706, 1)##
			
			#  цвет из common.plm[256]     цвет на forest1.txr (ap)
			#  оригиналы:  50 59 18               48 56 16
			#(0.1961, 0.2314, 0.0706, 1) (0.1882, 0.2196, 0.0627, 1)
			#if (image.get_format() == Image.FORMAT_RGBAF): #если RGB565 ДБ2
			if (image.get_format() != Image.FORMAT_RGBF): #если RGB565 ДБ2
				#если col 256 - цвет прозрачности деревьев
				
				#48 56 16 50 59 18
				#var str1 : String = "%d %d %d" % [img_pixel.r8, img_pixel.g8, img_pixel.b8]
				#var str2 : String = "%d %d %d" % [color.r8, color.g8, color.b8]
				#print(str1 + " " + str2)

				var tex8 : Array = [img_pixel.r8, img_pixel.g8, img_pixel.b8]
				var color8 : Array = [color.r8, color.g8, color.b8]
		
				if color8[0] > 0:
					color8[0] -= 2
					color8[1] -= 3 #2
					color8[2] -= 2
					
				#var str1 : String = "%d %d %d" % [tex8[0], tex8[1], tex8[2]]
				#var str2 : String = "%d %d %d" % [color8[0], color8[1], color8[2]]
				#print(str1 + " " + str2)
					
				if tex8[0] == color8[0] and tex8[1] == color8[1] and tex8[2] == color8[2]:
					img_pixel.a = 0

				#if (color.r8 > 45 and color.g8 > 54 and color.b8 > 12):
				#	color_converted.r = color.r * 0.9597144314125446
				#	color_converted.g = color.g * 0.9490060501296456
				#	color_converted.b = color.b * 0.8881019830028329
					
					#color_converted.r = color.r * 0.95
					#color_converted.g = color.g * 0.94
					#color_converted.b = color.b * 0.88
					
					#print("test")
					#print("%s %s" % [color, img_pixel])
					
					#print("%s %s" % [color_converted, img_pixel])
					
					#var accuracy : Color = Color(0.0001, 0.0001, 0.0001)
					#var accuracy : Color = Color(0.00005, 0.00005, 0.00005) уже красиво
					#var accuracy : Color = Color(0.000035, 0.000035, 0.000035)
					#var accuracy : float = 0.000035
					#if (LoaderUtils.compareColors(img_pixel, color_converted, accuracy)):
					
					#if (img_pixel == color):
					#	img_pixel.a = 0
				
				#else:
				#	if (img_pixel == color):
				#		img_pixel.a = 0
				#if (img_pixel == color_converted):
				#	img_pixel.a = 0
				#if (color.r > 0.05):
				#	print("%s %s" % [img_pixel, color])
					
			#if (img_pixel == color):
			#if (LoaderUtils.compareColors(img_pixel, color, 0.01)):
			else:
				if (img_pixel == color):
					#0.00005 при r += 2
					#при accuracy = 0.005 уже дырки в текстурах
					#print("%s %s" % [color, img_pixel])
					img_pixel.a = 0
			result.set_pixel(i, j, img_pixel)
			
	return result
	
func SetImageTexture(image_index : int, link_to : Node):
	var result : Image = link_to.textures_array[image_index - 1]
		
	if (result):
		return result
	else:
		LogWriter.writeErrorLog('FATAL ERROR: RESImporter::setImageTexture(%d)' % [image_index], 'There is NO "%d" image in module "%s"!' % [image_index, link_to.name], "error.log")

func SetColor(color_index : int, link_to : Node) -> Color:
	#если есть палитра, то брать цвет с неё
	#если ДБ2, то каждому модулю ставить палитру из common
	#print("col=%d | plm=%d" % [len(link_to.colors_array), len(link_to.palette_data_array)])
	if get_parent().VWIVersion == 1:
		if (!len(link_to.palette_data_array)):
			return link_to.colors_array[color_index - 1]
		else:
			return link_to.palette_data_array[color_index - 1]
	else:
		var module_common : Node = link_to.get_parent().get_node("common")
		if module_common:
			return module_common.palette_data_array[color_index - 1]
		else:
			return Color(1, 1, 1, 1)

func ImportRES(res_path : String, link_to : Node) -> float:
	var res_path_orig : String = res_path
	var res_dir : String = LoaderUtils.getPathWithoutFile(res_path)
	var load_variant : int
	
	res_path = res_path.left(len(res_path) - 3)
	
	if LoaderUtils.isFileExists(res_path + "pro"):
		res_path += "pro"
		load_variant = 1
	elif LoaderUtils.isFileExists(res_path + "res"):
		res_path += "res"
		load_variant = 2
	elif LoaderUtils.isFileExists(res_path + "rmp"):
		res_path += "rmp"
		load_variant = 2
	else:
		LogWriter.writeErrorLogAndExit('Критическая ошибка при импорте файла "%s."' % [res_path_orig], 'Файл ресурсов не найден!\nResources file is not found!\n!*.pro/*.res/*.rmp', "error.log")
	
	#print("VWIRESLoader::ImportRES(%s)" % [res_path])
	
	var timeStart : int = Time.get_ticks_msec()
	
	$TXRLoader.reload()
	
	if load_variant == 1:
		$PROImporter.ImportResources(res_dir, res_path, link_to)
	else:
		$RMPImporter.ImportResources(res_path, link_to)
	
	#LogWriter.writeToLog('"%s" был загружен за %.1f сек.' % [LoaderUtils.getNameFromPath(res_path, true), (Time.get_ticks_msec() - timeStart) / 1000.0], "stats.log")
	
	return (Time.get_ticks_msec() - timeStart) / 1000.0
