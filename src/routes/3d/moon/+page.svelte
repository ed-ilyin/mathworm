<script lang="ts">
	import { onMount } from 'svelte';
	let canvas: HTMLCanvasElement;
	let gl: WebGL2RenderingContext;
	let program: WebGLProgram;
	let requestId = 0;

	const vertexShaderSource = `#version 300 es
    in vec2 a_position;
    void main() { gl_Position = vec4(a_position, 0., 1.); }`;

	const fragmentShaderSource = `#version 300 es
precision highp float;
uniform vec2 u_resolution;
uniform float u_time;
out vec4 outColor;

vec2 sphIntersect(vec3 ro,vec3 rd,float ra){
  float b=dot(ro,rd);
  float c=dot(ro,ro)-ra*ra;
  float h=b*b-c;
  if(h<0.){
    return vec2(-1.);
  }
  h=sqrt(h);
  return vec2(-b-h,-b+h);
}

vec3 castRay(vec3 ro,vec3 rd){
  vec2 t=sphIntersect(ro,rd,1.);
  if(t.x<0.){
    return vec3(rd.y,rd.z,.5);
  }
  vec3 pos=ro+rd*t.x;
  vec3 nor=normalize(pos);
  vec3 light=normalize(vec3(cos(u_time),sin(u_time),sin(u_time)));
  // vec3 light=normalize(vec3(-4));
  float diffuse=dot(light,nor);
  // float specular=pow(max(dot(reflect(rd,nor),light),0.),64.);
  vec3 col=vec3(diffuse);
  return col;
}

void main(){
  vec2 uv=gl_FragCoord.xy/u_resolution-.5;
  float aspectRatio=u_resolution.x/u_resolution.y;
  if(aspectRatio<1.){uv.y/=aspectRatio;}else{uv.x*=aspectRatio;}
  vec3 ro=vec3(-3.,0.,0.);
  vec3 rd=normalize(vec3(1.,uv.x,uv.y));
  vec3 col=castRay(ro,rd);
  outColor=vec4(col,1.);
}`;

	onMount(() => {
		canvas.width = window.innerWidth * window.devicePixelRatio;
		canvas.height = window.innerHeight * window.devicePixelRatio;
		gl = canvas.getContext('webgl2') as WebGL2RenderingContext;
		gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);

		const vertexShader = gl.createShader(gl.VERTEX_SHADER) as WebGLShader;
		gl.shaderSource(vertexShader, vertexShaderSource);
		gl.compileShader(vertexShader);
		if (!gl.getShaderParameter(vertexShader, gl.COMPILE_STATUS)) {
			console.error('Failed to compile vertex shader: ', gl.getShaderInfoLog(vertexShader));
			return;
		}
		const fragmentShader = gl.createShader(gl.FRAGMENT_SHADER) as WebGLShader;
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
		gl.uniform2f(resolutionUniformLocation, gl.canvas.width, gl.canvas.height);

		const timeUniformLocation = gl.getUniformLocation(program, 'u_time');

		function render(time: number) {
			gl.uniform1f(timeUniformLocation, time / 1000);
			gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
			requestId = requestAnimationFrame(render);
		}
		requestId = requestAnimationFrame(render);
		return () => {
			cancelAnimationFrame(requestId);
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
