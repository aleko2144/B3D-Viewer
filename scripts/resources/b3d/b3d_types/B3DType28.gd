extends Node3D

var type : int = 28
var scene_root : Node
var LoaderUtils : Node

var need_to_be_imported : bool = false
var is_copy : bool = false

func LoadFromB3D(B3DFile) -> void:
	B3DFile.seek(B3DFile.get_position() + 16) #Vector4(xyzw)
	B3DFile.seek(B3DFile.get_position() + 12) #float(3)
	
	for _i in range(B3DFile.get_32()):
		var format : int = B3DFile.get_32() #формат блока
		var inter_format : int = format ^ 1
		B3DFile.seek(B3DFile.get_position() + 12) #float, int32 32767, mtlNum

		for _j in range(B3DFile.get_32()):
			B3DFile.seek(B3DFile.get_position() + 8) #X, Y
			#далее доп. параметры
			if (inter_format & 2): #UV
				#индивидуальная UV данной вершины этого спрайта
				B3DFile.seek(B3DFile.get_position() + 8) #U, V

#			if (inter_format & 0x10): #FACE_HAS_INTENCITY
#				if (inter_format & 0x1): #FACE_INTENCITY_VECTOR
#					if (inter_format & 0x20 or format == 24):
#						#print("has intensity vector")
#						B3DFile.seek(B3DFile.get_position() + 12)
#				elif (inter_format & 0x20):
#					#print("has intensity float")
#					B3DFile.seek(B3DFile.get_position() + 4)
	
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
