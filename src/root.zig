const std = @import("std");
const glfw = @import("zglfw");
const zgui = @import("zgui");
const zm = @import("zmath");
const zgl = @import("zopengl");
const gl = zgl.bindings;

const utils = @import("utils.zig");
const VertexArray = @import("graphics/vertex_array.zig").VertexArray;
const Shader = @import("graphics/shader.zig").Shader;
const Renderer = @import("graphics/renderer.zig").Renderer;
const Texture = @import("graphics/texture.zig").Texture;

const width = 960;
const height = 540;

pub fn run() !void {
    try glfw.init();
    defer glfw.terminate();

    var window = try glfw.Window.create(width, height, "Zig GL", null, null);
    defer window.destroy();

    glfw.makeContextCurrent(window);
    glfw.swapInterval(1);

    try zgl.loadCoreProfile(glfw.getProcAddress, 4, 6);

    zgui.init(std.heap.raw_c_allocator);
    defer zgui.deinit();

    // This exists *only because* you selected Backend.glfw_opengl3 in build.zig
    zgui.backend.init(window);
    defer zgui.backend.deinit();

    // rendering
    const shader = try Shader.init(
        @embedFile("./shaders/vertx.glsl"),
        @embedFile("./shaders/frag.glsl"),
    );

    const vertices = [_]f32{
        100.5, 100.5, 0.0, 0.0,
        200.5, 100.5, 1.0, 0.0,
        200.5, 200.5, 1.0, 1.0,
        100.5, 200.5, 0.0, 1.0,
    };

    const indices = [_]u32{ 0, 1, 2, 2, 3, 0 };

    var layout = [_]u32{ 2, 2 };

    const vao = VertexArray.init(&vertices, &indices, &layout);
    const texture = try Texture.init(std.heap.c_allocator, "./assets/swastika.png");
    const renderer = try Renderer.init();

    const proj = utils.ortho(0, 960, 0, 540, -1.0, 1.0);
    const view = zm.translation(-70, 0, -1);
    const model = zm.mul(zm.scaling(1.8, 1.8, 0), zm.translation(300, 0, 0));

    // the z.mul(b, a) = a * b
    // proj * (view * model)
    const mvp = zm.mul(zm.mul(model, view), proj);

    gl.enable(gl.BLEND);
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);

    while (!window.shouldClose()) {
        glfw.pollEvents();

        var tMat: [16]f32 = undefined;
        zm.storeMat(&tMat, mvp);
        renderer.clear();
        texture.bind(0);
        shader.setu_1i("u_Texture", 0);
        shader.setu_mvp(tMat);
        renderer.draw(vao, shader);

        try utils.show_ui(window);
        window.swapBuffers();
    }
}
