const std = @import("std");
const zgui = @import("zgui");
const zglfw = @import("zglfw");
const zm = @import("zmath");
const zstbi = @import("zstbi");

pub fn show_ui(window: *zglfw.Window) !void {
    const fb = window.getFramebufferSize();
    if (fb[0] == 0 or fb[1] == 0) return;
    zgui.backend.newFrame(@intCast(fb[0]), @intCast(fb[1]));

    _ = zgui.begin("DEBUG BOX", .{});

    _ = zgui.text("Hello", .{});

    // _ = zgui.sliderInt("Rotation X", .{ .v = rot_x, .min = -10, .max = 10 });
    // _ = zgui.sliderInt("Rotation Y", .{ .v = rot_y, .min = -10, .max = 10 });
    // _ = zgui.sliderInt("Rotation Z", .{ .v = rot_z, .min = -10, .max = 10 });
    // _ = zgui.sliderFloat("Scale", .{ .v = scale, .min = -5, .max = 5 });

    zgui.end();
    zgui.render();
    zgui.backend.draw();
}

pub fn mat2arr(mat: zm.Mat) [16]f32 {
    var arr: [16]f32 = undefined;
    zm.storeMat(&arr, mat);
    return arr;
}

pub const RgbaImage = struct {
    width: u32,
    height: u32,
    pixels: []u8, // RGBA8, len = width * height * 4
};

pub fn loadPngRgba8(allocator: std.mem.Allocator, path: []const u8) !RgbaImage {
    zstbi.init(allocator);
    defer zstbi.deinit();

    // set flip vertically
    zstbi.setFlipVerticallyOnLoad(true);

    const zpath = try std.mem.concatWithSentinel(allocator, u8, &.{path}, 0);
    defer allocator.free(zpath);

    var img = try zstbi.Image.loadFromFile(zpath, 4);
    defer img.deinit();

    const w: u32 = @intCast(img.width);
    const h: u32 = @intCast(img.height);

    const out: []u8 = try allocator.dupe(u8, img.data);

    return .{ .width = w, .height = h, .pixels = out };
}

pub fn ortho(left: f32, right: f32, bottom: f32, top: f32, near: f32, far: f32) zm.Mat {
    const rl = right - left;
    const tb = top - bottom;
    const fna = far - near;

    return zm.matFromArr(.{
        2.0 / rl,             0.0,                  0.0,                 0.0,
        0.0,                  2.0 / tb,             0.0,                 0.0,
        0.0,                  0.0,                  -2.0 / fna,          0.0,
        -(right + left) / rl, -(top + bottom) / tb, -(far + near) / fna, 1.0,
    });
}
