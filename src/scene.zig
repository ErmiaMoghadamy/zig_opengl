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

    cubes: std.ArrayList(Cube),

    pub fn init(allocator: std.mem.Allocator, renderer: *Renderer) !Scene {
        const aspect = @as(f32, @floatFromInt(800)) / @as(f32, @floatFromInt(600));
        var scene = Scene{
            .allocator = allocator,
            .renderer = renderer,
            .cubes = try std.ArrayList(Cube).initCapacity(allocator, 0),
            .camera = Camera.init(aspect),
        };

        for (0..7) |i| {
            var x: i32 = @intCast(i);
            x -= 3;
            for (0..7) |j| {
                var y: i32 = @intCast(j);
                y -= 3;
                var cube = try Cube.init("dirt", 0);
                cube.transform.setPos(@floatFromInt(x), 0.0, @floatFromInt(y));
                try scene.cubes.append(allocator, cube);
            }
        }

        var cube = try Cube.init("diamond", 0);
        cube.transform.setPos(0.0, 1.0, 0.0);
        try scene.cubes.append(allocator, cube);

        return scene;
    }

    pub fn addCube(self: *Scene) !void {
        const r1 = utils.genRandom();
        const r2 = utils.genRandom();
        var cube = try Cube.init("diamond", 0);
        cube.transform.setPos(@floatFromInt(r1), 1.0, @floatFromInt(r2));
        try self.cubes.append(self.allocator, cube);
    }

    pub fn deinit(self: *Scene) void {
        self.cubes.deinit(self.allocator);
    }

    pub fn update(self: *Scene, dt: f64) void {
        for (self.cubes.items) |*cube| {
            cube.update(dt);
        }
    }

    pub fn render(self: *Scene) void {
        self.renderer.clear();
        for (self.cubes.items) |*cube| {
            cube.draw(self.renderer, &self.camera);
        }
    }
};
