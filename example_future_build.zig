const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "my_app",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // 1. Point to your sovereign wrapper source
    const raylib_mod = b.addModule("raylib", .{
        .root_source_file = b.path("modules/raylib/src/raylib.zig"), 
    });
    exe.root_module.addImport("raylib", raylib_mod);

    // 2. Cross-Platform C Linking
    exe.addIncludePath(b.path("modules/raylib/include"));
    
    // Switch the binary based on the OS we are targeting
    const os_tag = target.result.os.tag;
    if (os_tag == .windows) {
        exe.addObjectFile(b.path("modules/raylib/lib/win/libraylib.a"));
        exe.linkSystemLibrary("gdi32");
        exe.linkSystemLibrary("winmm");
        exe.linkSystemLibrary("opengl32");
    } else if (os_tag == .linux) {
        exe.addObjectFile(b.path("modules/raylib/lib/lin/libraylib.a"));
        // Linux specific linkings (GL, m, pthread, dl, rt, X11)
    } else if (os_tag == .macos) {
        exe.addObjectFile(b.path("modules/raylib/lib/mac/libraylib.a"));
        // Mac specific frameworks (Cocoa, OpenGL, IOKit, CoreVideo)
    }
    
    exe.linkLibC();
    b.installArtifact(exe);
}
