const Mesh = @import("mesh.zig").Mesh;
const Shader = @import("shader.zig").Shader;
const Texture = @import("texture.zig").Texture;
const zm = @import("zmath");

pub const Entity = struct {
    mesh: *Mesh,
    shader: *Shader,
    texture: ?*Texture,
    transform: zm.Mat,
};
