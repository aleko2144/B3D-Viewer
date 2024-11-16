extends Node3D

var type : int = 23
var scene_root : Node
var LoaderUtils : Node

#var collision_type : int #тип коллизии
#var facesCount : int #количество полигонов коллизии

var vertex_data : PackedVector3Array

var need_to_be_imported : bool = false
var is_copy : bool = false

func read_CollisionFace(B3DFile) -> void:
	var vertsCount : int = B3DFile.get_32() #количество вершин
	for _j in range(vertsCount):
		vertex_data.append( LoaderUtils.getVector3Pos(B3DFile))

func LoadFromB3D(B3DFile) -> void:
	#print('%s->%s' % [self.name, B3DFile.get_position() - 4])
	B3DFile.seek(B3DFile.get_position() + 4) #var1
	var _collision_type : int = B3DFile.get_32()
	var bytes_skip : int = B3DFile.get_32()
	B3DFile.seek(B3DFile.get_position() + (bytes_skip * 4))
	#B3DFile.seek(B3DFile.get_position() + 4) #var3
	var facesCount : int = B3DFile.get_32()
	
	for _i in range(facesCount):
		read_CollisionFace(B3DFile)

func get_copy() -> Node:
	var func_exec_time : int = Time.get_ticks_msec()
	var node : Node3D = Node3D.new()
	node.name = self.name + "_copy"
	node.script = self.script
	node.is_copy = true
	node.scene_root = self.scene_root
	node.visible = self.visible
	scene_root.time_get_copy += (Time.get_ticks_msec() - func_exec_time) / 1000.0
	return node
