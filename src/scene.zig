const std = @import("std");
const zm = @import("zmath");
const Renderer = @import("graphics/renderer.zig").Renderer;
const VertexArray = @import("graphics/vertex_array.zig").VertexArray;
const Mesh = @import("graphics/mesh.zig").Mesh;
const Shader = @import("graphics/shader.zig").Shader;
const Entity = @import("graphics/entity.zig").Entity;
const Camera = @import("camera.zig").Camera;
const Cube = @import("objects/cube.zig").Cube;
const Drawable = @import("objects/drawable.zig").Drawable;

pub const Scene = struct {
    allocator: std.mem.Allocator,

    renderer: Renderer,
    camera: Camera,
    cubes: std.ArrayList(Cube),

    pub fn init(allocator: std.mem.Allocator, renderer: Renderer) !Scene {
        const aspect = @as(f32, @floatFromInt(800)) / @as(f32, @floatFromInt(600));

        var scene = Scene{
            .allocator = allocator,
            .renderer = renderer,
            .camera = Camera.init(aspect),
            .cubes = try std.ArrayList(Cube).initCapacity(allocator, 0),
        };

        try scene.cubes.append(allocator, try Cube.init());

        return scene;
    }

    pub fn deinit(self: *Scene) void {
        self.cubes.deinit(self.allocator);
    }

    pub fn update(self: *Scene) void {
        for (self.cubes.items) |*cube| {
            cube.update(&self.camera);
        }
    }

    pub fn draw(self: *Scene) void {
        self.renderer.clear();
        for (self.cubes.items) |*cube| {
            cube.draw(&self.renderer, &self.camera);
        }
    }

    pub fn addCube(self: *Scene) !void {
        try self.cubes.append(self.allocator, try Cube.init());
    }
};
