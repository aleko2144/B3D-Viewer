extends Window
var scenes : Node
var switchers_states : Array
var default_states : Array

func reset():
	$switchers_list.clear()
	
	scenes = get_parent().get_parent().get_node("Scenes")
	
	for group in scenes.switchers_array:
		$switchers_list.add_item(group[0][0])
		switchers_states.append(group[2][0])
		default_states.append(group[3][0])
		
		#print("%s=%d" % [group[0][0], group[2][0]])

func updateSwitchers(state_change : int) -> void:
	if (!len($switchers_list.get_selected_items())):
		return
	
	for idx in $switchers_list.get_selected_items():
		scenes.updateSwitchersState(idx, state_change)
		
		if (state_change):
			switchers_states[idx] += state_change
		else:
			switchers_states[idx] = default_states[idx]
		
	var sw_idx : int = $switchers_list.get_selected_items()[0]
	var sw_txt : String = "Selected switcher state: %d" % switchers_states[sw_idx]
	$lbl_switcher_state.text = sw_txt

func _on_close_requested():
	self.hide()

func _on_btn_next_sw_pressed():
	updateSwitchers(1)

func _on_btn_reset_sw_pressed():
	updateSwitchers(0)

func _on_btn_prev_sw_pressed():
	updateSwitchers(-1)

func _on_switchers_list_item_clicked(index, at_position, mouse_button_index):
	var sw_txt : String = "Selected switcher state: %d" % switchers_states[index]
	$lbl_switcher_state.text = sw_txt
