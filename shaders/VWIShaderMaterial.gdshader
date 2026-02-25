shader_type spatial;

render_mode cull_back;
//render_mode vertex_lighting, cull_back;
//render_mode unshaded, cull_back;

uniform sampler2D tex;
//uniform sampler2D filter : filter_nearest;

uniform vec3 colorValue;
uniform bool colorAsAlbedo;
uniform bool colorAsTransp;

uniform bool forceTransp;
uniform float transp;

uniform bool useMove;
uniform vec2 moveVec;

uniform bool useRot;
uniform vec2 rotCenter;
uniform float rot;

//а потом менять через код
#define DISABLE_SHADING 1

#if DISABLE_SHADING
	render_mode unshaded;
#endif

void vertex() {
	if (useMove){
		UV.x += moveVec.x * TIME;
		UV.y += moveVec.y * TIME;
	}
	if (useRot){
		float rotCurrent = radians(rot * TIME);
		UV -= rotCenter;
		UV = vec2(UV.x * cos(rotCurrent) - UV.y * sin(rotCurrent),
				  UV.x * sin(rotCurrent) + UV.y * cos(rotCurrent));
		UV += rotCenter;
	}
	//if (disableShading){
	//	NORMAL *= 0.0;
		//DIFFUSE_LIGHT -= 15.0;
		//SPECULAR_LIGHT = vec3(1, 1 ,1);
		//DIFFUSE_LIGHT = vec3(1.0, 1.0, 1.0);
	//}
}

void fragment() {
	ALBEDO = texture(tex, UV).rgb;
	ALPHA = texture(tex, UV).a;
	
	if (colorAsTransp){
		ALPHA_SCISSOR_THRESHOLD = 0.75;
		if ((ALBEDO.r == colorValue.r) && (ALBEDO.g == colorValue.g) && (ALBEDO.b == colorValue.b)){
			ALPHA = 0.0;
		}
	}
	if (colorAsAlbedo){
		ALBEDO = colorValue;
	}
	if (forceTransp){
		ALPHA = transp;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
