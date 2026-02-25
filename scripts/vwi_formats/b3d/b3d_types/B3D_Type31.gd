class_name B3D_Type31 extends B3D_Object

#RACES_D1.B3D, pos = 0x91C4
#3D msk-sprite with distance switch?
var masks_count : int

var objectPos  : Vector4
var spritePos  : Vector3

var spriteType : int
var some_vec : Vector3

var blendValues : PackedFloat32Array
var masks       : Array

###
var sprite3d     : MeshInstance3D
var planeMesh    : PlaneMesh
var material     : StandardMaterial3D
var currentMskID : int
###

#2 - SEOUL_ #5 #10 - races_d1
var msk_switch_distance : int = 3
var msk_max_distance    : int = 150 #300

func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 31

	buffer.seek(buffer.get_position() + 16) #XYZW
	masks_count = buffer.get_u32()
	
	###
	#msk_switch_distance = masks_count / 3.0
	###
	
	msk_switch_distance = msk_max_distance / masks_count
	
	objectPos = VectorUtils.LoadXZYVec4FromBuffer(buffer)

	spriteType  = buffer.get_u32()
	
	#8 - tree leaves
	#14 - tree wood and stolbik
	if (spriteType != 8 and spriteType != 14):
		breakpoint
	
	spritePos = VectorUtils.LoadXZYVec3FromBuffer(buffer)

	#buffer.seek(buffer.get_position() + 4)  #some int
	#вектор размера спрайта?
	#some_vector - sprite_xyzw = size?
	#buffer.seek(buffer.get_position() + 12) #some vector
	
	for i in range(masks_count):
		blendValues.append(buffer.get_float())
		var msk_id : int = buffer.get_u32()
		masks.append(sceneRoot.resources.getMaskByIndex(msk_id + 1))
		
	sprite3d  = MeshInstance3D.new()
	planeMesh = PlaneMesh.new()
	material  = StandardMaterial3D.new()
	
	var msk : ImageTexture = masks[currentMskID]
	var msk_size : Vector2 = msk.get_size()
	#print(msk.get_size())
	
	#print(masks[-1].get_size())
	#print(masks[0].get_size())
	#breakpoint
	
	#tree top
	#msk[-1] = (170.0, 152.0)
	#msk[ 0] = (17.0, 15.0)
	#tree wood
	#msk[-1] = (30.0, 82.0)
	#msk[ 0] = (3.0, 8.0)
	
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.albedo_texture = msk
	material.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
	
	#material.render_priority = sceneRoot.render_priority_counter
	#sceneRoot.render_priority_counter += 1

	var mask_size_base  : float
	var sprite_size_max : float = objectPos.w * 2
	
	#if (objectPos.w)
	#sprite_size_max = (objectPos.w * 2) - (spritePos.y + objectPos.w)

	#поиск наибольшей стороны текстуры
	if (msk_size.x < msk_size.y):
		mask_size_base = msk_size.y
	
	if (msk_size.y < msk_size.x):
		mask_size_base = msk_size.x

	#костыль
	if (spriteType == 14 and objectPos.y == spritePos.y):
		sprite_size_max = objectPos.w
	
	var size_coeff : float = sprite_size_max / mask_size_base
	var sprite_size : Vector2 = msk_size * size_coeff
	
	planeMesh.size = sprite_size
	planeMesh.center_offset.y = sprite_size.y / 2.0
	planeMesh.orientation = PlaneMesh.FACE_Z
	
	if (spriteType == 8):
		planeMesh.center_offset.y = 0
	
	sprite3d.mesh = planeMesh
	sprite3d.material_override = material
	sprite3d.name = 'test_sprite'

	self.add_child(sprite3d)

	sprite3d.global_position = spritePos

var distance_to_viewer : float
var target_msk_idx : int

func _process(delta: float) -> void:
	#distance/msk_count
	#2/99- SEOUL_ #5 #10/37 - races_d1
	#msk_switch_distance = 3

	distance_to_viewer = (spritePos - sceneRoot.viewer.get_global_position()).length()
	if ((distance_to_viewer / msk_switch_distance) < masks_count):
		target_msk_idx = masks_count - int(distance_to_viewer / msk_switch_distance)
		
		if (target_msk_idx < 0):
			target_msk_idx = 0
		elif (target_msk_idx >= masks_count):
			target_msk_idx = masks_count - 1
		
		currentMskID = target_msk_idx
		material.albedo_texture = masks[currentMskID]

#var mskIdx : int = masks_count - 1
#func _process(_delta: float) -> void:
#	if (Input.is_action_just_pressed('ui_up')):
#		if (mskIdx + 1 < masks_count):
#			mskIdx += 1
#	if (Input.is_action_just_pressed('ui_down')):
#		if (mskIdx - 1 > 0):
#			mskIdx -= 1
#		
#	var msk : ImageTexture = masks[mskIdx]
#	material.albedo_texture = msk
