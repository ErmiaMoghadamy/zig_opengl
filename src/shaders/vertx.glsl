#version 330 core

layout(location = 0) in vec3 aPos;
layout(location = 1) in vec2 tCoord;

out vec2 v_TexCoords;
out vec3 vColor;

uniform mat4 u_MPV;

void main() {
    gl_Position = u_MPV * vec4(aPos, 1.0);
    v_TexCoords = tCoord;
}
