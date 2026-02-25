class_name B3D_Type19 extends B3D_Room

func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 19
	is_room = true
	buffer.seek(buffer.get_position() + 4) #child obj cnt

func _physics_process123(delta: float) -> void:
	if (self.visible == false):
		for col in col_shapes:
			col.disabled = true
			col.debug_color = Color('d6596c6b')
	
	elif (self.visible == true):
		for col in col_shapes:
			col.disabled = false
			col.debug_color = Color('0099b36b')
