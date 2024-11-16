extends Window
var scenes : Node
var switchers_states : Array
var default_states : Array

func reset():
	$scenes_list.clear()
	$objects_list.clear()
	
	scenes = get_parent().get_parent().get_node("Scenes")
	
	for scn in scenes.get_children():
		$scenes_list.add_item(scn.name)

func _on_close_requested():
	self.hide()

func _on_scenes_list_item_clicked(index, at_position, mouse_button_index):
	var selected_scene_name : String = $scenes_list.get_item_text(index)
	var selected_scene : Node = scenes.get_node(selected_scene_name)
	
	$objects_list.clear()
	
	for obj in selected_scene.get_children():
		$objects_list.add_item(obj.name)
