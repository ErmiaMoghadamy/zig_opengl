#version 330 core

in vec2 vUV;

out vec4 color;

// varying vec3 vColor;

uniform sampler2D uTex;

void main() {
    // color = vec4(vColor, 1.0);
    color = texture(uTex, vUV);
}
