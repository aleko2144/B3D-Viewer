extends RigidBody3D

var force : float = 50

func _physics_process(delta: float) -> void:
	if (Input.is_action_pressed('ui_up')):
		self.apply_central_impulse(Vector3(0, 0, force))
	
	if (Input.is_action_pressed('ui_down')):
		self.apply_central_impulse(Vector3(0, 0, -force))
		
	if (Input.is_action_pressed('ui_right')):
		self.apply_central_impulse(Vector3(force, 0, 0))
	
	if (Input.is_action_pressed('ui_left')):
		self.apply_central_impulse(Vector3(-force, 0, 0))

func aboba() -> void:
	var vector_Front : Vector3 = self.transform.basis.z
	var vector_Top   : Vector3 = self.transform.basis.y
	var vector_Right : Vector3 = self.transform.basis.x
	
	if (Input.is_action_pressed('ui_up')):
		self.apply_central_impulse(vector_Front * force)
	
	if (Input.is_action_pressed('ui_down')):
		self.apply_central_impulse(vector_Front * -force)
		
	if (Input.is_action_pressed('ui_right')):
		self.apply_central_impulse(vector_Right * force)
	
	if (Input.is_action_pressed('ui_left')):
		self.apply_central_impulse(vector_Right * -force)
