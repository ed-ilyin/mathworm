#version 300 es
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
    return vec3(rd.z,rd.y,1.);
  }
  vec3 pos=ro+rd*t.x;
  vec3 nor=normalize(pos);
  vec3 light=normalize(vec3(cos(u_time*2.),sin(u_time*2.),sin(u_time)));
  float diffuse=dot(light,nor);
  // float specular=pow(max(dot(reflect(rd,nor),light),0.),64.);
  vec3 col=vec3(diffuse);
  return col;
}

void main(){
  vec2 uv=gl_FragCoord.xy/u_resolution-vec2(.5);
  uv.x*=u_resolution.x/u_resolution.y;
  vec3 ro=vec3(-3.,0.,0.);
  vec3 rd=normalize(vec3(1.,uv.x,uv.y));
  vec3 col=castRay(ro,rd);
  outColor=vec4(col,1.);
}
