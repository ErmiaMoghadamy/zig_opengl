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

    dt_ns: u64 = 0, // last frame delta (ns)
    fps_inst: f32 = 0, // instantaneous FPS
    fps_avg: f32 = 0, // averaged FPS (updates ~1x/sec)
    fps_smooth: f32 = 0, // smoothed FPS (EMA)
    fps_accum_ns: u64 = 0, // accumulator for 1-second average window
    fps_frames: u32 = 0,

    last_w: i32 = 0,
    last_h: i32 = 0,

    scene: Scene,

    pub fn init(allocator: std.mem.Allocator) !App {
        try glfw.init();
        errdefer glfw.terminate();

        var window = try glfw.createWindow(width, height, "Zypher Engine", null, null);
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

    fn handleInput(self: *App) !void {
        const dt = self.timeDelta();
        if (self.window.getKey(.escape) == .press) {
            self.window.setShouldClose(true);
        }

        if (self.window.getKey(.g) == .press) {
            try self.scene.addCube();
        }

        if (self.window.getKey(.w) == .press) {
            self.scene.camera.moveZ(@floatCast(-6 * dt));
        }

        if (self.window.getKey(.s) == .press) {
            self.scene.camera.moveZ(@floatCast(6 * dt));
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
            self.scene.camera.moveY(@floatCast(2 * dt));
        }

        if (self.window.getKey(.left_control) == .press) {
            self.scene.camera.moveY(@floatCast(-2 * dt));
        }
    }

    pub fn tick(self: *App) void {
        const now_ns: u64 = self.timer.read();
        const dt_ns: u64 = now_ns - self.last_time_ns;
        self.last_time_ns = now_ns;

        self.dt_ns = dt_ns;

        // Instant FPS (can jump a lot)
        if (dt_ns > 0) {
            const dt_s: f32 = @as(f32, @floatFromInt(dt_ns)) / 1_000_000_000.0;
            self.fps_inst = 1.0 / dt_s;

            // Smoothed FPS (EMA) - stable but responsive
            const alpha: f32 = 0.1; // 0.05 slower, 0.2 faster
            self.fps_smooth = self.fps_smooth * (1.0 - alpha) + self.fps_inst * alpha;
        }

        // 1-second average FPS (very stable)
        self.fps_accum_ns += dt_ns;
        self.fps_frames += 1;

        if (self.fps_accum_ns >= 1_000_000_000) {
            const accum_s: f32 = @as(f32, @floatFromInt(self.fps_accum_ns)) / 1_000_000_000.0;
            self.fps_avg = @as(f32, @floatFromInt(self.fps_frames)) / accum_s;

            // keep remainder so it doesn’t drift
            self.fps_accum_ns -= 1_000_000_000;
            self.fps_frames = 0;
        }
    }

    fn timeDelta(self: *App) f64 {
        return @as(f64, @floatFromInt(self.dt_ns)) / 1_000_000_000.0;
    }

    pub fn drawDebugUI(self: *App) void {
        const fb = self.window.getFramebufferSize();
        zgui.backend.newFrame(@intCast(fb[0]), @intCast(fb[1]));

        _ = zgui.begin("Debug", .{});

        zgui.text("dt: {d:.3} ms", .{@as(f32, @floatFromInt(self.dt_ns)) / 1_000_000.0});
        zgui.text("FPS inst: {d:.1}", .{self.fps_inst});
        zgui.text("FPS smooth: {d:.1}", .{self.fps_smooth});
        zgui.text("FPS avg(1s): {d:.1}", .{self.fps_avg});

        zgui.end();
        zgui.render();
        zgui.backend.draw();
    }

    pub fn render(self: *App) void {
        const dt = self.timeDelta();
        self.scene.update(dt);
        self.scene.render();
        self.drawDebugUI();
    }

    pub fn run(self: *App) !void {
        const sizes: [2]i32 = self.window.getFramebufferSize();
        gl.viewport(0, 0, sizes[0], sizes[1]);
        self.scene.camera.setAspect(@as(f32, @floatFromInt(sizes[0])) / @as(f32, @floatFromInt(sizes[1])));

        while (!self.window.shouldClose()) {
            glfw.pollEvents();

            self.tick();

            self.handleResize();

            try self.handleInput();
            self.render();

            self.window.swapBuffers();
        }
    }
};
