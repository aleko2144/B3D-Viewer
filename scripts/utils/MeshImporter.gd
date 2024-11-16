extends Node

@onready var LoaderUtils : Node = get_parent()

class VWIFaceData:
	var type : int
	var mtlIndex : int
	var useOwnUV : bool
	var vertsCount : int
	var vertsInd : Array
	var vertsUV : Array
	var intensityVectors : Array
	var useIntensityVector : bool
	var data_offset : int
	
var surfaces : Array

func addDataToArray(new_data : VWIFaceData) -> void:
	for data in surfaces:
		if data[0] == new_data.mtlIndex:
			if data[1] == new_data.type:
				data[2].append(new_data)
				return

	#если блока такого типа в массиве нет
	surfaces.append([new_data.mtlIndex, new_data.type, [new_data]])

func read_IndexData(B3DFile : StreamPeerBuffer) -> void:
	var faceData : VWIFaceData = VWIFaceData.new()
	faceData.data_offset = B3DFile.get_position()
	faceData.type = B3DFile.get_32() #формат блока
	
	var inter_format : int = faceData.type ^ 1
	B3DFile.seek(B3DFile.get_position() + 8) #float, int32 32767
	
	faceData.mtlIndex = B3DFile.get_32()
	faceData.vertsCount  = B3DFile.get_32()

	for _j in range(faceData.vertsCount):
		faceData.vertsInd.append(B3DFile.get_32())
		#далее доп. параметры
		
		if (inter_format & 2): #UV
			#индивидуальная UV данной вершины этого полигона
			faceData.vertsUV.append(LoaderUtils.getVector2(B3DFile))
			faceData.useOwnUV = true

		if (inter_format & 0x10): #FACE_HAS_INTENCITY
			if (inter_format & 0x1): #FACE_INTENCITY_VECTOR
				if (inter_format & 0x20 or faceData.type == 24):
					#print("has intensity vector")
					faceData.intensityVectors.append(LoaderUtils.getVector3(B3DFile))
					faceData.useIntensityVector = true
			elif (inter_format & 0x20):
				#print("has intensity float")
				B3DFile.seek(B3DFile.get_position() + 4)
				
	addDataToArray(faceData)

func LoadIndexes(B3DFile : StreamPeerBuffer, data_count : int): # -> Mesh:
	surfaces.clear()
	
	for i in range(data_count):
		read_IndexData(B3DFile)
