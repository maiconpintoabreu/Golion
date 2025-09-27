const std = @import("std");
const rl = @import("raylib");
const characterZig = @import("character.zig");

var camera: rl.Camera3D = std.mem.zeroes(rl.Camera3D);
var texture: rl.Texture2D = std.mem.zeroes(rl.Texture2D);
var textureCubic: rl.Texture2D = std.mem.zeroes(rl.Texture2D);
var model: rl.Model = std.mem.zeroes(rl.Model);
var cameraTarget: rl.Vector3 = .{ .x = 0, .y = 0, .z = 0 };
var player: characterZig.Character = .{};

const mapPosition: rl.Vector3 = rl.Vector3{ .x = -8.0, .y = 0.0, .z = -8.0 };
const screenWidth: i32 = 800;
const screenHeight: i32 = 450;

pub fn init() rl.RaylibError!void {
    rl.initWindow(screenWidth, screenHeight, "Golion");

    const cameraPosition: rl.Vector3 = .{ .x = 18, .y = 21, .z = 18 };

    const cameraUp: rl.Vector3 = .{ .x = 0, .y = 1, .z = 0 };
    const cameraProjection = rl.CameraProjection.perspective;
    camera = rl.Camera{ .fovy = 45.0, .position = cameraPosition, .up = cameraUp, .projection = cameraProjection, .target = cameraTarget };
    {
        const image: rl.Image = try rl.loadImage("resources/cubicmap.png");
        defer image.unload();
        textureCubic = try image.toTexture();
        const mesh = rl.genMeshCubicmap(image, .{ .x = 1.0, .y = 1.0, .z = 1.0 });
        model = try rl.loadModelFromMesh(mesh);
    }

    texture = try rl.loadTexture("resources/cubicmap_atlas.png");

    model.materials[0].maps[@intFromEnum(rl.MATERIAL_MAP_DIFFUSE)].texture = texture;

    try player.init();

    rl.disableCursor(); // Limit cursor to relative movement inside the window

    rl.setTargetFPS(60);
}

pub fn update() void {
    camera.target = cameraTarget;
    rl.updateCamera(&camera, .third_person);

    player.update();

    rl.beginDrawing();
    defer rl.endDrawing();

    rl.clearBackground(.ray_white);
    {
        rl.beginMode3D(camera);
        defer rl.endMode3D();
        model.draw(mapPosition, 1, .white);
        player.draw();
        rl.drawGrid(200, 1.0);
    }
    textureCubic.drawEx(.{ .x = @as(f32, @floatFromInt(screenWidth - textureCubic.width)) * 4.0 - 20, .y = 20.0 }, 0.0, 10, .white);
    rl.drawRectangleLines(screenWidth - textureCubic.width - 20, 20, textureCubic.width, textureCubic.height, .green);

    rl.drawFPS(10, 10);
}

pub fn unload() void {
    texture.unload();
    textureCubic.unload();
    model.unload();
}
