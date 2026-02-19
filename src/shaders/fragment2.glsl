#version 330 core

varying vec3 v_color;

out vec4 out_color;

void main() {
    out_color = vec4(v_color, 0.6);

    out_color.xyz *= 10;
    out_color.xyz = floor(out_color.xyz);
    out_color.xyz /= 10;
}
