// src/main.zig (Corrected with Calling Convention)
const std = @import("std");

const Color = extern struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,
};

// --- 2. Define function pointers WITH the C calling convention ---
const InitWindow = *const fn (width: c_int, height: c_int, title: [*:0]const u8) callconv(.C) void;
const WindowShouldClose = *const fn () callconv(.C) bool;
const CloseWindow = *const fn () callconv(.C) void;
const BeginDrawing = *const fn () callconv(.C) void;
const EndDrawing = *const fn () callconv(.C) void;
const ClearBackground = *const fn (color: Color) callconv(.C) void;
const DrawText = *const fn (text: [*:0]const u8, posX: c_int, posY: c_int, fontSize: c_int, color: Color) callconv(.C) void;

pub fn main() !void {
    const screenWidth: c_int = 800;
    const screenHeight: c_int = 450;

    var raylib = try std.DynLib.open("raylib.dll");
    defer raylib.close();

    // The lookup logic remains the same. The type definition is what matters.
    const initWindow = raylib.lookup(InitWindow, "InitWindow") orelse {
        std.debug.print("Error: Could not find function 'InitWindow' in raylib.dll\n", .{});
        return error.SymbolNotFound;
    };
    const windowShouldClose = raylib.lookup(WindowShouldClose, "WindowShouldClose") orelse {
        std.debug.print("Error: Could not find function 'WindowShouldClose' in raylib.dll\n", .{});
        return error.SymbolNotFound;
    };
    const closeWindow = raylib.lookup(CloseWindow, "CloseWindow") orelse {
        std.debug.print("Error: Could not find function 'CloseWindow' in raylib.dll\n", .{});
        return error.SymbolNotFound;
    };
    const beginDrawing = raylib.lookup(BeginDrawing, "BeginDrawing") orelse {
        std.debug.print("Error: Could not find function 'BeginDrawing' in raylib.dll\n", .{});
        return error.SymbolNotFound;
    };
    const endDrawing = raylib.lookup(EndDrawing, "EndDrawing") orelse {
        std.debug.print("Error: Could not find function 'EndDrawing' in raylib.dll\n", .{});
        return error.SymbolNotFound;
    };
    const clearBackground = raylib.lookup(ClearBackground, "ClearBackground") orelse {
        std.debug.print("Error: Could not find function 'ClearBackground' in raylib.dll\n", .{});
        return error.SymbolNotFound;
    };
    const drawText = raylib.lookup(DrawText, "DrawText") orelse {
        std.debug.print("Error: Could not find function 'DrawText' in raylib.dll\n", .{});
        return error.SymbolNotFound;
    };

    initWindow(screenWidth, screenHeight, "Zig loads Raylib DLL");
    defer closeWindow();

    while (!windowShouldClose()) {
        beginDrawing();
        defer endDrawing();

        clearBackground(Color{ .r = 245, .g = 245, .b = 245, .a = 255 }); // RAYWHITE
        drawText(
            "Successfully loaded raylib.dll at runtime!",
            140,
            200,
            20,
            Color{ .r = 130, .g = 130, .b = 130, .a = 255 }, // GRAY
        );
    }
}
