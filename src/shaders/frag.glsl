#version 330 core

// in vec2 v_TexCoords;
in vec3 vColor;
out vec4 color;

uniform sampler2D u_Texture;

void main() {
    // vec4 tColor = texture(u_Texture, v_TexCoords);
    vec4 tColor = vec4(vColor, 1.0);
    color = tColor;
}
