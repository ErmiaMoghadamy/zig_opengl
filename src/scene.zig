const zm = @import("zmath");
const Renderer = @import("graphics/renderer.zig").Renderer;
const VertexArray = @import("graphics/vertex_array.zig").VertexArray;
const Mesh = @import("graphics/mesh.zig").Mesh;
const Shader = @import("graphics/shader.zig").Shader;
const Camera = @import("camera.zig").Camera;

pub const Scene = struct {
    vao: VertexArray,
    shader: Shader,
    renderer: Renderer,
    camera: Camera,

    rot: f32,

    pub fn init(renderer: Renderer) !Scene {
        const vt = [_]f32{
            -0.5, -0.5, -0.5, 1.0, 0.0, 0.0,
            0.5,  -0.5, -0.5, 0.0, 1.0, 0.0,
            0.5,  0.5,  -0.5, 0.0, 0.0, 1.0,
            -0.5, 0.5,  -0.5, 1.0, 1.0, 0.0,
            -0.5, -0.5, 0.5,  1.0, 0.0, 1.0,
            0.5,  -0.5, 0.5,  0.0, 1.0, 1.0,
            0.5,  0.5,  0.5,  1.0, 1.0, 1.0,
            -0.5, 0.5,  0.5,  0.2, 0.2, 0.2,
        };
        const ib = [_]u32{
            0, 1, 2,
            2, 3, 0,
            4, 6, 5,
            6, 4, 7,
            0, 3, 7,
            7, 4, 0,
            1, 5, 6,
            6, 2, 1,
            0, 4, 5,
            5, 1, 0,
            3, 2, 6,
            6, 7, 3,
        };
        const li = [_]u32{ 3, 3 };

        const aspect = @as(f32, @floatFromInt(800)) / @as(f32, @floatFromInt(600));

        return .{
            .vao = VertexArray.init(&vt, &ib, &li),
            .shader = try Shader.init(@embedFile("shaders/vert2.glsl"), @embedFile("shaders/frag2.glsl")),
            .renderer = renderer,
            .camera = Camera.init(aspect),
            .rot = 0.0,
        };
    }

    fn get_mvp(self: *Scene) [16]f32 {
        const r1 = zm.rotationX(self.rot * 0.02);
        const r2 = zm.rotationY(self.rot * 0.03);
        const r3 = zm.rotationZ(-self.rot * 0.06);

        const model = zm.mul(zm.mul(r3, r2), r1);

        const mvp_rm = zm.mul(zm.mul(model, self.camera.view), self.camera.projection);

        var mvp_array: [16]f32 = undefined;

        zm.storeMat(&mvp_array, mvp_rm);

        return mvp_array;
    }

    pub fn update(self: *Scene) void {
        self.rot = self.rot + 0.01;
        self.shader.setu_mvp(self.get_mvp());
    }

    pub fn draw(self: *Scene) void {
        self.renderer.clear();
        self.shader.bind();
        self.renderer.draw(self.vao, self.shader);
    }
};
