extends MeshInstance3D

var type : int = 35
var scene_root : Node
var LoaderUtils : Node

var object_position : Vector3
var object_radius : float

var need_to_be_imported : bool = true
var is_copy : bool = false

var meshType  : int #тип меша (1 - разрывная UV, 3 - обычная)
var mtlIndex  : int #индекс материала
var dataCount : int #кол-во блоков данных

var verts_node : Node #блок с данными вершин

var offset : int

class VWIFaceData:
	var type : int
	#var mtlIndex : int
	var useOwnUV : bool
	var vertsCount : int
	var vertsInd : Array
	var vertsUV : Array
	var intensityVectors : Array
	var useIntensityVector : bool
	var data_offset : int
	
var surfaces : Array
#поверхности по типу, внутри массивы по номеру материала
#[ type:int ][ data:VWIFaceData[] ]

func addDataToArray(new_data : VWIFaceData) -> void:
	for data in surfaces:
		if data[0] == new_data.type: #mtlIndex
			data[1].append(new_data)
			return

	#если блока такого типа в массиве нет
	surfaces.append([new_data.type, [new_data]])

func read_IndexData(B3DFile) -> void:
	var faceData : VWIFaceData = VWIFaceData.new()
	faceData.data_offset = B3DFile.get_position()
	faceData.type = B3DFile.get_32() #формат блока
	
	var inter_format : int = faceData.type ^ 1
	B3DFile.seek(B3DFile.get_position() + 12) #float, int32 32767, mtlIndex
	
	#faceData.mtlIndex = B3DFile.get_32()
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

func constructMesh() -> void:
	self.mesh = ArrayMesh.new()
	var arr_len : int 
	var n : int 
	var arr_off : int
	var idx : int

	for i in range(len(surfaces)):  #mtlIndex
		#print("face type: %d" % [surfaces[_i][0]])
		
		var verts : PackedVector3Array = [] #verts_node.vertex_data
		var UV_data : PackedVector2Array = [] #verts_node.uv_data
		var normals : PackedVector3Array = [] #verts_node.normals_data
		var indexes : PackedInt32Array = []
		
		arr_len = len(verts_node.vertex_data)
		n = -1
		
		for data in surfaces[i][1]: #data
			n += 1
			arr_off = arr_len * n
			
			verts.append_array(verts_node.vertex_data)
			UV_data.append_array(verts_node.uv_data)
			normals.append_array(verts_node.normals_data)

			#из плагинов от LabKaVars
			#https://github.com/LabVaKars/Hard-Truck-1-2-Blender-plugins/
			#import_b3d.py -> type 8
			for j in range(data.vertsCount - 2):
				if !(data.type & 0b10000000):
					if !(j % 2): #0, 2, 4 и т.д. - нет остатка от деления
						indexes.append(arr_off + data.vertsInd[j - 1])
						indexes.append(arr_off + data.vertsInd[j])
						indexes.append(arr_off + data.vertsInd[j + 1])
					else: #1, 3, 5...
						indexes.append(arr_off + data.vertsInd[j])
						indexes.append(arr_off + data.vertsInd[j + 1])
						indexes.append(arr_off + data.vertsInd[j + 2])
				else:
					if !(j % 2): #0, 2, 4 и т.д. - нет остатка от деления
						indexes.append(arr_off + data.vertsInd[j])
						indexes.append(arr_off + data.vertsInd[j + 1])
						indexes.append(arr_off + data.vertsInd[j + 2])
					else: #1, 3, 5...
						indexes.append(arr_off + data.vertsInd[j])
						indexes.append(arr_off + data.vertsInd[j + 2])
						indexes.append(arr_off + data.vertsInd[j + 1])

				
			#расстановка параметров
			for _j in range(data.vertsCount):
				idx = data.vertsInd[_j]

				if data.useOwnUV:
					if len(UV_data) < idx:
						print("big index=%d" % [idx])
						print("verts count %d" % [len(verts)])
						print("UV count %d" % [len(UV_data)])
	
					UV_data[arr_off + idx].x = data.vertsUV[_j][0]
					UV_data[arr_off + idx].y = data.vertsUV[_j][1]
					
				if data.useIntensityVector:
					normals[arr_off + idx].x = data.intensityVectors[_j].x
					normals[arr_off + idx].y = data.intensityVectors[_j].y
					normals[arr_off + idx].z = data.intensityVectors[_j].z
			

		
		@warning_ignore("unassigned_variable")
		var surface_data : Array
		surface_data.resize(Mesh.ARRAY_MAX)
		surface_data[Mesh.ARRAY_VERTEX] = verts #verts_node.vertex_data
		surface_data[Mesh.ARRAY_TEX_UV] = UV_data #verts_node.uv_data
		surface_data[Mesh.ARRAY_NORMAL] = normals

		indexes.reverse()
		
		surface_data[Mesh.ARRAY_INDEX]  = indexes

		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_data)
	
	#применение текстуры
	
	var mtl : StandardMaterial3D = scene_root.getMaterial(mtlIndex).duplicate()
	#var mtl : ShaderMaterial = scene_root.getMaterial(mtlIndex).duplicate()

	#if mtl.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
	#	mtl.render_priority = scene_root.transparent_mesh_index
	#	scene_root.transparent_mesh_index += 1
	
	#self.material_override = scene_root.getMaterial(mtlIndex)
	if verts_node.type == 37 and verts_node.normals_type == 3:
		#self.material_override.duplicate()
		#self.material_override.flags_unshaded = true
		mtl.flags_unshaded = true
		#mtl.set_shader_parameter('flags_unshaded', true)
		
	self.material_override = mtl
	
	return

	
func LoadFromB3D(B3DFile : StreamPeerBuffer) -> void:
	offset = B3DFile.get_position() - 40
	
	object_position = LoaderUtils.getVector3(B3DFile)
	object_radius = B3DFile.get_float()

	meshType = B3DFile.get_32()
	mtlIndex = B3DFile.get_32()
	dataCount = B3DFile.get_32()
	
	for _i in range(dataCount):
		read_IndexData(B3DFile)
	#LoaderUtils.MeshImporter35.LoadIndexes(B3DFile, dataCount)

	verts_node = scene_root.getVertsNode(get_parent())
	
	if (verts_node):
		constructMesh()
	else:
		print("verts node not found! par=%s" % [get_parent().name])
		
	scene_root.meshes_array.append(self)
	

#проверка для экспорта в obj - is_visible_in_tree 
#https://docs.godotengine.org/en/stable/classes/class_node3d.html

func get_copy() -> Node:
	var func_exec_time : int = Time.get_ticks_msec()

	var node : MeshInstance3D = MeshInstance3D.new()
	node.name = self.name + "_copy"
	node.script = self.script
	node.type = self.type
	node.scene_root = self.scene_root
	node.LoaderUtils = self.LoaderUtils
	node.need_to_be_imported = self.need_to_be_imported
	
	node.mesh = self.mesh
	node.material_override = self.material_override
	node.is_copy = true
	
	for child in self.get_children():
		var new_child : Node = child.get_copy()
		node.add_child(new_child)
		
	node.scene_root = self.scene_root
	node.visible = self.visible
	scene_root.meshes_array.append(node)
	scene_root.time_get_copy += (Time.get_ticks_msec() - func_exec_time) / 1000.0
	return node
