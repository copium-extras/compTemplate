const std = @import("std");

pub fn build(b: *std.Build) !void {
    // --- 1. Define Cross-Compilation Targets ---
    const windows_target = b.resolveTargetQuery(.{
        .cpu_arch = .x86_64,
        .os_tag = .windows,
        .abi = .gnu,
    });
    const linux_target = b.resolveTargetQuery(.{
        .cpu_arch = .x86_64,
        .os_tag = .linux,
        .abi = .musl,
    });
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSmall,
    });

    // --- 2. Iterate Through 'src' and Build All Artifacts ---
    var src_dir = try std.fs.cwd().openDir("src", .{ .iterate = true });
    defer src_dir.close();
    var dir_iterator = src_dir.iterate();

    while (try dir_iterator.next()) |entry| {
        if (entry.kind != .file or !std.mem.endsWith(u8, entry.name, ".zig")) {
            continue;
        }

        const stem_name = std.fs.path.stem(entry.name);
        const root_source_path_str = b.pathJoin(&.{ "src", entry.name });
        const root_source_file = b.path(root_source_path_str);

        std.log.info("Building artifacts for {s}", .{entry.name});

        // --- Build Windows Artifacts ---
        const win_exe = b.addExecutable(.{
            .name = stem_name,
            .root_source_file = root_source_file,
            .target = windows_target,
            .optimize = optimize,
        });

        // Install Windows executable to windows/ folder
        const win_exe_install = b.addInstallArtifact(win_exe, .{
            .dest_dir = .{ .override = .{ .custom = "windows" } },
        });

        // --- Build Linux Artifacts ---
        const linux_exe = b.addExecutable(.{
            .name = stem_name,
            .root_source_file = root_source_file,
            .target = linux_target,
            .optimize = optimize,
        });

        // Install Linux executable to linux/ folder
        const linux_exe_install = b.addInstallArtifact(linux_exe, .{
            .dest_dir = .{ .override = .{ .custom = "linux" } },
        });

        // Add dependencies to the default install step
        b.getInstallStep().dependOn(&win_exe_install.step);
        b.getInstallStep().dependOn(&linux_exe_install.step);
    }
}
