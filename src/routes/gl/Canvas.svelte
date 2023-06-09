<script lang="ts">
	import { onMount } from 'svelte';
	export let shaderFileName = 'moon.frag';
	let canvas: HTMLCanvasElement;
	let gl: WebGL2RenderingContext;
	let fragmentShader: WebGLShader | undefined = undefined;
	let program: WebGLProgram;
	let requestId = 0;
	let ulMouse: WebGLUniformLocation | null = null;
	let ulResolution: WebGLUniformLocation | null = null;

	const vertexShaderSource = `#version 300 es
    in vec2 a_position;
    void main() { gl_Position = vec4(a_position, 0., 1.); }`;

	async function reloadFragmentShader(oldFragmentShader: WebGLShader | undefined) {
		let frag = await fetch(shaderFileName);
		let fragmentShaderSource = await frag.text();
		if (oldFragmentShader) gl.deleteShader(oldFragmentShader);
		const fragmentShader = gl.createShader(gl.FRAGMENT_SHADER) as WebGLShader;
		gl.shaderSource(fragmentShader, fragmentShaderSource);
		gl.compileShader(fragmentShader);
		if (!gl.getShaderParameter(fragmentShader, gl.COMPILE_STATUS)) {
			console.error('Failed to compile fragment shader: ', gl.getShaderInfoLog(fragmentShader));
			return;
		}
		gl.attachShader(program, fragmentShader);
		if (gl.getShaderInfoLog(fragmentShader)) {
			console.log(gl.getShaderInfoLog(fragmentShader));
		}
		gl.linkProgram(program);
		if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
			console.error('Failed to link program: ', gl.getProgramInfoLog(program));
			return;
		}
		return fragmentShader;
	}
	async function load(): Promise<[WebGLShader, WebGLBuffer | null] | undefined> {
		gl = canvas.getContext('webgl2') as WebGL2RenderingContext;
		const vertexShader = gl.createShader(gl.VERTEX_SHADER) as WebGLShader;
		gl.shaderSource(vertexShader, vertexShaderSource);
		gl.compileShader(vertexShader);
		if (!gl.getShaderParameter(vertexShader, gl.COMPILE_STATUS)) {
			console.error('Failed to compile vertex shader: ', gl.getShaderInfoLog(vertexShader));
			return;
		}
		program = gl.createProgram() as WebGLProgram;
		if (gl.getShaderInfoLog(vertexShader)) {
			console.log(gl.getShaderInfoLog(vertexShader));
		}
		if (gl.getProgramInfoLog(program)) {
			console.log(gl.getProgramInfoLog(program));
		}
		gl.attachShader(program, vertexShader);
		fragmentShader = await reloadFragmentShader(fragmentShader);
		gl.useProgram(program);

		const positionBuffer = gl.createBuffer();
		gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
		gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 1, -1, -1, 1, 1, 1]), gl.STATIC_DRAW);
		const positionAttributeLocation = gl.getAttribLocation(program, 'a_position');
		gl.enableVertexAttribArray(positionAttributeLocation);
		gl.vertexAttribPointer(positionAttributeLocation, 2, gl.FLOAT, false, 0, 0);

		ulResolution = gl.getUniformLocation(program, 'u_resolution');
		const ulTime = gl.getUniformLocation(program, 'u_time');
		ulMouse = gl.getUniformLocation(program, 'u_mouse');
		function render(time: number) {
			gl.uniform1f(ulTime, time / 1000);
			gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
			requestId = requestAnimationFrame(render);
		}
		requestId = requestAnimationFrame(render);
		return [vertexShader, positionBuffer];
	}
	function updateCanvasSize() {
		canvas.width = window.innerWidth * window.devicePixelRatio;
		canvas.height = window.innerHeight * window.devicePixelRatio;
		gl.viewport(-1, 0, gl.canvas.width, gl.canvas.height);
		gl.uniform2f(ulResolution, gl.canvas.width, gl.canvas.height);
	}
	function updateMousePosition(e: MouseEvent) {
		gl.uniform2f(ulMouse, e.clientX, e.clientY);
	}
	onMount(async () => {
		const result = await load();
		if (result) {
			const [vertexShader, positionBuffer] = result;
		}
		updateCanvasSize();
		window.addEventListener('resize', updateCanvasSize);
		window.addEventListener('mousemove', updateMousePosition);

		return () => {
			cancelAnimationFrame(requestId);
			window.removeEventListener('resize', updateCanvasSize);
			window.removeEventListener('mousemove', updateMousePosition);
			gl.deleteProgram(program);
			if (fragmentShader) gl.deleteShader(fragmentShader);
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
