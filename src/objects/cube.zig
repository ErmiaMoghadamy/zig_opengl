const Mesh = @import("../graphics/mesh.zig").Mesh;
const Shader = @import("../graphics/shader.zig").Shader;
const Renderer = @import("../graphics/renderer.zig").Renderer;
const Camera = @import("../camera.zig").Camera;
const zm = @import("zmath");
const utils = @import("../utils.zig");

pub const Cube = struct {
    mesh: Mesh,
    shader: Shader,
    position: [3]f32,
    init_rot: f32,

    pub fn init(i: f32, j: f32, k: f32, g: bool) !Cube {
        var vertices: [48]f32 = undefined;
        if (g) {
            vertices = [_]f32{
                -0.5, -0.5, -0.5, 0.269, 0.542, 0.449,
                0.5,  -0.5, -0.5, 0.269, 0.542, 0.449,
                0.5,  0.5,  -0.5, 0.269, 0.542, 0.449,
                -0.5, 0.5,  -0.5, 0.269, 0.542, 0.449,
                -0.5, -0.5, 0.5,  0.269, 0.542, 0.449,
                0.5,  -0.5, 0.5,  0.269, 0.542, 0.449,
                0.5,  0.5,  0.5,  0.269, 0.542, 0.449,
                -0.5, 0.5,  0.5,  0.269, 0.542, 0.449,
            };
        } else {
            vertices = [_]f32{
                -0.5, -0.5, -0.5, 0.0, 1.0, 0.0,
                0.5,  -0.5, -0.5, 0.0, 0.0, 1.0,
                0.5,  0.5,  -0.5, 0.0, 1.0, 0.0,
                -0.5, 0.5,  -0.5, 0.0, 1.0, 1.0,
                -0.5, -0.5, 0.5,  1.0, 0.0, 0.0,
                0.5,  -0.5, 0.5,  0.0, 1.0, 1.0,
                0.5,  0.5,  0.5,  1.0, 1.0, 0.0,
                -0.5, 0.5,  0.5,  1.0, 1.0, 1.0,
            };
        }

        const indices = [_]u32{
            0, 1, 2, 2, 3, 0,
            4, 5, 6, 6, 7, 4,
            0, 4, 5, 5, 1, 0,
            1, 5, 6, 6, 2, 1,
            2, 6, 7, 7, 3, 2,
            3, 7, 4, 4, 0, 3,
        };

        const layout = [_]u32{ 3, 3 };

        const calc_x: f32 = 1.0 * i;
        const calc_y: f32 = 1.0 * j;
        const calc_z: f32 = 1.0 * k;

        return Cube{
            .init_rot = 0.0,
            .position = [3]f32{ calc_x, calc_y, calc_z },
            .mesh = Mesh.init(&vertices, &indices, &layout),
            .shader = try Shader.init(
                @embedFile("../shaders/vert.glsl"),
                @embedFile("../shaders/frag.glsl"),
            ),
        };
    }

    pub fn getMvp(self: Cube, camera: *Camera) [16]f32 {
        const view = camera.view;
        const projection = camera.projection;
        const moves = zm.translation(self.position[0], self.position[1], self.position[2]);
        const model = zm.mul(zm.mul(zm.rotationZ(self.init_rot), zm.rotationY(self.init_rot)), moves);

        return utils.mat2arr(zm.mul(zm.mul(model, view), projection));
    }

    pub fn update(self: *Cube, camera: *Camera) void {
        self.shader.setu_mvp(self.getMvp(camera));
    }

    pub fn draw(self: *Cube, renderer: *Renderer, camera: *Camera) void {
        _ = camera;
        renderer.drawMesh(self.mesh, self.shader);
    }
};
