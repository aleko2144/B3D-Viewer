class_name LoaderUtils

static func File2Buffer(file_path : String) -> StreamPeerBuffer:
	if (not FileAccess.file_exists(file_path)):
		var alertMsg : String = 'File2Buffer: File "%s" does not exist!' % file_path
		LogWriter.writeErrorLog(alertMsg, true)
		return
	
	var file : FileAccess = FileAccess.open(file_path, FileAccess.READ)
	#получение размера файла
	file.seek_end(0)
	var file_size : int = file.get_position()
	file.seek(0)
	
	if !file_size:
		var alertMsg : String = 'File2Buffer: File "%s" is empty!' % file_path
		LogWriter.writeErrorLog(alertMsg, true)

	var buffer : StreamPeerBuffer = StreamPeerBuffer.new()
	buffer.set_data_array(file.get_buffer(file_size))
	file.close()
	
	return buffer
	#buffer.clear()

static func readString(buffer : StreamPeerBuffer) -> String:
	var str_array : PackedByteArray

	while (true):
		var temp_byte : int = buffer.get_u8()
		str_array.append(temp_byte)
		if !temp_byte or temp_byte == 13: #null or new line
			break
		
	var result : String = str_array.get_string_from_utf8()
	return result

#func getStr32(BinFile : StreamPeerBuffer) -> String:
#	var str_array : PackedByteArray = BinFile.data_array.slice(BinFile.get_position(), BinFile.get_position() + 32)
#	BinFile.seek(BinFile.get_position() + 32)
#	var result : String = str_array.get_string_from_utf8()
#	if result.is_empty():
#		return "object_%d" % [BinFile.get_position() - 40]
#	return result
	
static func readString32(buffer : StreamPeerBuffer, dontAllowEmpty : bool) -> String:
	var str_array : PackedByteArray = buffer.data_array.slice(buffer.get_position(), buffer.get_position() + 32)
	buffer.seek(buffer.get_position() + 32)
	var result : String = str_array.get_string_from_utf8()
	if result.is_empty():
		if (dontAllowEmpty):
			result = "object_%d" % [buffer.get_position() - 40]
		else:
			result = ""
	return result
