#version 300 es

precision highp float;

uniform vec2 u_resolution;
in vec2 v_texCoord;
out vec4 outColor;

vec2 sphIntersect(vec3 ro, vec3 rd, float ra) {
  float b = dot(ro, rd);
  float c = dot(ro, ro) - ra * ra;
  float h = b * b - c;
  if (h < 0.0) {
    return vec2(-1.0);
  }
  h = sqrt(h);
  return vec2(-b - h, -b + h);
}

vec3 castRay(vec3 ro, vec3 rd) {
  vec2 t = sphIntersect(ro, rd, 1.0);
  if (t.x < 0.0) {
    return vec3(0.0);
  }
  vec3 pos = ro + rd * t.x;
  vec3 nor = normalize(pos);
  return vec3(1.0) * pow(1.0 - abs(nor.y), 2.0);
}

void main() {
  vec2 p = (v_texCoord.xy / u_resolution.xy - 0.5) * 2.0;
  vec3 ro = vec3(0.0, 0.0, -2.0);
  vec3 rd = normalize(vec3(p, -1.0));
  vec3 col = castRay(ro, rd);
  outColor = vec4(col, 1.0);
}
