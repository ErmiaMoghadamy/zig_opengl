const std = @import("std");
const Mesh = @import("../graphics/mesh.zig").Mesh;
const Shader = @import("../graphics/shader.zig").Shader;
const Renderer = @import("../graphics/renderer.zig").Renderer;
const Camera = @import("../camera.zig").Camera;
const Texture = @import("../graphics/texture.zig").Texture;
const zm = @import("zmath");
const utils = @import("../utils.zig");

pub const Cube = struct {
    mesh: Mesh,
    shader: Shader,
    texture: Texture,
    model: zm.Mat,

    pub fn init() !Cube {
        const vertices = [_]f32{
            -0.5, -0.5, 0.5,  0.0, 0.0,
            0.5,  -0.5, 0.5,  1.0, 0.0,
            0.5,  0.5,  0.5,  1.0, 1.0,
            -0.5, 0.5,  0.5,  0.0, 1.0,
            -0.5, -0.5, -0.5, 1.0, 0.0,
            -0.5, 0.5,  -0.5, 1.0, 1.0,
            0.5,  0.5,  -0.5, 0.0, 1.0,
            0.5,  -0.5, -0.5, 0.0, 0.0,
            -0.5, -0.5, -0.5, 0.0, 0.0,
            -0.5, -0.5, 0.5,  1.0, 0.0,
            -0.5, 0.5,  0.5,  1.0, 1.0,
            -0.5, 0.5,  -0.5, 0.0, 1.0,
            0.5,  -0.5, -0.5, 1.0, 0.0,
            0.5,  0.5,  -0.5, 1.0, 1.0,
            0.5,  0.5,  0.5,  0.0, 1.0,
            0.5,  -0.5, 0.5,  0.0, 0.0,
            -0.5, -0.5, -0.5, 0.0, 1.0,
            0.5,  -0.5, -0.5, 1.0, 1.0,
            0.5,  -0.5, 0.5,  1.0, 0.0,
            -0.5, -0.5, 0.5,  0.0, 0.0,
            -0.5, 0.5,  -0.5, 0.0, 0.0,
            -0.5, 0.5,  0.5,  0.0, 1.0,
            0.5,  0.5,  0.5,  1.0, 1.0,
            0.5,  0.5,  -0.5, 1.0, 0.0,
        };

        const indices = [_]u32{
            0,  1,  2,  2,  3,  0,
            4,  5,  6,  6,  7,  4,
            8,  9,  10, 10, 11, 8,
            12, 13, 14, 14, 15, 12,
            16, 17, 18, 18, 19, 16,
            20, 21, 22, 22, 23, 20,
        };

        const layout = [_]u32{ 3, 2 };

        return Cube{
            .model = zm.identity(),
            .mesh = Mesh.init(&vertices, &indices, &layout),
            .shader = try Shader.init(
                @embedFile("../shaders/vertex.glsl"),
                @embedFile("../shaders/fragment.glsl"),
            ),
            .texture = try Texture.init(std.heap.raw_c_allocator, "./assets/swastika.png"),
        };
    }

    pub fn getModel(self: Cube) zm.Mat {
        return self.model;
    }

    pub fn update(self: *Cube, camera: *Camera) void {
        self.texture.bind(0);
        self.shader.setu_1i("uTexture", 0);
        self.shader.setu_mat("uModel", utils.mat2arr(self.getModel()));
        self.shader.setu_mat("uView", utils.mat2arr(camera.view));
        self.shader.setu_mat("uProjection", utils.mat2arr(camera.projection));
    }

    pub fn draw(self: *Cube, renderer: *Renderer) void {
        renderer.drawMesh(&self.mesh, &self.shader);
    }
};
