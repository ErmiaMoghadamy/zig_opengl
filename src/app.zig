const std = @import("std");
const glfw = @import("zglfw");
const zgl = @import("zopengl");
const gl = zgl.bindings;
const Renderer = @import("graphics/renderer.zig").Renderer;
const Scene = @import("scene.zig").Scene;

pub const App = struct {
    const width: i32 = 800;
    const height: i32 = 600;

    window: *glfw.Window,
    renderer: Renderer,
    scene: Scene,

    fb_w: i32 = width,
    fb_h: i32 = height,
    last_w: i32 = 0,
    last_h: i32 = 0,
    pending_resize: bool = true, // apply once on startup

    pub fn init() !App {
        try glfw.init();
        errdefer glfw.terminate();

        var window = try glfw.Window.create(width, height, "Blank Screen", null, null);
        errdefer window.destroy();

        glfw.makeContextCurrent(window);
        glfw.swapInterval(1);

        try zgl.loadCoreProfile(glfw.getProcAddress, 4, 6);

        gl.viewport(0, 0, width, height);
        gl.enable(gl.DEPTH_TEST);
        gl.enable(gl.BLEND);
        gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);

        const renderer = try Renderer.init();

        return .{
            .window = window,
            .renderer = renderer,
            .scene = try Scene.init(renderer),
        };
    }

    pub fn deinit(self: *App) void {
        self.window.destroy();
        glfw.terminate();
    }

    pub fn render(self: *App) void {
        self.scene.update();
        self.scene.draw();
    }

    pub fn run(self: *App) !void {
        const sizes: [2]i32 = self.window.getFramebufferSize();
        gl.viewport(0, 0, sizes[0], sizes[1]);
        self.scene.camera.setAspect(@as(f32, @floatFromInt(sizes[0])) / @as(f32, @floatFromInt(sizes[1])));

        while (!self.window.shouldClose()) {
            glfw.pollEvents();
            self.handleResize();
            self.render();
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
};
