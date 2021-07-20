shader_type canvas_item;

uniform vec2 mousePos = vec2(0.0, 0.0);
uniform vec2 globalPos = vec2(0.0, 0.0);
//uniform vec2[] cellsPos = [];

const vec2 screenSize = vec2(1280.0, 720.0);

//vec4 drawCell(vec2 screenPos, vec4 sourceColor, float radius, vec4 color, ) {
//
//}

void fragment() {
	
	vec4 tex = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	vec2 offset = globalPos * vec2(1.0, -1.0);
	
	vec2 correctedMousePos = mousePos;
	correctedMousePos.y = screenSize.y * 0.5 - mousePos.y;
	
	vec2 pos = SCREEN_UV * screenSize * 0.5 + offset;

	vec2 positions[2] = {correctedMousePos, vec2(100.0, 100.0)};
	
	vec4 finalCol = tex;
	
	for (int i = 0; i < 2; ++i) {

		vec2 cellPos = positions[i];
		float len = length(pos - cellPos);
		vec4 cellCol = vec4(0.0, 0.0, 0.0, 1.0);
		finalCol = mix(finalCol, cellCol, float(len < 10.0));

	}

	
	
	COLOR = finalCol;
	
}