#version 330 core

varying vec3 v_color;

out vec4 out_color;

void main() {
    out_color = vec4(cos(v_color * 10), 0.4);
}
