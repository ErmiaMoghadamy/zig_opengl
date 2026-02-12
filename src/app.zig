const std = @import("std");
const glfw = @import("zglfw");
const zgui = @import("zgui");
const zgl = @import("zopengl");
const gl = zgl.bindings;
const Renderer = @import("graphics/renderer.zig").Renderer;
const Scene = @import("scene.zig").Scene;

pub const App = struct {
    const width: i32 = 800;
    const height: i32 = 600;

    allocator: std.mem.Allocator,
    window: *glfw.Window,
    renderer: Renderer,
    scene: Scene,

    camera_fov: f32,

    fb_w: i32 = width,
    fb_h: i32 = height,
    last_w: i32 = 0,
    last_h: i32 = 0,
    pending_resize: bool = true, // apply once on startup

    pub fn init(allocator: std.mem.Allocator) !App {
        try glfw.init();
        errdefer glfw.terminate();

        var window = try glfw.Window.create(width, height, "Blank Screen", null, null);
        errdefer window.destroy();

        glfw.makeContextCurrent(window);
        glfw.swapInterval(1);

        try zgl.loadCoreProfile(glfw.getProcAddress, 4, 6);

        zgui.init(allocator);
        errdefer zgui.deinit();
        zgui.backend.init(window);
        errdefer zgui.backend.deinit();

        gl.viewport(0, 0, width, height);
        gl.enable(gl.DEPTH_TEST);
        gl.enable(gl.BLEND);
        gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);

        const renderer = try Renderer.init();

        var scene = try Scene.init(allocator, renderer);
        errdefer scene.deinit();

        return .{
            .camera_fov = 0.1,
            .allocator = allocator,
            .window = window,
            .renderer = renderer,
            .scene = scene,
        };
    }

    pub fn deinit(self: *App) void {
        self.scene.deinit();

        zgui.backend.deinit();
        zgui.deinit();

        self.window.destroy();
        glfw.terminate();
    }

    pub fn render(self: *App) void {
        self.scene.update();
        self.scene.draw();
    }

    pub fn drawUi(self: *App) !void {
        const fb = self.window.getFramebufferSize();
        if (fb[0] == 0 or fb[1] == 0) return;
        zgui.backend.newFrame(@intCast(fb[0]), @intCast(fb[1]));
        _ = zgui.begin("DEBUG BOX", .{});

        if (zgui.button("Add Cube", .{})) {
            try self.scene.addCube();
        }
        _ = zgui.sliderFloat("FOV", .{ .v = &self.camera_fov, .min = 0.3, .max = 2 });

        self.scene.camera.updateFov(self.camera_fov);

        zgui.end();
        zgui.render();
        zgui.backend.draw();
    }

    pub fn run(self: *App) !void {
        const sizes: [2]i32 = self.window.getFramebufferSize();
        gl.viewport(0, 0, sizes[0], sizes[1]);
        self.scene.camera.setAspect(@as(f32, @floatFromInt(sizes[0])) / @as(f32, @floatFromInt(sizes[1])));

        while (!self.window.shouldClose()) {
            glfw.pollEvents();
            self.handleInput();
            self.handleResize();
            self.render();
            try self.drawUi();
            self.window.swapBuffers();
        }
    }

    fn handleResize(self: *App) void {
        const fbs = self.window.getFramebufferSize();

        if (fbs[0] > 0 and fbs[1] > 0 and (fbs[0] != self.last_w or fbs[1] != self.last_h)) {
            self.last_w = fbs[0];
            self.last_h = fbs[1];

            gl.viewport(0, 0, fbs[0], fbs[1]);

            const aspect =
                @as(f32, @floatFromInt(fbs[0])) /
                @as(f32, @floatFromInt(fbs[1]));
            self.scene.camera.setAspect(aspect);
        }
    }

    fn handleInput(self: *App) void {
        if (self.window.getKey(.escape) == .press) {
            self.window.setShouldClose(true);
        }

        if (self.window.getKey(.w) == .press) {
            self.scene.camera.moveZ(-0.1);
        }

        if (self.window.getKey(.s) == .press) {
            self.scene.camera.moveZ(0.1);
        }

        if (self.window.getKey(.a) == .press) {
            self.scene.camera.moveX(-0.1);
        }

        if (self.window.getKey(.d) == .press) {
            self.scene.camera.moveX(0.1);
        }

        if (self.window.getKey(.q) == .press) {
            self.scene.camera.rotateY(-0.06);
        }

        if (self.window.getKey(.e) == .press) {
            self.scene.camera.rotateY(0.06);
        }

        if (self.window.getKey(.z) == .press) {
            self.scene.camera.rotatePitch(-0.05);
        }

        if (self.window.getKey(.x) == .press) {
            self.scene.camera.rotatePitch(0.05);
        }

        if (self.window.getKey(.right_shift) == .press) {
            self.scene.camera.moveX(0.1);
        }

        if (self.window.getKey(.space) == .press) {
            self.scene.camera.moveY(0.1);
        }

        if (self.window.getKey(.left_control) == .press) {
            self.scene.camera.moveY(-0.1);
        }
    }
};
