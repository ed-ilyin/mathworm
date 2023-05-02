<script lang="ts">
	import { onMount } from 'svelte';
	let canvas: HTMLCanvasElement;
	let gl: WebGL2RenderingContext | null;
	let program: WebGLProgram | null;

	const vertexShaderSource = `
		attribute vec4 a_position;
		void main() {
			gl_Position = a_position;
		}`;

	const fragmentShaderSource = `
	void main() {
		vec2 uv = gl_FragCoord.xy;
		gl_FragColor = vec4(uv, 0.0, 1.0);
	}`;

	onMount(() => {
		// Set canvas size to match screen size and device pixel ratio
		canvas.width = window.innerWidth * window.devicePixelRatio;
		canvas.height = window.innerHeight * window.devicePixelRatio;

		gl = canvas.getContext('webgl2');
		if (!gl) {
			console.error('WebGL2 not supported');
			return;
		}
		// Set the viewport to match canvas size and device pixel ratio
		gl.viewport(
			0,
			0,
			canvas.width, //* window.devicePixelRatio,
			canvas.height //* window.devicePixelRatio
		);

		const vertexShader = gl.createShader(gl.VERTEX_SHADER);
		if (!vertexShader) {
			console.error('Failed to create vertex shader');
			return;
		}
		gl.shaderSource(vertexShader, vertexShaderSource);
		gl.compileShader(vertexShader);

		const fragmentShader = gl.createShader(gl.FRAGMENT_SHADER);
		if (!fragmentShader) {
			console.error('Failed to create fragment shader');
			return;
		}
		gl.shaderSource(fragmentShader, fragmentShaderSource);
		gl.compileShader(fragmentShader);

		program = gl.createProgram();
		if (!program) {
			console.error('Failed to create program');
			return;
		}
		gl.attachShader(program, vertexShader);
		gl.attachShader(program, fragmentShader);
		gl.linkProgram(program);

		gl.useProgram(program);

		// Render the scene
		function render() {
			if (!gl || !program) return;
			gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
			requestAnimationFrame(render);
		}
		requestAnimationFrame(render);
	});
</script>

<canvas bind:this={canvas} />

<style>
	canvas {
		top: 0px;
		left: 0px;
		width: 100%;
		height: 100%;
		position: absolute;
		z-index: -1;
	}
</style>
