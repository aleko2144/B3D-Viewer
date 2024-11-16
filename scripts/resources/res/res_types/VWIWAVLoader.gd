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
	
func LoadWAV_FromBuffer(buffer : StreamPeerBuffer) -> void:
	file_path = LoaderUtils.getStr(buffer) #для отладки
	file_size = buffer.get_32()
	buffer.seek(buffer.get_position() + file_size)
