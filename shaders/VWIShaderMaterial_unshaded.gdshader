shader_type spatial;

//render_mode vertex_lighting, cull_back;
render_mode unshaded, cull_back;

uniform sampler2D tex;

uniform vec3 color;
uniform bool colorAsAlbedo;
uniform bool colorAsTransp;

uniform bool forceTransp;
uniform float transp;

uniform bool useMove;
uniform vec2 moveVec;

uniform bool useRot;
uniform vec2 rotCenter;
uniform float rot;

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
}

void fragment() {
	ALBEDO = texture(tex, UV).rgb;
	ALPHA = texture(tex, UV).a;
	
	if (colorAsAlbedo){
		ALBEDO = color;
	}
	if (colorAsTransp){
		if ((ALBEDO.r == color.r) && (ALBEDO.g == color.g) && (ALBEDO.b == color.b)){
			ALPHA = 0.0;
		}
	}
	if (forceTransp){
		ALPHA = transp;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
