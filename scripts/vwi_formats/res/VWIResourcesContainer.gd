class_name VWIResourcesContainer

var palette    : VWIPalette
var colors     : Array
#var effects   : Array #only in htruck1
var textures   : Array
var backfiles  : Array
var maskfiles  : Array
var soundfiles : Array

var materials : Array
var sounds    : Array

var colors_cnt     : int
var textures_cnt   : int
var backfiles_cnt  : int
var masks_cnt      : int
var materials_cnt  : int
var soundfiles_cnt : int
var sounds_cnt     : int

#materials and sounds sections as strings array
var mtl_str_array : Array
var snd_str_array : Array

func readColors(buffer : StreamPeerBuffer, count : int) -> void:
	colors_cnt = count
	for i in range(count):
		LoaderUtils.readString(buffer)
		
func readPalette(buffer : StreamPeerBuffer) -> void:
	#print(buffer.get_position())
	#breakpoint
	var _plm_name : String = LoaderUtils.readString(buffer) #palette file name
	var _plm_size : int    = buffer.get_u32()
	
	var temp_palette : VWIPalette = VWIPalette.new()
	temp_palette.FromBytes(buffer)
	palette = temp_palette
	
func readSoundFiles(buffer : StreamPeerBuffer, count : int) -> void:
	soundfiles_cnt = count
	for i in range(count):
		var _snd_name : String = LoaderUtils.readString(buffer)
		var snd_size : int    = buffer.get_u32()
		buffer.seek(buffer.get_position() + snd_size)
		
func readSounds(buffer : StreamPeerBuffer, count : int) -> Array: #void:
	sounds_cnt = count
	var temp_array : Array
	for i in range(count):
		temp_array.append(LoaderUtils.readString(buffer))
		
	return temp_array
		
func readMasks(buffer : StreamPeerBuffer, count : int) -> void:
	masks_cnt = count
	for i in range(count):
		var msk_name : String = LoaderUtils.readString(buffer)
		var msk_size : int    = buffer.get_u32()
		#buffer.seek(buffer.get_position() + msk_size)
		##############################################
		var mask : VWIImageMSK = VWIImageMSK.new()
		mask.tex_name = msk_name.split(' ')[0]
		mask.FromBytes(buffer)
		maskfiles.append(mask)
		
func readTextures(buffer : StreamPeerBuffer, count : int, applyToBackfiles : bool) -> void:
	if (!applyToBackfiles):
		textures_cnt = count
	else:
		backfiles_cnt = count

	for i in range(count):
		#var prev_tex : VWIImageTXR
		#if (!applyToBackfiles and i > 3):
		#	prev_tex = textures[len(textures) - 1]
		#	prev_tex.image.save_png('..\\_test\\%s.png' % prev_tex.tex_name)
			
		var txr_name : String = LoaderUtils.readString(buffer)
		var txr_size : int    = buffer.get_u32()
		var txr : VWIImageTXR = VWIImageTXR.new()
		txr.tex_name = txr_name.split(' ')[0]
		txr.FromBytes(buffer, txr_size)
		
		if (!applyToBackfiles):
			textures.append(txr)
		else:
			backfiles.append(txr)
			
func readMaterials(buffer : StreamPeerBuffer, count : int) -> Array: #void:
	materials_cnt = count
	var temp_array : Array
	for i in range(count):
		temp_array.append(LoaderUtils.readString(buffer))
		
	return temp_array
		
func initMaterials(mtl_str_arr : Array) -> void:
	for mtl_str in mtl_str_arr:
		var mtl : VWIMaterial = VWIMaterial.new()
		mtl.FromString(mtl_str, self)
		materials.append(mtl)

func FromBytes(buffer : StreamPeerBuffer, file_size : int) -> void:
	var load_start_time : int = Time.get_ticks_msec()
	var temp_start_time : int
	
	#buffer.seek(buffer.get_position() + 12)
	while (buffer.get_position() < file_size):
		var section_line : PackedStringArray = LoaderUtils.readString(buffer).split(' ')
		var section_name : String = section_line[0]
		var items_count : int = int(section_line[1])
		
		#var pos_in_file : int = buffer.get_position()
		
		match section_name:
			'COLORS':
				temp_start_time = Time.get_ticks_msec()
				readColors(buffer, items_count)
				print('colors (%d): %.3f sec' % [items_count, (Time.get_ticks_msec() - temp_start_time) / 1000.0])
			'PALETTEFILES':
				temp_start_time = Time.get_ticks_msec()
				readPalette(buffer)
				print('palletefiles: %.3f sec' % [(Time.get_ticks_msec() - temp_start_time) / 1000.0])
			'SOUNDFILES':
				temp_start_time = Time.get_ticks_msec()
				readSoundFiles(buffer, items_count)
				print('soundfiles (%d): %.3f sec' % [items_count, (Time.get_ticks_msec() - temp_start_time) / 1000.0])
			'SOUNDS':
				temp_start_time = Time.get_ticks_msec()
				snd_str_array = readSounds(buffer, items_count)
				print('sounds (%d): %.3f sec' % [items_count, (Time.get_ticks_msec() - temp_start_time) / 1000.0])
			'MASKFILES':
				temp_start_time = Time.get_ticks_msec()
				readMasks(buffer, items_count)
				print('maskfiles (%d): %.3f sec' % [items_count, (Time.get_ticks_msec() - temp_start_time) / 1000.0])
			'TEXTUREFILES':
				temp_start_time = Time.get_ticks_msec()
				readTextures(buffer, items_count, false)
				print('texturefiles (%d): %.3f sec' % [items_count, (Time.get_ticks_msec() - temp_start_time) / 1000.0])
			'BACKFILES':
				temp_start_time = Time.get_ticks_msec()
				readTextures(buffer, items_count, true)
				print('backfiles (%d): %.3f sec' % [items_count, (Time.get_ticks_msec() - temp_start_time) / 1000.0])
			'MATERIALS':
				temp_start_time = Time.get_ticks_msec()
				mtl_str_array = readMaterials(buffer, items_count)
				print('materials (%d): %.3f sec' % [items_count, (Time.get_ticks_msec() - temp_start_time) / 1000.0])
			_:
				breakpoint
		"""
			#'EFFECTS'
		"""
	#init mtl and snd
	initMaterials(mtl_str_array)
	#initSounds(snd_str_array)
	var total_import_time : float = (Time.get_ticks_msec() - load_start_time) / 1000.0
	LogWriter.writeOutputLog('RES imported in %.3fs' % [total_import_time])

func getTextureByName(tex_name : String):
	#print(tex_name)
	for txr in textures:
		#print(txr.tex_name)
		if txr.tex_name == tex_name:
			return txr.texture
			
func getMaskByName(msk_name : String):
	#print(tex_name)
	for msk in maskfiles:
		#print(txr.tex_name)
		if msk.tex_name == msk_name:
			return msk.texture

func getTextureByIndex(idx : int) -> ImageTexture:
	if idx <= textures_cnt:
		return textures[idx - 1].texture
	return ImageTexture.new()

func getMaskByIndex(idx : int) -> ImageTexture:
	if idx <= masks_cnt:
		return maskfiles[idx - 1].texture
	return ImageTexture.new()
	
func getMaterialByIndex(idx : int) -> ShaderMaterial:
	if idx < materials_cnt:
		return materials[idx].material
	return ShaderMaterial.new()
	
func getMaterialByName(search_name : String) -> ShaderMaterial:
	for mtl in materials:
		#print('%s -> %s' % [search_name, mtl.mtl_name])
		if mtl.mtl_name == search_name:
			return mtl.material
	return ShaderMaterial.new()
	
func getColorByIndex(idx : int) -> Color:
	if (palette):
		return palette.getColorByIndex(idx - 1)
	return Color(0, 0, 0)
