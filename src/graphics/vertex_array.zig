const std = @import("std");
const gl = @import("zopengl").bindings;
const VertexBuffer = @import("./buffer.zig").VertexBuffer;
const IndexBuffer = @import("./buffer.zig").IndexBuffer;

pub const VertexArray = struct {
    id: u32,
    vbo: VertexBuffer,
    ebo: IndexBuffer,
    layout: []const u32,

    pub fn init(vertices: []const f32, indices: []const u32, layout: []const u32) VertexArray {
        var vao = VertexArray{
            .id = 0,
            .vbo = VertexBuffer.init(vertices),
            .ebo = IndexBuffer.init(indices),
            .layout = layout,
        };

        gl.genVertexArrays(1, &vao.id);
        gl.bindVertexArray(vao.id);

        vao.setup_layout();

        return vao;
    }

    pub fn indexCount(self: VertexArray) c_int {
        return @intCast(self.ebo.count);
    }

    pub fn draw(self: VertexArray) void {
        self.bind();

        self.vbo.bind();
        self.ebo.bind();

        gl.drawElements(gl.TRIANGLES, self.indexCount(), gl.UNSIGNED_INT, null);
    }

    pub fn setup_layout(self: *VertexArray) void {
        var strides: c_int = 0;

        for (self.layout) |element| {
            strides += @intCast(element * @sizeOf(f32));
        }

        gl.bindVertexArray(self.id);

        var index: u32 = 0;
        var offset: u32 = 0;

        for (self.layout) |element| {
            const size: c_int = @intCast(element);
            gl.vertexAttribPointer((index), size, gl.FLOAT, gl.FALSE, strides, @ptrFromInt(offset * @sizeOf(f32)));
            gl.enableVertexAttribArray(index);

            index += 1;
            offset += element;
        }
    }

    pub fn bind(self: VertexArray) void {
        gl.bindVertexArray(self.id);
    }

    pub fn unbind(self: VertexArray) void {
        _ = self;
        gl.bindVertexArray(0);
    }
};
