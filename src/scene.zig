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
    cube: Cube,

    pub fn init(allocator: std.mem.Allocator, renderer: Renderer) !Scene {
        const aspect = @as(f32, @floatFromInt(800)) / @as(f32, @floatFromInt(600));

        return Scene{
            .allocator = allocator,
            .renderer = renderer,
            .camera = Camera.init(aspect),
            .cube = try Cube.init(),
        };
    }

    pub fn deinit(self: *Scene) void {
        _ = self;
    }

    pub fn update(self: *Scene) void {
        self.cube.update(&self.camera);
    }

    pub fn draw(self: *Scene) void {
        self.renderer.clear();

        self.cube.draw(&self.renderer, &self.camera);
    }
};
