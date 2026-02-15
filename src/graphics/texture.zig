const std = @import("std");
const gl = @import("zopengl").bindings;
const utils = @import("../utils.zig");

pub const Texture = struct {
    id: c_uint,
    filepath: []const u8,
    width: c_int,
    height: c_int,
    bpp: c_int,

    // cpu buffer
    localBuffer: []u8 = &[_]u8{},
    allocator: std.mem.Allocator,

    slot: i32,

    pub fn init(allocator: std.mem.Allocator, filepath: []const u8, ts: i32) !Texture {
        var t = Texture{
            .id = 0,
            .allocator = allocator,
            .localBuffer = undefined,
            .filepath = filepath,
            .width = 0,
            .height = 0,
            .bpp = 0,
            .slot = ts,
        };

        try t.post_init();

        return t;
    }

    pub fn deinit(self: *Texture) void {
        if (self.id != 0) {
            gl.deleteTextures(1, &self.id);
            self.id = 0;
        }
        if (self.localBuffer.len != 0) {
            self.allocator.free(self.localBuffer);
            self.localBuffer = &[_]u8{};
        }
    }

    pub fn post_init(self: *Texture) !void {
        // load image cpu buffer

        const img = try utils.loadPngRgba8(self.allocator, self.filepath);
        self.width = @intCast(img.width);
        self.height = @intCast(img.height);
        self.localBuffer = img.pixels;

        // gl buffer
        gl.genTextures(1, &self.id);
        gl.bindTexture(gl.TEXTURE_2D, self.id);

        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);

        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA8, self.width, self.height, 0, gl.RGBA, gl.UNSIGNED_BYTE, self.localBuffer.ptr);
        gl.bindTexture(gl.TEXTURE_2D, 0);
    }

    pub fn getWidth(self: Texture) u32 {
        return self.width;
    }

    pub fn getHeight(self: Texture) u32 {
        return self.height;
    }

    pub fn bind(self: Texture) void {
        const slot_enum: c_uint = switch (self.slot) {
            0 => gl.TEXTURE0,
            1 => gl.TEXTURE1,
            2 => gl.TEXTURE2,
            3 => gl.TEXTURE3,
            4 => gl.TEXTURE4,
            5 => gl.TEXTURE5,
            6 => gl.TEXTURE6,
            7 => gl.TEXTURE7,
            8 => gl.TEXTURE8,
            9 => gl.TEXTURE9,
            10 => gl.TEXTURE10,
            11 => gl.TEXTURE11,
            12 => gl.TEXTURE12,
            13 => gl.TEXTURE13,
            14 => gl.TEXTURE14,
            15 => gl.TEXTURE15,
            else => 0,
        };

        gl.activeTexture(slot_enum);
        gl.bindTexture(gl.TEXTURE_2D, self.id);
    }

    pub fn unbind(self: Texture) void {
        _ = self;
        gl.bindTexture(gl.TEXTURE_2D, 0);
    }
};
