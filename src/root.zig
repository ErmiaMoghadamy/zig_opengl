const std = @import("std");
const App = @import("app.zig").App;

pub fn run() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var app = try App.init(gpa.allocator());
    defer app.deinit();

    try app.run();
}
