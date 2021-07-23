shader_type canvas_item;

uniform vec2 mousePos = vec2(0.0, 0.0);
uniform vec2 globalPos = vec2(0.0, 0.0);
uniform sampler2D cellsPos;
uniform int cellsCount = 0;

const vec2 screenSize = vec2(1280.0, 736.0);

//vec4 drawCell(vec2 screenPos, vec4 sourceColor, float radius, vec4 color, ) {
//
//}

void fragment() {
	
	vec4 tex = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 texl = textureLod(SCREEN_TEXTURE, SCREEN_UV, 1.0);
	
	vec2 offset = globalPos * vec2(1.0, -1.0);
	
//	vec2 correctedMousePos = mousePos;
//	correctedMousePos.y = screenSize.y * 0.5 - mousePos.y;
	
//	vec2 suv = vec2(SCREEN_UV.x, SCREEN_UV.y);
	
	vec2 pixelPos = SCREEN_UV * screenSize * 0.5 + offset;
	pixelPos = floor(pixelPos);

//	vec2 positions[3] = {correctedMousePos, vec2(100.0, 100.0), cpos};
	
	vec4 finalCol = tex;
	
	float finalIntencity = 0.0;
	float mFinalIntencity = 0.0;
	
	float collidingCells = 0.0;
		
	float m = 1.0;
	
	vec4 cellColors[6] = {
		vec4(235. / 255., 205. / 255., 194. / 255., 1.0) * 1.0,
		vec4(105. / 255., 235. / 255., 094. / 255., 1.0) * 2.0,
		vec4(105. / 255., 094. / 255., 235. / 255., 1.0) * 2.0,
		vec4(235. / 255., 105. / 255., 094. / 255., 1.0) * 2.0,
		vec4(235. / 255., 205. / 255., 094. / 255., 1.0) * 2.0,
		vec4(235. / 255., 094. / 255., 205. / 255., 1.0) * 2.0
	};
	
	vec4 cellColors2[6] = {
		vec4(235. / 255., 225. / 255., 215. / 255., 1.0) * 1.0,
		vec4(105. / 255., 235. / 255., 124. / 255., 1.0) * 1.0,
		vec4(105. / 255., 124. / 255., 235. / 255., 1.0) * 1.0,
		vec4(235. / 255., 125. / 255., 115. / 255., 1.0) * 1.0,
		vec4(235. / 255., 225. / 255., 115. / 255., 1.0) * 1.0,
		vec4(235. / 255., 115. / 255., 225. / 255., 1.0) * 1.0
//		vec4(235. / 255., 105. / 255., 124. / 255., 1.0) * 1.0, red
	};
	
	float colorIntencities[6] = {
		1.0,
		1.4,
		1.4,
		1.4,
		1.4,
		1.4
	};
	
	vec4 cellCol = vec4(0.0, 0.0, 0.0, 0.0);
	vec4 cellCol2 = vec4(0.0, 0.0, 0.0, 0.0);
	float colorIntencity = 0.0;
	
	for (int i = 0; i < cellsCount; ++i) {

		float xh1 = texelFetch(cellsPos, ivec2(i * 3, 0), 0).r * 255.0;
		float xh2 = texelFetch(cellsPos, ivec2(i * 3 + 1, 0), 0).r * 255.0;
		float xsign = texelFetch(cellsPos, ivec2(i * 3 + 2, 0), 0).r * 255.0 - 1.0;
		float yh1 = texelFetch(cellsPos, ivec2(i * 3, 1), 0).r * 255.0;
		float yh2 = texelFetch(cellsPos, ivec2(i * 3 + 1, 1), 0).r * 255.0;
		float ysign = texelFetch(cellsPos, ivec2(i * 3 + 2, 1), 0).r * 255.0 - 1.0;

		float x = (xh1 * 255.0 + xh2) * xsign;
		float y = (yh1 * 255.0 + yh2) * ysign;
		y = screenSize.y * 0.5 - y;

		vec2 cellPos = vec2(x, y);

		
		float len = length(pixelPos - cellPos);
//		vec4 cellCol = vec4(0.0, 0.0, 0.0, 1.0);
		
		if (len <= 12.0) {
			float t = (sin(TIME * 4.0 + float(i) * 3.14159 * 0.2) + 1.0) * 0.5;
			t = 0.7 + t * 0.3;
	
			float intencity = len / 12.0;// * ((sin(cellPos.x * 0.1) + 1.0) * 0.5) * t;
			finalIntencity += pow(1.0 - intencity, 2.0);
			mFinalIntencity += pow(1.0 - intencity * t, 2.0);
			collidingCells += 1.0;
			
			int colorId = int(texelFetch(cellsPos, ivec2(i * 3, 2), 0).r * 255.0);
			float cellIntenticy = texelFetch(cellsPos, ivec2(i * 3 + 1, 2), 0).r * 255.0 * 0.1;
			cellCol += cellColors[colorId];
			cellCol2 += cellColors2[colorId];
//			colorIntencity += colorIntencities[colorId];
			colorIntencity += cellIntenticy;
			
		}
		
	}
	
//	if (collidingCells > 1.0) {
//		finalIntencity = mFinalIntencity;
//	}
	
	finalIntencity = clamp(finalIntencity, 0.0, 1.0);
	
	if (collidingCells < 1.0) {
		cellCol = cellColors[0];
		cellCol2 = cellColors2[0];
		colorIntencity = colorIntencities[0];
	}
	else {
		cellCol /= vec4(collidingCells);
		cellCol2 /= vec4(collidingCells);
		colorIntencity /= collidingCells;
	}
	
//	cellCol.a = 1.0;
//	cellCol2.a = 1.0;
	
	finalCol = mix(finalCol, pow(texl, vec4(0.8)) + cellCol2 * finalIntencity * 0.7 * pow(colorIntencity, 2.0), clamp(pow(finalIntencity, 0.5), 0.0, 1.0));
	finalCol = mix(finalCol, pow(texl, vec4(0.8)) + cellCol * (colorIntencity - finalIntencity) * 0.6, floor(finalIntencity * 1.6));
	
	COLOR = finalCol;
	
}