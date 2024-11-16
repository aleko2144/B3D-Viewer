extends Node

var Root : Node
var LogWriter : Node
var LoaderUtils : Node

func reload():
	Root = get_tree().get_root().get_child(0)
	LogWriter = Root.LogWriter
	LoaderUtils = Root.LoaderUtils

#https://www.reddit.com/r/godot/comments/l8ximk/translate_a_base_10_number_into_a_binary_number/
#by JDude13
func intToBin(num : int) -> String:
	var result : String
	#print("n=%d" % [num])
	#while num > 0:
	#	result = String(num & 1) + result
	#	num = num >>1
	#print(result)
	#breakpoint
	return result

func UnMask(num : int):
	var bits : Array
	var bits_str : String = intToBin(num)
	for c in bits_str:
		bits.append(int(c))
	#int(digit) for digit in bin(num)[2:]]
	var left_zeros : int = 0
	var right_zeros = 0
	var ones = 0
	if num == 0:
		return [0, 0, 0]
	for bit in bits:
		if bit:
			ones+=1
		else:
			right_zeros+=1
		left_zeros = 16 - len(bits)
	return [left_zeros, ones, right_zeros]

func convertToTGA(image_start_offset : int, size_x : int, size_y : int, file : StreamPeerBuffer, file_path : String):
	var result : PackedByteArray
	var LOFF_offset : int = file.get_position()
	
	#file.seek(image_start_offset)
	file.data_array[image_start_offset] = 0
	file.data_array[image_start_offset + 7] = 0 #20
	file.data_array[image_start_offset + 16] = 32
	
	result = file.data_array.slice(image_start_offset, image_start_offset + 17)
	#print(result)
	#breakpoint
	#var image_start_offset : int = file.get_position()
	#var idSize : int = file.get_8()
	#file.seek(file.get_position() + 12) #11
	
	file.seek(LOFF_offset + 12) #LOFF
		
	var colors : Array = []
	var colors_new : Array = []
	var PFRM_masks : Array = []
	var PFRM_masks_modified : Array = []
		
	for _i in range(size_x * size_y * 2):
		colors.append(file.get_8())
			
	#FORMAT_RGBA4444
	#FORMAT_RGBA5551
	#image.create_from_data(size_x, size_y, false, Image.FORMAT_RGBA4444, colors) #5/6

	#пропуск PFRM и LVMP
	while (true):
		var id = file.get_32()
		var length = file.get_32()
		if (id == 1347245644): #LVMP
			file.seek(file.get_position() + length + 2)
			#print("LVMP")
		elif (id == 1297237584): #PFRM
			#var PFRM_start : int = file.get_position()
				
			for k in range(4):
				PFRM_masks.append(file.get_32())
				PFRM_masks_modified.append(UnMask(PFRM_masks[k]))
					
			file.seek(file.get_position() + (length - 16))

			#print(PFRM_masks)
			#print(PFRM_masks_modified)
				
			#file.seek(file.get_position() + length)
			#print("PFRM")
				
			var temp_color : Array = [0, 0, 0, 0]
				
			for color in colors:
				temp_color[0] = ((color & PFRM_masks[0]) >> PFRM_masks_modified[0][2]) << (8 - PFRM_masks_modified[0][1])
				temp_color[1] = ((color & PFRM_masks[1]) >> PFRM_masks_modified[1][2]) << (8 - PFRM_masks_modified[1][1])
				temp_color[2] = ((color & PFRM_masks[2]) >> PFRM_masks_modified[2][2]) << (8 - PFRM_masks_modified[2][1])
					
				if (PFRM_masks_modified[3][1]):
					temp_color[3] = ((color & PFRM_masks[3]) >> PFRM_masks_modified[3][2]) << (8 - PFRM_masks_modified[3][1])
				else:
					if (temp_color[0] | temp_color[1] | temp_color[2]):
						temp_color[3] = 0b11111111
					else:
						temp_color[3] = 0
				colors_new.append([temp_color[2], temp_color[1], temp_color[0], temp_color[3]])
				
			#var_to_bytes()
				
		elif (id == 1380208197): #ENDR
			print("ENDR")
			break
		else:
			LogWriter.writeErrorLog('Критическая ошибка при импорте файла "%s."' % [file_path], 'Неизвестная секция в TXR!\nUnknown section in TXR!\n(%d)' % [id], "error.log")
			file.seek(file.get_position() - 4)
			break
