const std = @import("std");
const glfw = @import("zglfw");
const zgui = @import("zgui");
const zgl = @import("zopengl");
const gl = zgl.bindings;
const Renderer = @import("graphics/renderer.zig").Renderer;
const Shader = @import("graphics/shader.zig").Shader;
const Mesh = @import("graphics/mesh.zig").Mesh;
const Scene = @import("scene.zig").Scene;

pub const App = struct {
    const width: i32 = 980;
    const height: i32 = 720;

    allocator: std.mem.Allocator,
    window: *glfw.Window,
    renderer: Renderer,

    timer: std.time.Timer,
    last_time_ns: u64,

    fb_w: i32 = width,
    fb_h: i32 = height,
    last_w: i32 = 0,
    last_h: i32 = 0,
    pending_resize: bool = true,

    scene: Scene,

    pub fn init(allocator: std.mem.Allocator) !App {
        try glfw.init();
        errdefer glfw.terminate();

        var window = try glfw.createWindow(width, height, "Saturn Engine", null, null);
        errdefer window.destroy();

        glfw.makeContextCurrent(window);
        glfw.swapInterval(1);

        try zgl.loadCoreProfile(glfw.getProcAddress, 3, 3);

        zgui.init(allocator);
        errdefer zgui.deinit();

        zgui.backend.init(window);
        errdefer zgui.backend.deinit();

        gl.viewport(0, 0, width, height);
        gl.enable(gl.DEPTH_TEST);
        gl.enable(gl.BLEND);
        gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);

        var renderer = try Renderer.init();
        errdefer renderer.deinit();

        var scene = try Scene.init(allocator, &renderer);
        errdefer scene.deinit();

        var timer = try std.time.Timer.start();

        return App{
            .allocator = allocator,
            .window = window,
            .renderer = renderer,
            .scene = scene,
            .timer = timer,
            .last_time_ns = timer.read(),
        };
    }

    pub fn deinit(self: *App) void {
        self.scene.deinit();

        zgui.backend.deinit();
        zgui.deinit();

        self.window.destroy();
        glfw.terminate();
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

    fn handleInput(self: *App, dt: f64) void {
        if (self.window.getKey(.escape) == .press) {
            self.window.setShouldClose(true);
        }

        if (self.window.getKey(.w) == .press) {
            self.scene.camera.moveZ(@floatCast(-4 * dt));
        }

        if (self.window.getKey(.s) == .press) {
            self.scene.camera.moveZ(@floatCast(4 * dt));
        }

        if (self.window.getKey(.a) == .press) {
            self.scene.camera.moveX(@floatCast(-4 * dt));
        }

        if (self.window.getKey(.d) == .press) {
            self.scene.camera.moveX(@floatCast(4 * dt));
        }

        if (self.window.getKey(.q) == .press) {
            self.scene.camera.rotateY(@floatCast(-4 * dt));
        }

        if (self.window.getKey(.e) == .press) {
            self.scene.camera.rotateY(@floatCast(4 * dt));
        }

        if (self.window.getKey(.z) == .press) {
            self.scene.camera.rotateV(@floatCast(-2 * dt));
        }

        if (self.window.getKey(.x) == .press) {
            self.scene.camera.rotateV(@floatCast(2 * dt));
        }

        if (self.window.getKey(.space) == .press) {
            self.scene.camera.moveY(0.1);
        }

        if (self.window.getKey(.left_control) == .press) {
            self.scene.camera.moveY(-0.1);
        }
    }

    fn timeDelta(self: *App) f64 {
        const now = self.timer.read();
        const delta_ns = now - self.last_time_ns;
        self.last_time_ns = now;

        const dt = @as(f32, @floatFromInt(delta_ns)) / 1_000_000_000.0;

        if (dt > 0.1) return 0.1;

        return dt;
    }

    pub fn render(self: *App, dt: f64) void {
        self.scene.update(dt);
        self.scene.render();
    }

    pub fn run(self: *App) !void {
        const sizes: [2]i32 = self.window.getFramebufferSize();
        gl.viewport(0, 0, sizes[0], sizes[1]);
        self.scene.camera.setAspect(@as(f32, @floatFromInt(sizes[0])) / @as(f32, @floatFromInt(sizes[1])));

        while (!self.window.shouldClose()) {
            glfw.pollEvents();
            self.handleResize();

            const dt = self.timeDelta();

            self.handleInput(dt);
            self.render(dt);
            self.window.swapBuffers();
        }
    }
};
