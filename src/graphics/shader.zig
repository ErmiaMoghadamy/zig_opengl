const std = @import("std");
const gl = @import("zopengl").bindings;

pub const ShaderError = error{
    VertexShaderCreationFailed,
    FragmentShaderCreationFailed,
    VertexShaderCompilationFailed,
    FragmentShaderCompilationFailed,
    ProgramCreationFailed,
    ProgramLinkingFailed,
    OpenGlError,
};

pub const Shader = struct {
    id: u32,

    pub fn init(vs_src: [*c]const u8, fs_src: [*c]const u8) ShaderError!Shader {
        const vs = gl.createShader(gl.VERTEX_SHADER);
        if (vs == 0) {
            return error.VertexShaderCreationFailed;
        }
        errdefer gl.deleteShader(vs);

        gl.shaderSource(vs, 1, &vs_src, null);
        gl.compileShader(vs);

        var vs_success: i32 = 0;
        gl.getShaderiv(vs, gl.COMPILE_STATUS, &vs_success);
        if (vs_success == 0) {
            var info_log: [1024]u8 = undefined;
            var log_len: gl.Sizei = 0;
            gl.getShaderInfoLog(vs, info_log.len, &log_len, &info_log[0]);
            std.debug.print("Vertex Shader Compilation Error: {s}\n", .{info_log[0..@intCast(log_len)]});
            return error.VertexShaderCompilationFailed;
        }

        const fs = gl.createShader(gl.FRAGMENT_SHADER);
        if (fs == 0) {
            return error.FragmentShaderCreationFailed;
        }
        errdefer gl.deleteShader(fs);

        gl.shaderSource(fs, 1, &fs_src, null);
        gl.compileShader(fs);

        var fs_success: i32 = 0;
        gl.getShaderiv(fs, gl.COMPILE_STATUS, &fs_success);
        if (fs_success == 0) {
            var info_log: [1024]u8 = undefined;
            var log_len: gl.Sizei = 0;
            gl.getShaderInfoLog(fs, info_log.len, &log_len, &info_log[0]);
            std.debug.print("Fragment shader error:\n{s}\n", .{info_log[0..@intCast(log_len)]});
            return error.FragmentShaderCompilationFailed;
        }

        const id = gl.createProgram();

        if (id == 0) {
            return error.ProgramCreationFailed;
        }
        errdefer gl.deleteProgram(id);

        gl.attachShader(id, vs);
        gl.attachShader(id, fs);

        gl.linkProgram(id);

        var link_success: i32 = 0;
        gl.getProgramiv(id, gl.LINK_STATUS, &link_success);
        if (link_success == 0) {
            var info_log: [1024]u8 = undefined;
            var log_len: gl.Sizei = 0;
            gl.getProgramInfoLog(id, info_log.len, &log_len, &info_log[0]);
            std.debug.print("Program Linking Error: {s}\n", .{info_log[0..@intCast(log_len)]});
            return ShaderError.ProgramLinkingFailed;
        }

        gl.deleteShader(vs);
        gl.deleteShader(fs);

        return Shader{ .id = id };
    }

    pub fn deinit(self: *Shader) void {
        gl.deleteProgram(self.id);
        self.id = 0;
    }

    pub fn setu_mat(self: Shader, name: [:0]const u8, mat: [16]f32) void {
        self.bind();

        const location = gl.getUniformLocation(self.id, name.ptr);

        gl.uniformMatrix4fv(location, 1, 0, &mat);
    }

    pub fn setu_1i(self: Shader, name: [:0]const u8, value: i32) void {
        self.bind();

        const location = gl.getUniformLocation(self.id, name.ptr);

        gl.uniform1i(location, value);
    }

    pub fn bind(self: Shader) void {
        gl.useProgram(self.id);
    }

    pub fn unbind(self: Shader) void {
        _ = self;
        gl.useProgram(0);
    }
};
