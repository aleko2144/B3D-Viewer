class_name B3D_Type01 extends B3D_Object

var start_space_name : String
var start_room_name  : String

var start_space : Node3D
var start_room  : Node3D

func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 1
	start_space_name = LoaderUtils.readString32(buffer, false)
	start_room_name  = LoaderUtils.readString32(buffer, false)

func initialize() -> void:
	start_space = sceneRoot.searchSceneObject(start_space_name)
	start_room  = sceneRoot.searchSceneObject(start_room_name)
