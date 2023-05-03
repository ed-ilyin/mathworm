#version 300 es
precision highp float;
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform vec3 u_camera;
uniform float u_time;
uniform sampler2D u_sample;
uniform float u_sample_part;
uniform vec2 u_seed1;
uniform vec2 u_seed2;
out vec4 outColor;

const float MAX_DIST=99999.;
const int MAX_REF=8;
vec3 light=normalize(vec3(-.5,.75,-1.));

uvec4 R_STATE;

uint TausStep(uint z,int S1,int S2,int S3,uint M)
{
  uint b=(((z<<S1)^z)>>S2);
  return(((z&M)<<S3)^b);
}

uint LCGStep(uint z,uint A,uint C)
{
  return(A*z+C);
}

vec2 hash22(vec2 p)
{
  p+=u_seed1.x;
  vec3 p3=fract(vec3(p.xyx)*vec3(.1031,.1030,.0973));
  p3+=dot(p3,p3.yzx+33.33);
  return fract((p3.xx+p3.yz)*p3.zy);
}

float random()
{
  R_STATE.x=TausStep(R_STATE.x,13,19,12,uint(4294967294));
  R_STATE.y=TausStep(R_STATE.y,2,25,4,uint(4294967288));
  R_STATE.z=TausStep(R_STATE.z,3,11,17,uint(4294967280));
  R_STATE.w=LCGStep(R_STATE.w,uint(1664525),uint(1013904223));
  return 2.3283064365387e-10*float((R_STATE.x^R_STATE.y^R_STATE.z^R_STATE.w));
}

vec3 randomOnSphere(){
  vec3 rand=vec3(random(),random(),random());
  float theta=rand.x*2.*3.14159265;
  float v=rand.y;
  float phi=acos(2.*v-1.);
  float r=pow(rand.z,1./3.);
  float x=r*sin(phi)*cos(theta);
  float y=r*sin(phi)*sin(theta);
  float z=r*cos(phi);
  return vec3(x,y,z);
}

mat2 rot(float a){
  float s=sin(a);
  float c=cos(a);
  return mat2(c,-s,s,c);
}

vec2 sphIntersect(in vec3 ro,in vec3 rd,float ra){
  float b=dot(ro,rd);
  float c=dot(ro,ro)-ra*ra;
  float h=b*b-c;
  if(h<0.)return vec2(-1.);
  h=sqrt(h);
  return vec2(-b-h,-b+h);
}

vec2 boxIntersection(in vec3 ro,in vec3 rd,in vec3 rad,out vec3 oN){
  vec3 m=1./rd;
  vec3 n=m*ro;
  vec3 k=abs(m)*rad;
  vec3 t1=-n-k;
  vec3 t2=-n+k;
  float tN=max(max(t1.x,t1.y),t1.z);
  float tF=min(min(t2.x,t2.y),t2.z);
  if(tN>tF||tF<0.)return vec2(-1.);
  oN=-sign(rd)*step(t1.yzx,t1.xyz)*step(t1.zxy,t1.xyz);
  return vec2(tN,tF);
}

float plaIntersect(in vec3 ro,in vec3 rd,in vec4 p){
  return-(dot(ro,p.xyz)+p.w)/dot(rd,p.xyz);
}

vec3 getSky(vec3 rd){
  vec3 col=vec3(.3,.6,1.);
  vec3 sun=vec3(.95,.9,1.);
  // vec3 light=normalize(vec3(cos(u_time),sin(u_time),sin(u_time)));
  sun*=max(0.,pow(dot(rd,light),256.));
  col*=max(0.,dot(light,vec3(0.,0.,-1.)));
  return clamp(sun+col*.01,0.,1.);
}

vec4 castRay(inout vec3 ro,inout vec3 rd){
  vec4 col;
  vec2 minIt=vec2(MAX_DIST);
  vec2 it;
  vec3 n;
  mat2x4 spheres[6];
  spheres[0][0]=vec4(-1.,0.,-.01,1.);
  spheres[1][0]=vec4(0.,3.,-.01,1.);
  spheres[2][0]=vec4(1.,-2.,-.01,1.);
  spheres[3][0]=vec4(3.5,-1.,.5,.5);
  spheres[4][0]=vec4(-3.5,-1.,0.,.5);
  spheres[5][0]=vec4(-5.5,-.5,-.01,1.);
  spheres[0][1]=vec4(1.,1.,1.,-.5);
  spheres[1][1]=vec4(1.,1.,1.,.5);
  spheres[2][1]=vec4(1.,0.,.5,1.);
  spheres[3][1]=vec4(1.,1.,1.,-2.);
  spheres[4][1]=vec4(.5,1.,.5,-2.);
  spheres[5][1]=vec4(.5,.5,.5,0.);
  for(int i=0;i<spheres.length();i++){
    it=sphIntersect(ro-spheres[i][0].xyz,rd,spheres[i][0].w);
    if(it.x>0.&&it.x<minIt.x){
      minIt=it;
      vec3 itPos=ro+rd*it.x;
      n=normalize(itPos-spheres[i][0].xyz);
      col=spheres[i][1];
    }
  }
  vec3 boxN;
  vec3 boxPos=vec3(3.,1.,-.001);
  it=boxIntersection(ro-boxPos,rd,vec3(1.),boxN);
  if(it.x>0.&&it.x<minIt.x){
    minIt=it;
    n=boxN;
    col=vec4(.9,.2,.2,-.5);
  }
  vec3 planeNormal=vec3(0.,0.,-1.);
  it=vec2(plaIntersect(ro,rd,vec4(planeNormal,1.)));
  if(it.x>0.&&it.x<minIt.x){
    minIt=it;
    n=planeNormal;
    col=vec4(.8431,.3843,.1176,.01);
  }
  if(minIt.x==MAX_DIST)return vec4(getSky(rd),-2.);
  if(col.a==-2.)return col;
  vec3 reflected=reflect(rd,n);
  if(col.a<0.){
    float fresnel=1.-abs(dot(-rd,n));
    if(random()-.1<fresnel*fresnel){
      rd=reflected;
      return col;
    }
    ro+=rd*(minIt.y+.001);
    rd=refract(rd,n,1./(1.-col.a));
    return col;
  }
  vec3 itPos=ro+rd*it.x;
  vec3 r=randomOnSphere();
  vec3 diffuse=normalize(r*dot(r,n));
  ro+=rd*(minIt.x-.001);
  rd=mix(diffuse,reflected,col.a);
  return col;
}

vec3 traceRay(vec3 ro,vec3 rd){
  vec3 col=vec3(1.);
  for(int i=0;i<MAX_REF;i++)
  {
    vec4 refCol=castRay(ro,rd);
    col*=refCol.rgb;
    if(refCol.a==-2.)return col;
  }
  return vec3(0.);
}

void main(){
  vec2 texCoord=gl_FragCoord.xy/u_resolution;
  texCoord.y=1.-texCoord.y;
  vec2 uv=(texCoord-.5)*u_resolution/u_resolution.y;
  vec2 uvRes=hash22(uv+1.)*u_resolution+u_resolution;
  // R_STATE.x=uint(u_seed1.x+uvRes.x);
  // R_STATE.y=uint(u_seed1.y+uvRes.x);
  // R_STATE.z=uint(u_seed2.x+uvRes.y);
  // R_STATE.w=uint(u_seed2.y+uvRes.y);
  R_STATE.x=uint(u_time+uvRes.x);
  R_STATE.y=uint(u_time+uvRes.x);
  R_STATE.z=uint(u_time+uvRes.y);
  R_STATE.w=uint(u_time+uvRes.y);
  // vec3 rayOrigin=u_camera;
  vec3 rayOrigin=vec3(-15.,0.,0.);
  vec3 rayDirection=normalize(vec3(1.,uv));
  // rayDirection.zx*=rot(-u_mouse.y);
  // rayDirection.xy*=rot(u_mouse.x);
  vec3 col=vec3(0.);
  int samples=4;
  for(int i=0;i<samples;i++){
    col+=traceRay(rayOrigin,rayDirection);
  }
  col/=vec3(samples);
  float white=20.;
  col*=white*16.;
  col=(col*(1.+col/white/white))/(1.+col);
  vec3 sampleCol=texture(u_sample,texCoord).rgb;
  // col=mix(sampleCol,col,u_sample_part);
  col=mix(sampleCol,col,vec3(.5));
  outColor=vec4(col,1.);
  // outColor=vec4(texCoord/u_resolution,1.,1.);
}