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
	
func LoadPLM_LoadData(buffer : StreamPeerBuffer, link_to : Node) -> void:
	buffer.seek(12) #сразу к количеству элементов
	var colorsCount : int = buffer.get_32()
	#print(colorsCount)
	@warning_ignore("integer_division", "integer_division")
	for _i in range(colorsCount / 3):
		link_to.palette_data_array.append(LoaderUtils.getColorInt8(buffer))
	
func LoadPLM_FromBuffer(buffer : StreamPeerBuffer, link_to : Node) -> void:
	file_path = LoaderUtils.getStr(buffer) #для отладки
	file_size = buffer.get_32()
	
	var PLM_data : StreamPeerBuffer = StreamPeerBuffer.new()
	PLM_data.set_data_array(buffer.data_array.slice(buffer.get_position(), buffer.get_position() + file_size))
	
	LoadPLM_LoadData(PLM_data, link_to)
	
	buffer.seek(buffer.get_position() + file_size)
	
	#print(file_path)
	#print(file_size)
	#breakpoint
	
func LoadPLM_FromFile(path : String, link_to : Node) -> void:
	file_path = path
	
	var plm_file : FileAccess = FileAccess.open(path, FileAccess.READ)
	
	#получение размера файла
	plm_file.seek_end(0)
	file_size = plm_file.get_position()
	plm_file.seek(0)

	var file_buffer : StreamPeerBuffer = StreamPeerBuffer.new()
	file_buffer.set_data_array(plm_file.get_buffer(file_size))
	plm_file.close()
	
	if file_size > 0:
		LoadPLM_LoadData(file_buffer, link_to)
	else:
		LogWriter.writeErrorLogAndExit('Критическая ошибка при импорте файла "%s."' % [path], 'Файл пустой!\nFile is empty!', "error.log")

	file_size = 0
