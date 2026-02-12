const std = @import("std");
const zm = @import("zmath");
const utils = @import("utils.zig");
const Renderer = @import("graphics/renderer.zig").Renderer;
const Mesh = @import("graphics/mesh.zig").Mesh;
const Shader = @import("graphics/shader.zig").Shader;
const Camera = @import("camera.zig").Camera;
const Cube = @import("objects/cube.zig").Cube;

pub const Scene = struct {
    allocator: std.mem.Allocator,
    renderer: *Renderer,
    camera: Camera,

    cube: Cube,

    pub fn init(allocator: std.mem.Allocator, renderer: *Renderer) !Scene {
        const aspect = @as(f32, @floatFromInt(800)) / @as(f32, @floatFromInt(600));
        return Scene{
            .allocator = allocator,
            .renderer = renderer,
            .cube = try Cube.init(),
            .camera = Camera.init(aspect),
        };
    }

    pub fn deinit(self: *Scene) void {
        _ = self;
    }

    pub fn update(self: *Scene, dt: f64) void {
        _ = dt;
        // self.cube.model = zm.mul(self.cube.model, zm.translation(0.0, @as(f32, @floatCast(dt * 1.5)), 0.0));
        self.cube.update(&self.camera);
    }

    pub fn render(self: *Scene) void {
        self.renderer.clear();
        self.cube.draw(self.renderer);
    }
};
