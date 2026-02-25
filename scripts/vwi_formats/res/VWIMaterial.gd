class_name VWIMaterial

var mtl_name : String
var material : ShaderMaterial

func FromString(in_str : String, res : VWIResourcesContainer) -> void:
	var mtl_str : PackedStringArray = in_str.split(' ', false)
	#print(mtl_str)
	
	mtl_name = mtl_str[0]
	material = ShaderMaterial.new()
	material.shader = load("res://shaders/VWIShaderMaterial.gdshader")
	material.resource_name = mtl_name
	#material = load("res://shaders/VWIShaderMaterial_unshaded.gdshader")
	
	#var temp_str : String
	#var temp_int : int
	#var temp_txr : VWIImageTXR
	
	var use_tex : bool = false
	
	for i in range(len(mtl_str)):
		match mtl_str[i]:
			'tex':
				#print('tex %d -> %s' % [temp_int, res.getTextureByIndex(temp_int).tex_name])
				i += 1
				var texture : ImageTexture = res.getTextureByIndex(int(mtl_str[i]))
				material.set_shader_parameter('tex', texture)
				use_tex = true
			'ttx':
				i += 1
				var texture : ImageTexture = res.getTextureByIndex(int(mtl_str[i]))
				material.set_shader_parameter('colorAsTransp', true)
				material.set_shader_parameter('tex', texture)
				use_tex = true
		
			'col':
				i += 1
				#color may be used as alpha-channel, but this doesn't
				#work in Godot, because colors in VWI are RGB8, not RGB-float
				if (!use_tex):
					material.set_shader_parameter('colorAsAlbedo', true)
					var col : Color = res.getColorByIndex(int(mtl_str[i]))
					#if (mtl_name == 'forest1'):
					#	print(col)
					material.set_shader_parameter('colorValue', col)
			'move':
				material.set_shader_parameter('useMove', true)
				var move_dir : Vector2
				i += 1
				move_dir.x = float(mtl_str[i])
				i += 1
				move_dir.y = float(mtl_str[i])
				material.set_shader_parameter('moveVec', move_dir)
			'RotPoint':
				material.set_shader_parameter('useRot', true)
				var rot_center : Vector2
				i += 1
				rot_center.x = float(mtl_str[i])
				i += 1
				rot_center.y = float(mtl_str[i])
				material.set_shader_parameter('rotCenter', rot_center)
			'rot':
				material.set_shader_parameter('useRot', true)
				i += 1
				material.set_shader_parameter('rot', float(mtl_str[i]))	
			'transp':
				material.set_shader_parameter('forceTransp', true)
				i += 1
				material.set_shader_parameter('transp', float(mtl_str[i]))
		
			#_:
				#print(temp_str)
