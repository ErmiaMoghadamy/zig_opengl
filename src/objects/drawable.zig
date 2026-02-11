const Renderer = @import("../graphics/renderer.zig").Renderer;
const Camera = @import("../camera.zig").Camera;

pub const Drawable = struct {
    ptr: *anyopaque,
    init: *const fn (*anyopaque) *anyopaque,
    update: *const fn (*anyopaque) void,
    draw: *const fn (*anyopaque, *Renderer, *Camera) void,
};
