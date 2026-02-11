const zm = @import("zmath");

pub const Camera = struct {
    position: zm.Vec,
    view: zm.Mat,
    projection: zm.Mat,

    fov: f32,
    aspect: f32,
    near: f32,
    far: f32,

    pub fn init(aspect: f32) Camera {
        var cam = Camera{
            .position = zm.f32x4(0.0, 0.0, 5.0, 1.0),
            .view = undefined,
            .projection = undefined,

            .fov = 0.78539816339, // 45° in radians
            .aspect = aspect,
            .near = 0.1,
            .far = 100.0,
        };

        cam.updateProjection();
        cam.updateView();

        return cam;
    }

    pub fn updateProjection(self: *Camera) void {
        self.projection = zm.perspectiveFovRh(
            self.fov,
            self.aspect,
            self.near,
            self.far,
        );
    }

    pub fn updateView(self: *Camera) void {
        self.view = zm.lookAtRh(
            self.position,
            zm.f32x4(0.0, 0.0, 0.0, 1.0), // look at origin
            zm.f32x4(0.0, 1.0, 0.0, 0.0), // up
        );
    }

    pub fn setAspect(self: *Camera, aspect: f32) void {
        self.aspect = aspect;
        self.updateProjection();
    }
};
