class_name B3D_SwitchContainer extends B3D_Object

var groups : Array
var groupsNum   : int
var switchState : int
var current_importing_group : int

func addToGroup(obj : Node) -> void:
	groups[current_importing_group].append(obj)
	#groups[current_importing_group].append(self.get_child_count() - 1)

func finishGroup() -> void:
	current_importing_group += 1
	
func resizeGroupsArray() -> void:
	for _i in range(groupsNum):
		groups.append([])

func switchObjectVisibility(obj : Node, state : bool) -> void:
	if (obj):
		obj.visible = state

func setSwitch(switch_target : int) -> void:
	var i : int = 0
	
	for group in groups:
		for obj in group:
			if i == switch_target:
				switchObjectVisibility(obj, true)
				#self.get_child(index).visible = true
			else:
				switchObjectVisibility(obj, false)
				#self.get_child(index).visible = false
		i += 1

	switchState = switch_target
