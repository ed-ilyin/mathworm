<script lang="ts">
	import { onMount } from 'svelte';
	let canvas: HTMLCanvasElement;
	let gl: WebGL2RenderingContext;
	let program: WebGLProgram;

	const vertexShaderSource = `
    attribute vec2 a_position;
    void main() {
      gl_Position = vec4(a_position, 0.0, 1.0);
    }
  `;

	const fragmentShaderSource = `
	  precision highp float;
	  uniform vec2 u_resolution;
	  void main() {
	    vec2 st = gl_FragCoord.xy / u_resolution;
	    gl_FragColor = vec4(st, 0.5, 1.0);
	  }`;

	onMount(() => {
		canvas.width = window.innerWidth * window.devicePixelRatio;
		canvas.height = window.innerHeight * window.devicePixelRatio;
		gl = canvas.getContext('webgl2') as WebGL2RenderingContext;

		const vertexShader = gl.createShader(gl.VERTEX_SHADER) as WebGLShader;
		gl.shaderSource(vertexShader, vertexShaderSource);
		gl.compileShader(vertexShader);
		if (!gl.getShaderParameter(vertexShader, gl.COMPILE_STATUS)) {
			console.error('Failed to compile vertex shader');
			return;
		}

		const fragmentShader = gl.createShader(gl.FRAGMENT_SHADER) as WebGLShader;
		gl.shaderSource(fragmentShader, fragmentShaderSource);
		gl.compileShader(fragmentShader);
		console.log(gl.getShaderInfoLog(fragmentShader));
		if (!gl.getShaderParameter(fragmentShader, gl.COMPILE_STATUS)) {
			console.error('Failed to compile fragment shader');
			return;
		}

		program = gl.createProgram() as WebGLProgram;
		if (!program) {
			console.error('Failed to create program');
			return;
		}
		gl.attachShader(program, vertexShader);
		gl.attachShader(program, fragmentShader);
		gl.linkProgram(program);

		const positionBuffer = gl.createBuffer();
		gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
		gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 1, -1, -1, 1, 1, 1]), gl.STATIC_DRAW);

		const positionAttributeLocation = gl.getAttribLocation(program, 'a_position');
		gl.enableVertexAttribArray(positionAttributeLocation);
		gl.vertexAttribPointer(positionAttributeLocation, 2, gl.FLOAT, false, 0, 0);

		gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);
		const resolutionUniformLocation = gl.getUniformLocation(program, 'u_resolution');
		gl.useProgram(program);
		gl.uniform2f(resolutionUniformLocation, gl.canvas.width, gl.canvas.height);

		gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
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
