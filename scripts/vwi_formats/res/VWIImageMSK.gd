class_name VWIImageMSK

var tex_name   : String
var size       : Vector2i

var image   : Image
var texture : ImageTexture

func FromBytes(buffer : StreamPeerBuffer) -> void:
	#var data_end  : int = buffer.get_position() + file_size
	
	var bit_depth : int
	var bw_color  : bool
	#var bw_mask   : bool
	#MSK8       MS16       MSKR        MASK
	#944460621  909202253  1380668237  1263747405
	var mark_str : String = buffer.get_utf8_string(4)
	buffer.seek(buffer.get_position() - 4)
	var mark : int = buffer.get_u32()

	match mark:
		1263747405: #'MASK':
			bit_depth = 8
			bw_color = false
			#bw_mask = false
		944460621: #'MSK8':
			bit_depth = 8
			bw_color = false
			#bw_mask = true
		909202253: #'MS16':
			bit_depth = 16
			bw_color = false
		1380668237: #'MSKR': #circ.rmp/msk/drop7.msk
			bit_depth = 8
			bw_color = true
		_:
			LogWriter.writeErrorLog('Неизвестный формат MSK!/Unknown MSK format! (%s -> %s)' % [tex_name, mark_str], true)

	#размер картинки
	size.x = buffer.get_u16()
	size.y = buffer.get_u16()
	
	var total_cnt : int = size.x * size.y
	var pixel_cnt : int = 0
	
	#print(size)
	var temp_image : Image = Image.new()
	temp_image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	
	var temp_idx : int
	var pixel : int 
	var pix_pos : Vector2i
	
	if bit_depth == 8:
		#если bw_color, то палитра пустая
		var palette : PackedVector3Array
		if (!bw_color):
			for n in range(256):
				palette.append(Vector3i(buffer.get_u8(), buffer.get_u8(), buffer.get_u8()))
		else:
			buffer.seek(buffer.get_position() + 768)
		
		while (pixel_cnt < total_cnt):
			temp_idx = buffer.get_u8()
			if (temp_idx < 128):
				for i in range(temp_idx):
					pixel = buffer.get_u8()
					@warning_ignore("integer_division")
					pix_pos.y = pixel_cnt / size.x
					pix_pos.x = pixel_cnt - (pix_pos.y * size.x)
					
					if (!bw_color):
						#r = palette[pixel].x #g = palette[pixel].y #b = palette[pixel].z
						@warning_ignore("narrowing_conversion")
						temp_image.set_pixel(pix_pos.x, pix_pos.y, Color.from_rgba8(palette[pixel].x, palette[pixel].y, palette[pixel].z))
					else:
						#r = pixel #g = pixel #b = pixel
						temp_image.set_pixel(pix_pos.x, pix_pos.y, Color.from_rgba8(pixel, pixel, pixel, 255 - pixel))
					pixel_cnt += 1
			else:
				for i in range(temp_idx - 128):
					temp_image.set_pixel(pix_pos.x, pix_pos.y, Color(0, 0, 0, 0))
					pixel_cnt += 1
	else:
		buffer.seek(buffer.get_position() + 768)
		while (pixel_cnt < total_cnt):
			temp_idx = buffer.get_u8()
			if (temp_idx < 128):
				for i in range(temp_idx):
					pixel = buffer.get_u16()
					@warning_ignore("integer_division")
					pix_pos.y = pixel_cnt / size.x
					pix_pos.x = pixel_cnt - (pix_pos.y * size.x)

					#r = 8 * (pixel & 0x1F) #g = g = (pixel >> 3) & 0xFC #b = (pixel >> 8) & 0xF8
					temp_image.set_pixel(pix_pos.x, pix_pos.y, Color.from_rgba8( ((pixel >> 8) & 0xF8), ((pixel >> 3) & 0xFC), (8 * (pixel & 0x1F)), 255))
					pixel_cnt += 1
			else:
				for i in range(temp_idx - 128):
					temp_image.set_pixel(pix_pos.x, pix_pos.y, Color(0, 0, 0, 0))
					pixel_cnt += 1

	image = temp_image
	texture = ImageTexture.create_from_image(image)
	
	#print(tex_name)
	if (!image.is_empty()):
		image.save_png("g:\\dev\\htruck_godot\\CIRCUIT_masks\\%s.png" % [tex_name])
	#	loader.test_iter += 1
