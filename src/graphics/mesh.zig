const gl = @import("zopengl").bindings;
const VertexBuffer = @import("buffer.zig").VertexBuffer;
const IndexBuffer = @import("buffer.zig").IndexBuffer;
const VertexArray = @import("vertex_array.zig").VertexArray;

pub const Mesh = struct {
    vbo: VertexBuffer,
    ebo: IndexBuffer,
    vao: VertexArray,
    index_count: c_int,

    pub fn init(vertices: []const f32, indices: []const u32, layout: []const u32) Mesh {
        var mesh = Mesh{
            .vbo = VertexBuffer.init(vertices),
            .ebo = IndexBuffer.init(indices),
            .vao = VertexArray.init(layout),
            .index_count = @intCast(indices.len),
        };

        mesh.vao.unbind();
        return mesh;
    }

    pub fn bind(self: Mesh) void {
        self.vao.bind();
        self.vbo.bind();
        self.ebo.bind();
    }

    pub fn unbind(self: Mesh) void {
        self.vao.unbind();
        self.vbo.unbind();
        self.ebo.unbind();
    }
};
