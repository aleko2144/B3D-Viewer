extends Node3D

var type : int = 20
var scene_root : Node
var LoaderUtils : Node

#var vertsCount : int #количество вершин
#var vertex_data : PackedVector3Array

var need_to_be_imported : bool = false
var is_copy : bool = false

func LoadFromB3D(B3DFile) -> void:
	#print('%s->%s' % [self.name, B3DFile.get_position() - 4])
	#print('20: %s->%s' % [self.name, B3DFile.get_position() - 4])

	B3DFile.seek(B3DFile.get_position() + 16) #Vector4(xyzw)
	var vertsCount : int = B3DFile.get_32()
	B3DFile.seek(B3DFile.get_position() + 8) #var3, var4
	
	for _i in range(B3DFile.get_32()): #float varX[var5]
		B3DFile.seek(B3DFile.get_position() + 4)
	
	for _i in range(vertsCount):
		B3DFile.seek(B3DFile.get_position() + 12)
		#vertex_data.append(LoaderUtils.getVector3Pos(B3DFile))
		
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
