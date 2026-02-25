extends CharacterBody3D

var force : float = 0.01

func _physics_process(_delta: float) -> void:
	if (Input.is_action_pressed('ui_up')):
		self.move_and_collide(Vector3(0, 0, force))
	
	if (Input.is_action_pressed('ui_down')):
		self.move_and_collide(Vector3(0, 0, -force))
		
	if (Input.is_action_pressed('ui_right')):
		self.move_and_collide(Vector3(force, 0, 0))
	
	if (Input.is_action_pressed('ui_left')):
		self.move_and_collide(Vector3(-force, 0, 0))
