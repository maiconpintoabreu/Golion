const rl = @import("raylib");
const std = @import("std");
const buildin = @import("builtin");
const gameplayZig = @import("gameplay.zig");

pub fn main() anyerror!void {
    rl.setTraceLogLevel(if (buildin.mode == .Debug) .all else .err);
    rl.traceLog(
        rl.TraceLogLevel.info,
        "Initializing Game!",
        .{},
    );

    rl.setConfigFlags(rl.ConfigFlags{
        .window_resizable = true,
    });

    try gameplayZig.init();

    std.os.emscripten.emscripten_set_main_loop(updateFrame, 0, 1);

    gameplayZig.unload();
}
export fn updateFrame() void {
    gameplayZig.update();
}
