class_name B3D_Type08 extends B3D_Object

var pos : Vector4
var linkedObjName  : String

var numFaces : int
var vertices : PackedVector3Array
var UV       : PackedVector2Array

var verts_node : Node
#var scene_root : Node

func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 8
	buffer.seek(buffer.get_position() + 16) #XYZW
	
	numFaces = buffer.get_u32()
	for _i in range(numFaces):
		read_IndexData(buffer)

	#verts_node = scene_root.getVertsNode(get_parent())
	verts_node = getVertsNode(self.get_parent())
	if (verts_node):
		constructMesh()
		#pass
	else:
		print("verts node not found! par=%s" % [get_parent().name])

var surfaces : Array
#поверхности по формату
#[ format:int ][ mtl:int ][ data:VWIFaceStruct[] ]

#var test_indexes : Array

func addDataToArray(new_data : VWIFaceStruct) -> void:
	for group : FaceStructGroups in surfaces:
		if group.mtlIndex == new_data.mtlIndex:
			group.structs.append(new_data)
			return
	
	var new_group : FaceStructGroups = FaceStructGroups.new()
	new_group.mtlIndex = new_data.mtlIndex
	new_group.structs.append(new_data)
	
	surfaces.append(new_group)

func read_IndexData(buffer : StreamPeerBuffer) -> void:
	var faceData : VWIFaceStruct = VWIFaceStruct.new()
	#faceData.data_offset = buffer.get_position()
	faceData.format = buffer.get_u32() #формат блока
	
	var inter_format : int = faceData.format ^ 1
	buffer.seek(buffer.get_position() + 8) #float, int32 32767
	
	faceData.mtlIndex = buffer.get_u32()
	faceData.vertsCount  = buffer.get_u32()

	for _j in range(faceData.vertsCount):
		faceData.vertsInd.append(buffer.get_u32())
		#далее доп. параметры
		
		if (inter_format & 2): #UV
			#индивидуальная UV данной вершины этого полигона
			faceData.vertsUV.append(VectorUtils.LoadVec2FromBuffer(buffer))
			faceData.useOwnUV = true

		if (inter_format & 0x10): #FACE_HAS_INTENCITY
			if (inter_format & 0x1): #FACE_INTENCITY_VECTOR
				if (inter_format & 0x20 or faceData.type == 24):
					#print("has intensity vector")
					faceData.intensityVectors.append(VectorUtils.LoadVec3FromBuffer(buffer))
					faceData.useIntensityVector = true
			elif (inter_format & 0x20):
				#print("has intensity float")
				buffer.seek(buffer.get_position() + 4)
				
	addDataToArray(faceData)
	
	#if faceData.mtlIndex not in test_indexes:
	#	test_indexes.append(faceData.mtlIndex)



#func addDataToArray(new_data : VWIFaceStruct) -> void:
	#for data in surfaces:
	#	if data[0] == new_data.mtlIndex:
	#		if data[1] == new_data.format:
	#			data[2].append(new_data)
	#			return

	#если блока такого типа в массиве нет
	#surfaces.append([new_data.mtlIndex, new_data.format, [new_data]])

func getVertsNode(obj : Node) -> Node:
	if obj.tag == 37 or obj.tag == 36 or obj.tag == 7 or obj.tag == 6:
		return obj
	elif obj.tag == 32767:
		return null
	else:
		return getVertsNode(obj.get_parent())

func constructMesh() -> void:
	var mesh_node  : Node = MeshInstance3D.new()
	self.add_child(mesh_node)
	
	mesh_node.mesh = ArrayMesh.new()

	#var mesh_unshaded : bool
	#if verts_node.tag == 37 and verts_node.normals_type == 3:
	#	mesh_unshaded = true

	#добавить деление по индексу материала
	for i in range(len(surfaces)):  #mtlIndex
		#print("face type: %d" % [surfaces[_i][0]])
		
		var verts : PackedVector3Array #verts_node.vertex_data
		var UV_data : PackedVector2Array #verts_node.uv_data
		var normals : PackedVector3Array #verts_node.normals_data
		var indexes : PackedInt32Array
		var mtlIndex : int = surfaces[i].mtlIndex
		
		var arr_len : int = verts_node.numVerts
		var n : int = -1
	
		for data : VWIFaceStruct in surfaces[i].structs: #data
			n += 1
			var arr_off : int = arr_len * n
			
			verts.append_array(verts_node.vertices)
			UV_data.append_array(verts_node.UV)
			normals.append_array(verts_node.normals)

			#из плагинов от LabKaVars
			#https://github.com/LabVaKars/Hard-Truck-1-2-Blender-plugins/
			#import_b3d.py -> type 8
			for j in range(data.vertsCount - 2):
				if !(data.format & 0b10000000):
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
				
				var v_idx : int = len(indexes) - 1 
				
				var vec_1 : Vector3 = verts[indexes[v_idx - 2]]
				var vec_2 : Vector3 = verts[indexes[v_idx - 1]]
				var vec_3 : Vector3 = verts[indexes[v_idx]]
				
				var normal_vec2 : Vector3 = VectorUtils.get_triangle_normal(vec_1, vec_2, vec_3)
				
				normals[indexes[v_idx  ]] = normal_vec2
				normals[indexes[v_idx-1]] = normal_vec2
				normals[indexes[v_idx-2]] = normal_vec2
				
			#расстановка параметров
			for _j in range(data.vertsCount):
				var idx : int = data.vertsInd[_j]
				if data.useOwnUV:
					if len(UV_data) < idx:
						print("big index=%d" % [idx])
						print("verts count %d" % [len(verts)])
						print("UV count %d" % [len(UV_data)])

					UV_data[arr_off + idx].x = data.vertsUV[_j][0]
					UV_data[arr_off + idx].y = data.vertsUV[_j][1]
					
				#оно в общем-то и не очень надо
				#if data.useIntensityVector:
				#	normals[arr_off + idx].x = data.intensityVectors[_j].x
				#	normals[arr_off + idx].y = data.intensityVectors[_j].y
				#	normals[arr_off + idx].z = data.intensityVectors[_j].z

		#for z in range(len(indexes) / 3):
		#	normals[z]
		#	normals[z + 1]
		#	normals[z + 2]

		var surface_data : Array
		surface_data.resize(Mesh.ARRAY_MAX)
		surface_data[Mesh.ARRAY_VERTEX] = verts #verts_node.vertex_data
		surface_data[Mesh.ARRAY_TEX_UV] = UV_data #verts_node.uv_data
		surface_data[Mesh.ARRAY_NORMAL] = normals
		#index_data.invert()
		
		indexes.reverse()
		#print(verts)
		#print(normals)
		#breakpoint
		surface_data[Mesh.ARRAY_INDEX]  = indexes
			
		#print(verts_node.name)
		#breakpoint
		mesh_node.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_data)
		#mesh_node.mesh.surface_set_material(i, StandardMaterial3D.new())
		mesh_node.mesh.surface_set_material(i, sceneRoot.resources.getMaterialByIndex(mtlIndex))
		mesh_node.mesh.surface_set_name(i, mesh_node.mesh.surface_get_material(i).resource_name)
		#mesh.surface_set_material(i, scene_root.getMaterial(mtlIndex))
		
		#var mtl : StandardMaterial3D = scene_root.getMaterial(mtlIndex).duplicate()
		#var mtl : ShaderMaterial = scene_root.getMaterial(mtlIndex).duplicate()

		#if mtl.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
		#	mtl.render_priority = scene_root.transparent_mesh_index
		#	scene_root.transparent_mesh_index += 1
		
		#if mesh_unshaded:
		#	mtl.flags_unshaded = true
			#mtl.set_shader_parameter('flags_unshaded', true)

		#var mtl : ShaderMaterial = scene_root.resources.getMaterialByIndex(mtlIndex) #-1
		#var mtl : ShaderMaterial = scene_root.getMaterialByIndex(mtlIndex) #.duplicate()
		
		#if mesh_unshaded:
			#mtl = mtl.duplicate()
			#print(mtl.shader.code[439])# = "#define DISABLE_SHADING 1"
		
		#for x in range(30):
		#	mtl.shader.code.
		#	print(mtl.shader.code[430 + x])
		
		#mesh_node.mesh.surface_set_material(i, mtl)
		#указание материала создаваемой поверхности
		
		#self.material_override = scene_root.getMaterial(mtlIndex)
	
	#mesh_node.mesh.regen_normal_maps()
	return
