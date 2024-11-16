extends Node

var rotation_vector_current : Vector2
var rotation_vector_target : Vector2

var moving_vector_current : Vector3
var moving_vector_target : Vector3

var interp_speed : float = 0.1 #0.01
var look_speed : float = 0.01
var move_speed : float = 1

@onready var Viewer : Node = get_parent()

#взято из https://docs.godotengine.org/en/3.5/tutorials/3d/using_transforms.html
func _input(event):
	if event is InputEventMouseMotion:
		if event.button_mask & 2:
			rotation_vector_target.y += -event.relative.x * look_speed
			rotation_vector_target.x += event.relative.y * look_speed
			
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			move_speed *= 1.2
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			move_speed *= 0.8

func ViewerMovement_ProcessMouseLook(rot_obj : Node, limit : bool) -> void:
	if !rot_obj:
		return
	rotation_vector_current = rotation_vector_current.lerp(rotation_vector_target, interp_speed)
	rot_obj.transform.basis = Basis() # reset rotation
	rot_obj.rotate_object_local(Vector3(0, 1, 0), rotation_vector_current.y) # first rotate in Y
	rot_obj.rotate_object_local(Vector3(1, 0, 0), rotation_vector_current.x) # then rotate in X
	
	var limit_x : float = deg_to_rad(90)
	var limit_y : float = deg_to_rad(115)
	
	if (limit):
		if rotation_vector_target.x > limit_x:
			rotation_vector_target.x = limit_x
		if rotation_vector_target.x < -limit_x:
			rotation_vector_target.x = -limit_x
			
		if rotation_vector_target.y > limit_y:
			rotation_vector_target.y = limit_y
		if rotation_vector_target.y < -limit_y:
			rotation_vector_target.y = -limit_y
	
func ViewerMovement_ProcessMovement() -> void:
	if (Input.is_action_pressed('viewer_forward')):
		moving_vector_target.z = move_speed
	elif (Input.is_action_pressed('viewer_backward')):
		moving_vector_target.z = -move_speed
	else:
		moving_vector_target.z = 0
	
	if (Input.is_action_pressed('viewer_right')):
		moving_vector_target.x = -move_speed
	elif (Input.is_action_pressed('viewer_left')):
		moving_vector_target.x = move_speed
	else:
		moving_vector_target.x = 0
		
	if (Input.is_action_pressed('viewer_up')):
		moving_vector_target.y = move_speed
	elif (Input.is_action_pressed('viewer_down')):
		moving_vector_target.y = -move_speed
	else:
		moving_vector_target.y = 0
	
	moving_vector_current = moving_vector_current.lerp(moving_vector_target, interp_speed)
	
	if !Viewer.lock_input:
		Viewer.translate_object_local(moving_vector_current)


func Viewer_LimitAngles() -> void:
	if rotation_vector_current.x > 360 or rotation_vector_current.x < -360:
		rotation_vector_current.x = 0
	if rotation_vector_current.y > 360 or rotation_vector_current.y < -360:
		rotation_vector_current.y = 0
		
	if rotation_vector_target.x > 360 or rotation_vector_target.x < -360:
		rotation_vector_target.x = 0
	if rotation_vector_target.y > 360 or rotation_vector_target.y < -360:
		rotation_vector_target.y = 0

func Viewer_Process() -> void:
	Viewer_LimitAngles()
	
	ViewerMovement_ProcessMouseLook(Viewer, false)
	ViewerMovement_ProcessMovement()
	
	if !Viewer.lock_input:
		if (Input.is_action_just_pressed('viewer_light')):
			Viewer.get_node('SpotLight3D').visible = !Viewer.get_node('SpotLight3D').visible
			#var test : Transform3D
			#test.origin.x = 35
			#test.origin.y = 25
			#test.origin.z = 15
			#self.Viewer_SetTransform(test)
			
		if (Input.is_action_just_pressed("viewer_reset_transform")):
			Viewer.get_parent().Scenes.resetViewerPosition()
		
	#if (Input.is_action_just_pressed("viewer_show_test_object")):
	#	if len($dialog/LineEdit.text):
	#		#get_parent().Scenes.get_child(0).switchObjectRender($dialog/LineEdit.text)
	#		get_parent().Scenes.get_node($dialog/LineEdit.text).switchObjectRender($dialog/LineEdit2.text)

#enum {MODE_FREE_VIEW, FREEZE_MODE_STATIC, MODE_INTERIOR_VIEW, MODE_OUTSIDE_VIEW}
func _physics_process(_delta):
	Viewer_Process()
