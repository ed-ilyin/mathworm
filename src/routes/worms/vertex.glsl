#version 300 es
precision mediump float;

in vec2 v_texcoord;
out vec4 fragColor;

void main(){
  vec2 uv=v_texcoord.xy;
  fragColor=vec4(uv,.5,1.);
}