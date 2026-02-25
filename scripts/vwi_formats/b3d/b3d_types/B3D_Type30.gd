class_name B3D_Type30 extends B3D_Object

var door_pos  : Vector3
var door_w    : float
var door_room : String
var door_pnt1 : Vector3
var door_pnt2 : Vector3

var room_node : Node3D

func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 30
	is_door = true
	
	door_pos  = VectorUtils.LoadXZYVec3FromBuffer(buffer)
	door_w    = buffer.get_float()
	door_room = LoaderUtils.readString32(buffer, false)
	door_pnt1 = VectorUtils.LoadXZYVec3FromBuffer(buffer)
	door_pnt2 = VectorUtils.LoadXZYVec3FromBuffer(buffer)

func initialize() -> void:
	room_node = sceneRoot.searchSceneObject(door_room)
