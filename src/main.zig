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
    try gameplayZig.init();

    while (!rl.windowShouldClose()) {
        gameplayZig.update();
    }
    gameplayZig.unload();

    rl.closeWindow();
}
