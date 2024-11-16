extends Window

func reset():
	$lbl_msg.text = ""
	$cbox_modules.clear()
	
	for scn in get_parent().get_parent().get_node("Scenes").get_children():
		$cbox_modules.add_item(scn.name)
	
	$cbox_modules.selected = 0

func _on_btn_switch_pressed():
	var scn_name : String = $cbox_modules.get_item_text($cbox_modules.get_selected())
	
	if len(scn_name):
		var scene : Node = get_parent().get_parent().Scenes.get_node(scn_name)
		if !scene:
			$lbl_msg.text = "Модуль не найден / module has not found"
		else:
			var object : Node = scene.get_node($text_object.text)
			if !object:
				$lbl_msg.text = "Объект не найден / object has not found"
			else:
				object.visible = !object.visible
				if object.visible:
					$lbl_msg.text = "Объект отображён / object is displayed"
				else:
					$lbl_msg.text = "Объект скрыт / object is hidden"
	#	#get_parent().Scenes.get_child(0).switchObjectRender($dialog/LineEdit.text)
	#		get_parent().Scenes.get_node($dialog/LineEdit.text).switchObjectRender($dialog/LineEdit2.text)
	#else:
	#	$lbl_msg

#func _on_btn_cancel_pressed():
#	self.visible = false

func _on_btn_hide_all_pressed():
	var scn_name : String = $cbox_modules.get_item_text($cbox_modules.get_selected())
	
	if len(scn_name):
		var scene : Node = get_parent().get_parent().Scenes.get_node(scn_name)
		if !scene:
			$lbl_msg.text = "Модуль не найден / module has not found"
		else:
			for object in scene.get_children():
				object.visible = false

func _on_btn_unhide_all_pressed():
	var scn_name : String = $cbox_modules.get_item_text($cbox_modules.get_selected())
	
	if len(scn_name):
		var scene : Node = get_parent().get_parent().Scenes.get_node(scn_name)
		if !scene:
			$lbl_msg.text = "Модуль не найден / module has not found"
		else:
			for object in scene.get_children():
				object.visible = true


func _on_close_requested():
	self.hide()
