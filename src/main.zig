const std = @import("std");
const token = @import("token.zig");

pub fn main() !void {
    std.debug.print("All your {s} are belong to us !!\n", .{"codebase"});
}

test "simple test" {}
