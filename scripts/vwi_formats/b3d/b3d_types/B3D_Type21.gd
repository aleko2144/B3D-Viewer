class_name B3D_Type21 extends B3D_SwitchContainer

func FromBytes(buffer : StreamPeerBuffer) -> void:
	tag = 21
	is_switcher = true

	buffer.seek(buffer.get_position() + 16) #XYZW
	groupsNum  = buffer.get_u32()
	switchState = buffer.get_u32()
	buffer.seek(buffer.get_position() + 4) #child obj cnt

	self.resizeGroupsArray()
	
#func _process(_delta: float) -> void:
#	if (Input.is_action_just_pressed('ui_up')):
#		self.setSwitch(switchState + 1)
#	if (Input.is_action_just_pressed('ui_down')):
#		self.setSwitch(switchState - 1)
#	#self.visible = false
