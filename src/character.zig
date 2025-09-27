const std = @import("std");
const rl = @import("raylib");

const BONE_SOCKETS = 3;
const BONE_SOCKET_HAT = 0;
const BONE_SOCKET_HAND_R = 1;
const BONE_SOCKET_HAND_L = 2;

pub const Character = struct {
    position: rl.Vector3 = std.mem.zeroes(rl.Vector3),
    angle: f32 = 0.0,
    model: rl.Model = std.mem.zeroes(rl.Model),
    modelAnimations: []rl.ModelAnimation = undefined,
    anim: rl.ModelAnimation = std.mem.zeroes(rl.ModelAnimation),
    animIndex: usize = 0,
    animCurrentFrame: i32 = 0,
    animsCount: usize = 0,
    equipModel: [BONE_SOCKETS]rl.Model = std.mem.zeroes([BONE_SOCKETS]rl.Model),
    boneSocketIndex: [BONE_SOCKETS]usize = undefined,

    pub fn init(self: *Character) rl.RaylibError!void {
        self.model = try rl.loadModel("resources/models/greenmam/character.glb"); // Load character model
        self.equipModel = .{
            try rl.loadModel("resources/models/greenmam/character_hat.glb"), // Index for the hat model is the same as BONE_SOCKET_HAT
            try rl.loadModel("resources/models/greenmam/character_sword.glb"), // Index for the sword model is the same as BONE_SOCKET_HAND_R
            try rl.loadModel("resources/models/greenmam/character_shield.glb"), // Index for the shield model is the same as BONE_SOCKET_HAND_L
        };
        self.modelAnimations = try rl.loadModelAnimations("resources/models/greenmam/character.glb");
        self.animsCount = self.modelAnimations.len;

        // search bones for sockets
        for (0..@as(usize, @intCast(self.model.boneCount))) |i| {
            const boneName: [:0]const u8 = @ptrCast(&self.model.bones[i].name);
            if (rl.textIsEqual(boneName, "socket_hat")) {
                self.boneSocketIndex[BONE_SOCKET_HAT] = i;
                continue;
            }

            if (rl.textIsEqual(boneName, "socket_hand_R")) {
                self.boneSocketIndex[BONE_SOCKET_HAND_R] = i;
                continue;
            }

            if (rl.textIsEqual(boneName, "socket_hand_L")) {
                self.boneSocketIndex[BONE_SOCKET_HAND_L] = i;
                continue;
            }
        }
    }

    pub fn update(self: *Character) void {
        self.anim = self.modelAnimations[self.animIndex];
        self.animCurrentFrame = @mod(self.animCurrentFrame + 1, self.anim.frameCount);
        rl.updateModelAnimation(self.model, self.anim, self.animCurrentFrame);
    }

    pub fn draw(self: *Character) void {
        // Draw character
        const characterRotate: rl.Quaternion = rl.math.quaternionFromAxisAngle(.{ .x = 0.0, .y = 1.0, .z = 0.0 }, self.angle * std.math.rad_per_deg);
        self.model.transform = rl.math.matrixMultiply(rl.math.quaternionToMatrix(characterRotate), rl.math.matrixTranslate(self.position.x, self.position.y, self.position.z));
        rl.updateModelAnimation(self.model, self.anim, self.animCurrentFrame);
        rl.drawMesh(self.model.meshes[0], self.model.materials[1], self.model.transform);

        for (0..BONE_SOCKETS) |i| {
            const transform = &self.anim.framePoses[@intCast(self.animCurrentFrame)][self.boneSocketIndex[i]];
            const inRotation = self.model.bindPose[self.boneSocketIndex[i]].rotation;
            const outRotation = transform.rotation;

            // Calculate socket rotation (angle between bone in initial pose and same bone in current animation frame)
            const rotate = rl.math.quaternionMultiply(outRotation, rl.math.quaternionInvert(inRotation));
            var matrixTransform = rl.math.quaternionToMatrix(rotate);
            // Translate socket to its position in the current animation
            matrixTransform = rl.math.matrixMultiply(matrixTransform, rl.math.matrixTranslate(transform.translation.x, transform.translation.y, transform.translation.z));
            // Transform the socket using the transform of the character (angle and translate)
            matrixTransform = rl.math.matrixMultiply(matrixTransform, self.model.transform);
            rl.drawMesh(self.equipModel[i].meshes[0], self.equipModel[i].materials[1], matrixTransform);
        }
    }

    pub fn unload(self: *Character) void {
        self.model.unload();
        self.modelAnimations.unload();
        for (self.equipModel) |model| {
            model.unload();
        }
    }
};
