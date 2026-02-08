#version 330 core

in vec2 v_TexCoords;
out vec4 color;

uniform sampler2D u_Texture;

void main() {
    vec4 tColor = texture(u_Texture, v_TexCoords);
    color = tColor;
}
