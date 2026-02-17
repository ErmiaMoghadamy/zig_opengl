const Shader = @import("shader.zig").Shader;
const Texture = @import("texture.zig").Texture;

pub const Material = struct {
    shader: *Shader,
    texture: *Texture,
    sampler_uniform: [:0]const u8 = "uTex",

    pub fn init(shader: *Shader, texture: *Texture) Material {
        return .{
            .shader = shader,
            .texture = texture,
        };
    }

    pub fn bind(self: Material) void {
        self.shader.bind();
        self.texture.bind();
        self.shader.setu_1i(self.sampler_uniform, self.texture.slot);
    }
};
