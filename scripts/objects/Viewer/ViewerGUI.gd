extends Node

@onready var Viewer : Node3D = get_parent()
var vertsCount : int
var objCount : int
var drawCalls : int 

#var Render : RenderingServer
func _process(_delta):
	vertsCount = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
	objCount  = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME)
	drawCalls = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	$Label_Position.text = "FPS=%d | %.3f %.3f %.3f" % [Engine.get_frames_per_second(), -Viewer.position.x, Viewer.position.z, Viewer.position.y]
	$Label_FrameInfo.text = "FRAME: verts=%d, objects=%d, drawCalls=%d" % [vertsCount, objCount, drawCalls]
	#print(RenderingServer.viewport_get_render_info(get_viewport(), RenderingServer.VIEWPORT_RENDER_INFO_TYPE_VISIBLE, RenderingServer.VIEWPORT_RENDER_INFO_PRIMITIVES_IN_FRAME ))
	#print(get_viewport())
	#print(VisualServer)
	#print()
	
	#$Label_DrawCalls.text = "drawcalls=%d" % [get_viewport().get_rendering_info(SubViewport.RENDER_INFO_DRAW_CALLS_IN_FRAME)]

	#$group_left/txt_ScreenResolution.text = "xres %d, yres %d" % [get_parent().xres, get_parent().yres]
	#$group_left/txt_FPS.text = "FPS: %d" % [Engine.get_frames_per_second()]
	#$group_left/txt_ViewerPosition.text = "%.3f %.3f %.3f" % [-Viewer.position.x, Viewer.position.z, Viewer.position.y]
	#$group_left/txt_VerticesInFrame.text = "Vertices in frame: %d" % [get_viewport().get_rendering_info(SubViewport.RENDER_INFO_VERTICES_IN_FRAME)]
	#$group_left/txt_ObjectsInFrame.text = "Objects in frame: %d" % [get_viewport().get_rendering_info(SubViewport.RENDER_INFO_OBJECTS_IN_FRAME)]
	#$group_left/txt_DrawCalls.text = "DrawCalls in frame: %d" % [get_viewport().get_rendering_info(SubViewport.RENDER_INFO_DRAW_CALLS_IN_FRAME)]
