extends Node3D

var position2D : Vector2

@export  var lock_input : bool = true
@onready var light_node : Node = self.get_node("SpotLight3D")

@onready var gui_node : Node = self.get_node("ViewerGUI")
var gui_visible : bool

func _process(_delta):
	if (lock_input):
		return
	
	position2D.x = self.position.x
	position2D.y = self.position.z
		
	if (Input.is_action_just_pressed('viewer_light')):
		light_node.visible = !light_node.visible
		
	if (Input.is_action_just_pressed('viewer_hide_ui')):
		gui_visible = not gui_visible
		gui_node.set_visible(gui_visible)
