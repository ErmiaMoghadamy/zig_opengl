const std = @import("std");
const zm = @import("zmath");
const utils = @import("utils.zig");
const Renderer = @import("graphics/renderer.zig").Renderer;
const Mesh = @import("graphics/mesh.zig").Mesh;
const Shader = @import("graphics/shader.zig").Shader;
const Camera = @import("camera.zig").Camera;
const Cube = @import("objects/cube.zig").Cube;
const Texture = @import("graphics/texture.zig").Texture;

pub const Scene = struct {
    allocator: std.mem.Allocator,
    renderer: *Renderer,
    camera: Camera,

    cubes: std.ArrayList(Cube),
    base_shader: Shader = undefined,
    base_texture: Texture = undefined,
    base_texture2: Texture = undefined,

    pub fn init(allocator: std.mem.Allocator, renderer: *Renderer) !Scene {
        const aspect = @as(f32, @floatFromInt(800)) / @as(f32, @floatFromInt(600));
        return Scene{
            .allocator = allocator,
            .renderer = renderer,
            .cubes = try std.ArrayList(Cube).initCapacity(allocator, 0),
            .camera = Camera.init(aspect),
            .base_shader = try Shader.init(@embedFile("shaders/vertex.glsl"), @embedFile("shaders/fragment.glsl")),
            .base_texture = try Texture.init(allocator, "assets/diamond.png", 0),
            .base_texture2 = try Texture.init(allocator, "assets/dirt.png", 1),
        };
    }

    pub fn addCube(self: *Scene) !void {
        const tg = self.camera.target;
        var cube: Cube = undefined;
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

        cube.transform.setPos(tg[0], tg[1], tg[2]);
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
        for (self.cubes.items) |*cube| {
            cube.draw(self.renderer, &self.camera);
        }
    }
};
