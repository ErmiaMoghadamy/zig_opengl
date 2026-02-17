const std = @import("std");
const glfw = @import("zglfw");
const zgui = @import("zgui");
const zgl = @import("zopengl");
const gl = zgl.bindings;
const Renderer = @import("graphics/renderer.zig").Renderer;
const Scene = @import("scene.zig").Scene;
const FrameTimer = @import("frame_timer.zig").FrameTimer;
const CameraController = @import("camera_controller.zig").CameraController;

pub const App = struct {
    const width: i32 = 980;
    const height: i32 = 720;

    allocator: std.mem.Allocator,
    window: *glfw.Window,
    renderer: Renderer,

    frame_timer: FrameTimer,
    camera_controller: CameraController = .{},

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

        return App{
            .allocator = allocator,
            .window = window,
            .renderer = renderer,
            .scene = scene,
            .frame_timer = try FrameTimer.init(),
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
        if (self.window.getKey(.escape) == .press) {
            self.window.setShouldClose(true);
        }

        if (self.window.getKey(.g) == .press) {
            try self.scene.addCube();
        }
        self.camera_controller.update(
            self.window,
            &self.scene.camera,
            @floatCast(self.frame_timer.deltaSeconds()),
        );
    }

    pub fn drawDebugUI(self: *App) void {
        const fb = self.window.getFramebufferSize();
        zgui.backend.newFrame(@intCast(fb[0]), @intCast(fb[1]));

        _ = zgui.begin("Debug", .{});

        zgui.text("dt: {d:.3} ms", .{@as(f32, @floatFromInt(self.frame_timer.dt_ns)) / 1_000_000.0});
        zgui.text("FPS inst: {d:.1}", .{self.frame_timer.fps_inst});
        zgui.text("FPS smooth: {d:.1}", .{self.frame_timer.fps_smooth});
        zgui.text("FPS avg(1s): {d:.1}", .{self.frame_timer.fps_avg});

        zgui.end();
        zgui.render();
        zgui.backend.draw();
    }

    pub fn render(self: *App) void {
        const dt = self.frame_timer.deltaSeconds();
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

            self.frame_timer.tick();

            self.handleResize();

            try self.handleInput();
            self.render();

            self.window.swapBuffers();
        }
    }
};
