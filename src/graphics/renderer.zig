const gl = @import("zopengl").bindings;
const VertexArray = @import("vertex_array.zig").VertexArray;
const Mesh = @import("mesh.zig").Mesh;
const Shader = @import("shader.zig").Shader;

pub const Renderer = struct {
    pub fn init() !Renderer {
        return Renderer{};
    }

    pub fn draw(self: Renderer, vao: VertexArray, shader: Shader) void {
        _ = self;
        shader.bind();
        vao.draw();
    }

    pub fn clear(self: Renderer) void {
        _ = self;
        gl.clearColor(0.0, 0.0, 0.0, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    }
};
