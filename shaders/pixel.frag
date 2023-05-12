#pragma header

// uniform float pixelZoom = 6.0;
// how it works
// - takes the camera
// - unzooms it to make it pixel perfect and align every pixel
// - zooms in the result using this shader
void main() {
	vec2 camPos = openfl_TextureCoordv;

	camPos = vec2(0.5, 0.5) + ((camPos - vec2(0.5, 0.5)) * 0.5);

	gl_FragColor = flixel_texture2D(bitmap, camPos);
}
