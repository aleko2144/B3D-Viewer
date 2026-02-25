class_name B3D_Type28 extends B3D_Object

var numStructs : int
var numVerts   : int
var vertices   : Array
var format     : int
var inter_format : int
#var vertices : PackedVector3Array
#var UV       : PackedVector2Array

func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 28

	buffer.seek(buffer.get_position() + 16) #Vector4(xyzw)
	buffer.seek(buffer.get_position() + 12) #float(3)
	
	numStructs = buffer.get_u32()
	
	for _i in range(numStructs):
		format       = buffer.get_32() #формат блока
		inter_format = format ^ 1
		buffer.seek(buffer.get_position() + 12) #float, int32 32767, mtlNum
		numVerts     = buffer.get_u32()
		for _j in range(numVerts):
			buffer.seek(buffer.get_position() + 8) #X, Y
			#далее доп. параметры
			if (inter_format & 2): #UV
				#индивидуальная UV данной вершины этого спрайта
				buffer.seek(buffer.get_position() + 8) #U, V
	
	#buffer.seek(buffer.get_position() + 4) #child obj cnt
