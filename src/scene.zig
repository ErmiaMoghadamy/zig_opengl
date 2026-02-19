const std = @import("std");
const utils = @import("utils.zig");
const Renderer = @import("graphics/renderer.zig").Renderer;
const Shader = @import("graphics/shader.zig").Shader;
const Camera = @import("camera.zig").Camera;
const Cube = @import("objects/cube.zig").Cube;
const Texture = @import("graphics/texture.zig").Texture;
const RenderContext = @import("graphics/render_context.zig").RenderContext;
const Mesh = @import("graphics/mesh.zig").Mesh;

pub const Scene = struct {
    allocator: std.mem.Allocator,
    renderer: *Renderer,
    camera: Camera,

    cubes: std.ArrayList(Cube),
    base_shader: Shader = undefined,
    base_texture: Texture = undefined,
    base_texture2: Texture = undefined,

    m: Mesh,
    ts: Shader,

    pub fn init(allocator: std.mem.Allocator, renderer: *Renderer) !Scene {
        const aspect = @as(f32, @floatFromInt(800)) / @as(f32, @floatFromInt(600));

        const v = [_]f32{
            0.5,  -0.5, 0.0, 1.0, 0.0, 0.0,
            -0.5, -0.5, 0.0, 0.0, 1.0, 0.0,
            0.0,  0.5,  0.0, 0.0, 0.0, 1.0,
        };

        const in = [_]u32{ 0, 1, 2 };

        const l = [_]u32{ 3, 3 };

        return Scene{
            .allocator = allocator,
            .renderer = renderer,
            .cubes = try std.ArrayList(Cube).initCapacity(allocator, 0),
            .camera = Camera.init(aspect),
            .base_shader = try Shader.init(@embedFile("shaders/vertex.glsl"), @embedFile("shaders/fragment.glsl")),
            .base_texture = try Texture.init(allocator, "assets/diamond.png", 0),
            .base_texture2 = try Texture.init(allocator, "assets/dirt.png", 1),
            .m = Mesh.init(&v, &in, &l),
            .ts = try Shader.init(@embedFile("shaders/vertex2.glsl"), @embedFile("shaders/fragment2.glsl")),
        };
    }

    pub fn addCube(self: *Scene) !void {
        const tg = self.camera.target;
        var cube: Cube = undefined;

        const x: f32 = @floatFromInt(utils.genRandom());
        const y: f32 = @floatFromInt(utils.genRandom());

        if (std.crypto.random.boolean()) {
            cube = try Cube.init(
                &self.base_texture,
                &self.base_shader,
            );
        } else {
            cube = try Cube.init(
                &self.base_texture2,
                &self.base_shader,
            );
        }

        cube.transform.setPos(x, tg[1], y);
        try self.cubes.append(self.allocator, cube);
    }

    pub fn deinit(self: *Scene) void {
        for (self.cubes.items) |*cube| {
            cube.deinit();
        }

        self.cubes.deinit(self.allocator);

        self.base_shader.deinit();
        self.base_texture.deinit();
        self.base_texture2.deinit();
    }

    pub fn update(self: *Scene, dt: f64) void {
        for (self.cubes.items) |*cube| {
            cube.update(dt);
        }
    }

    pub fn render(self: *Scene) void {
        self.renderer.clear();
        const context = RenderContext.fromCamera(&self.camera);
        for (self.cubes.items) |*cube| {
            cube.draw(self.renderer, context);
        }

        self.m.bind();
        self.ts.bind();
        self.renderer.drawMesh(&self.m);
    }
};
