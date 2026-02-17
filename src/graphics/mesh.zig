const gl = @import("zopengl").bindings;
const VertexBuffer = @import("buffer.zig").VertexBuffer;
const IndexBuffer = @import("buffer.zig").IndexBuffer;
const VertexArray = @import("vertex_array.zig").VertexArray;

pub const Mesh = struct {
    vbo: VertexBuffer,
    ibo: IndexBuffer,
    vao: VertexArray,
    index_count: c_int,

    pub fn init(vertices: []const f32, indices: []const u32, layout: []const u32) Mesh {
        return Mesh{
            .vbo = VertexBuffer.init(vertices),
            .ibo = IndexBuffer.init(indices),
            .vao = VertexArray.init(layout),
            .index_count = @intCast(indices.len),
        };
    }

    pub fn deinit(self: *Mesh) void {
        self.vao.deinit();
        self.vbo.deinit();
        self.ibo.deinit();
    }

    pub fn bind(self: Mesh) void {
        self.vao.bind();
        self.vbo.bind();
        self.ibo.bind();
    }

    pub fn unbind(self: Mesh) void {
        self.vao.unbind();
        self.vbo.unbind();
        self.ibo.unbind();
    }
};
