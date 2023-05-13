#version 300 es
precision highp float;
uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_mouse;
out vec4 outColor;

void main(){
    // vec2 uv=gl_FragCoord.xy/u_resolution-.5;
    // float aspectRatio=u_resolution.x/u_resolution.y;
    // if(aspectRatio<1.){uv.y/=aspectRatio;}else{uv.x*=aspectRatio;}
    // outColor=vec3(sin(u_time)/2.+.5,sin(u_time*2.)/2.+.5,sin(u_time/2.)/2.+.5);
    // outColor=vec3(sin(u_time+uv.x)/2.+.5,sin(u_time*2.+uv.y)/2.+.5,sin(u_time/2.+uv.x)/2.+.5);
    // draw line each 0.1
    vec2 m=round(mod(gl_FragCoord.xy,100.));
    outColor=m.x==0.||m.y==0.?vec4(0.,0.,0.,1.):vec4(u_mouse.x/u_resolution.x,u_mouse.y/u_resolution.y,0.,1.);
}