const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    // --- 2. Dynamically Build a DLL for Each .zig File in 'src' ---
    var src_dir = try std.fs.cwd().openDir("src", .{ .iterate = true });
    defer src_dir.close();

    var dir_iterator = src_dir.iterate();
    while (try dir_iterator.next()) |entry| {
        // Process only .zig files
        if (entry.kind != .file or !std.mem.endsWith(u8, entry.name, ".zig")) {
            continue;
        }

        const lib_name = std.fs.path.stem(entry.name);
        const root_source_path = b.pathJoin(&.{ "src", entry.name });

        std.log.info("Building script: {s} -> {s}.dll", .{ entry.name, lib_name });

        const app = b.addExecutable(.{
            .name = lib_name,
            .root_source_file = b.path(root_source_path),
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(app);
    }
}
