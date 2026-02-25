class_name VWISceneContainer extends B3D_Object

#var b3d_mtl_count : int
#var b3d_mtl_names : PackedStringArray
var resources     : VWIResourcesContainer

var viewerObject : B3D_Type01
var viewer : Node
var rooms  : Array

#запросы на поиск объекта
var searchQueries : Array

var render_priority_counter : int = 0

func addSearchQuery(from : Node, target : String) -> void:
	searchQueries.append([target, from])

func processSearchQueries() -> void:
	pass
	#for obj in self.get_children():
	#	for query in searchQueries:
	#		if obj.name == query[0]:
	#			query[1].
	
func searchSceneObject(objName : String) -> Node3D:
	for obj in self.get_children():
		if obj.name == objName:
			return obj
	return null

func initialize() -> void:
	placeViewer()

func placeViewer() -> void:
	if !(viewerObject):
		return
	
	if viewerObject.start_room:
		viewerObject.start_room.visible = true
	
	if viewerObject.start_space:
		viewer.set_global_transform(viewerObject.start_space.get_global_transform())
