const zm = @import("zmath");

pub const Transform = struct {
    position: zm.Vec = zm.f32x4(0, 0, 0, 1),
    rotation: zm.Vec = zm.f32x4(0, 0, 0, 0),
    scale: zm.Vec = zm.f32x4(1, 1, 1, 0),

    pub fn init() Transform {
        return Transform{};
    }

    pub fn setPos(self: *Transform, x: f32, y: f32, z: f32) void {
        self.position = zm.f32x4(x, y, z, 1);
    }

    pub fn matrix(self: Transform) zm.Mat {
        const T = zm.translationV(self.position);
        const rx = zm.rotationX(self.rotation[0]);
        const ry = zm.rotationY(self.rotation[1]);
        const rz = zm.rotationY(self.rotation[2]);

        const R = zm.mul(rz, zm.mul(rx, ry));
        const S = zm.scalingV(self.scale);
        return zm.mul(S, zm.mul(T, R));
    }
};
