const Mesh = @import("../graphics/mesh.zig").Mesh;
const Shader = @import("../graphics/shader.zig").Shader;
const Renderer = @import("../graphics/renderer.zig").Renderer;
const Camera = @import("../camera.zig").Camera;
const zm = @import("zmath");
const utils = @import("../utils.zig");

pub const Cube = struct {
    mesh: Mesh,
    shader: Shader,
    rotation: f32,
    position: [3]f32,

    pub fn init() !Cube {
        const vertices = [_]f32{
            -0.5, -0.5, -0.5, 1.0, 0.0, 0.0,
            0.5,  -0.5, -0.5, 0.0, 0.0, 1.0,
            0.5,  0.5,  -0.5, 0.0, 1.0, 0.0,
            -0.5, 0.5,  -0.5, 1.0, 0.0, 1.0,
            -0.5, -0.5, 0.5,  1.0, 1.0, 0.0,
            0.5,  -0.5, 0.5,  0.0, 1.0, 1.0,
            0.5,  0.5,  0.5,  0.0, 0.0, 0.0,
            -0.5, 0.5,  0.5,  1.0, 1.0, 1.0,
        };

        const indices = [_]u32{
            0, 1, 2, 2, 3, 0,
            4, 5, 6, 6, 7, 4,
            0, 4, 5, 5, 1, 0,
            1, 5, 6, 6, 2, 1,
            2, 6, 7, 7, 3, 2,
            3, 7, 4, 4, 0, 3,
        };

        const layout = [_]u32{ 3, 3 };

        return Cube{
            .rotation = 0.0,
            .position = [3]f32{ 0.0, 0.0, 0.0 },
            .mesh = Mesh.init(&vertices, &indices, &layout),
            .shader = try Shader.init(
                @embedFile("../shaders/vert2.glsl"),
                @embedFile("../shaders/frag2.glsl"),
            ),
        };
    }

    pub fn getMvp(self: Cube, camera: *Camera) [16]f32 {
        const view = camera.view;
        const projection = camera.projection;
        const r1 = zm.rotationX(self.rotation);
        const r2 = zm.rotationY(self.rotation);
        const r3 = zm.rotationZ(0);
        const r = zm.mul(r1, zm.mul(r2, r3));
        const moves = zm.translation(self.position[0], self.position[1], self.position[2]);
        const model = zm.mul(r, moves);

        return utils.mat2arr(zm.mul(zm.mul(model, view), projection));
    }

    pub fn move(self: *Cube, r: f32) void {
        self.position[0] = r;
        // self.position[1] += r;
    }

    pub fn update(self: *Cube, camera: *Camera) void {
        self.rotation += 0.01;
        self.shader.setu_mvp(self.getMvp(camera));
    }

    pub fn draw(self: *Cube, renderer: *Renderer, camera: *Camera) void {
        _ = camera;
        renderer.drawMesh(self.mesh, self.shader);
    }
};
