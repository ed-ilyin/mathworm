#version 300 es
precision highp float;
uniform float u_time;// The current time in seconds
uniform vec2 u_resolution;// The size of the canvas
out vec3 outColor;

float rand(vec2 co){
  return fract(sin(dot(co,vec2(12.9898,78.233)))*43758.5453);
}

void main(){
  vec2 uv=gl_FragCoord.xy/u_resolution;
  float x=rand(uv);
  float y=rand(vec2(x,u_time));
  float z=rand(vec2());
  outColor=vec3(x,y,z);
}
