<script lang="ts">
	import { onMount } from 'svelte';
	let canvas: HTMLCanvasElement;
	let gl: WebGL2RenderingContext;
	let program: WebGLProgram;
	let requestId = 0;

	const vertexShaderSource = `#version 300 es
    in vec2 a_position;
    void main() { gl_Position = vec4(a_position, 0., 1.); }`;

	function updateCanvasSize() {
		canvas.width = window.innerWidth * window.devicePixelRatio;
		canvas.height = window.innerHeight * window.devicePixelRatio;
		gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);
	}

	onMount(async () => {
		gl = canvas.getContext('webgl2') as WebGL2RenderingContext;
		updateCanvasSize();
		window.addEventListener('resize', updateCanvasSize);

		const vertexShader = gl.createShader(gl.VERTEX_SHADER) as WebGLShader;
		gl.shaderSource(vertexShader, vertexShaderSource);
		gl.compileShader(vertexShader);
		if (!gl.getShaderParameter(vertexShader, gl.COMPILE_STATUS)) {
			console.error('Failed to compile vertex shader: ', gl.getShaderInfoLog(vertexShader));
			return;
		}
		const fragmentShader = gl.createShader(gl.FRAGMENT_SHADER) as WebGLShader;
		let fragmentShaderSource = await fetch('moon2.frag').then((res) => res.text());
		gl.shaderSource(fragmentShader, fragmentShaderSource);
		gl.compileShader(fragmentShader);
		if (!gl.getShaderParameter(fragmentShader, gl.COMPILE_STATUS)) {
			console.error('Failed to compile fragment shader: ', gl.getShaderInfoLog(fragmentShader));
			return;
		}
		program = gl.createProgram() as WebGLProgram;
		gl.attachShader(program, vertexShader);
		gl.attachShader(program, fragmentShader);
		gl.linkProgram(program);
		if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
			console.error('Failed to link program: ', gl.getProgramInfoLog(program));
			return;
		}

		const positionBuffer = gl.createBuffer();
		gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
		gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 1, -1, -1, 1, 1, 1]), gl.STATIC_DRAW);

		const positionAttributeLocation = gl.getAttribLocation(program, 'a_position');
		gl.enableVertexAttribArray(positionAttributeLocation);
		gl.vertexAttribPointer(positionAttributeLocation, 2, gl.FLOAT, false, 0, 0);

		const resolutionUniformLocation = gl.getUniformLocation(program, 'u_resolution');
		gl.useProgram(program);

		const timeUniformLocation = gl.getUniformLocation(program, 'u_time');

		function render(time: number) {
			gl.uniform2f(resolutionUniformLocation, gl.canvas.width, gl.canvas.height);
			gl.uniform1f(timeUniformLocation, time / 1000);
			gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
			requestId = requestAnimationFrame(render);
		}
		requestId = requestAnimationFrame(render);
		return () => {
			cancelAnimationFrame(requestId);
			window.removeEventListener('resize', updateCanvasSize);
			gl.deleteProgram(program);
			gl.deleteShader(fragmentShader);
			gl.deleteShader(vertexShader);
			gl.deleteBuffer(positionBuffer);
		};
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
