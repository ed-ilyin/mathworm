#version 300 es
precision highp float;

uniform vec2 u_resolution;
uniform float u_time;

out vec4 outColor;

vec2 sphIntersect(vec3 ro,vec3 rd,float ra,vec3 pos){
    vec3 newRo=ro-pos;
    float b=dot(newRo,rd);
    float c=dot(newRo,newRo)-ra*ra;
    float h=b*b-c;
    if(h<0.){
        return vec2(-1.);
    }
    h=sqrt(h);
    return vec2(-b-h,-b+h);
}

vec3 castRay(vec2 uv,vec3 ro,vec3 rd){
    vec2 t1=sphIntersect(ro,rd,2.,vec3(4.,-1.,0.));
    vec2 t2=sphIntersect(ro,rd,1.,vec3(0.,.5,0.));
    
    float t=-1.;
    if(t1.x>0.&&(t2.x<0.||t1.x<t2.x)){
        t=t1.x;
    }else if(t2.x>0.&&(t1.x<0.||t2.x<t1.x)){
        t=t2.x;
    }
    
    if(t<0.){
        return vec3(uv.y,uv.x,.5);
    }
    
    vec3 pos=ro+rd*t;
    vec3 nor=normalize(pos);
    vec3 light=normalize(vec3(1.,-2.,-2.));
    float diffuse=-dot(light,nor);
    vec3 col=vec3(diffuse);
    
    return col;
}

void main(){
    vec2 uv=gl_FragCoord.xy/u_resolution-.5;
    float aspectRatio=u_resolution.x/u_resolution.y;
    if(aspectRatio<1.){
        uv.y/=aspectRatio;
    }else{
        uv.x*=aspectRatio;
    }
    vec3 ro=vec3(-4.,0.,0.);
    vec3 rd=normalize(vec3(1.,uv.x,uv.y));
    vec3 col=castRay(uv,ro,rd);
    outColor=vec4(col,1.);
}