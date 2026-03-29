const std = @import("std");
const layout = @import("ui/layout.zig"); 

const ray = @cImport({
    @cInclude("raylib.h");
    @cInclude("raygui.h");
});

pub fn main() !void {
    // FIX: Enable resizing and maximizing before creating the window
    ray.SetConfigFlags(ray.FLAG_WINDOW_RESIZABLE);
    
    ray.InitWindow(1280, 800, "Ziguezon: The Raygui Tour");
    defer ray.CloseWindow();
    ray.SetTargetFPS(60);

    var exit_requested = false;

    // --- GUI STATE VARIABLES ---
    
    // Top Menu State
    var file_menu_active: c_int = 0;
    var file_menu_edit = false;

    // Left Pane (Toggles & Selections)
    var check_val = false;
    var toggle_active = false;
    var radio_idx: c_int = 0; // 0 = Option A, 1 = Option B
    var combo_active: c_int = 0;

    // Right Pane (Values, Text & Lists)
    var slider_val: f32 = 50.0;
    var prog_val: f32 = 0.4;
    var spinner_val: c_int = 0;
    var spinner_edit = false;
    
    var textbox_text:[64:0]u8 = [_:0]u8{0} ** 64;
    var textbox_edit = false;
    
    var list_scroll: c_int = 0;
    var list_active: c_int = -1;

    // Mid Top (Color & Visualization)
    var color_picker_val = ray.Color{ .r = 200, .g = 100, .b = 50, .a = 255 };

    // Scroll States
    var scroll_mid = ray.Vector2{ .x = 0, .y = 0 };
    var scroll_bot = ray.Vector2{ .x = 0, .y = 0 };

    while (!ray.WindowShouldClose() and !exit_requested) {
        // Because of this line, the layout instantly adapts to window resizing!
        const vp = layout.Viewport.init(@floatFromInt(ray.GetScreenWidth()), @floatFromInt(ray.GetScreenHeight()));

        ray.BeginDrawing();
        defer ray.EndDrawing();
        ray.ClearBackground(ray.GetColor(@bitCast(ray.GuiGetStyle(ray.DEFAULT, ray.BACKGROUND_COLOR))));

        // --- PANELS ---
        _ = ray.GuiPanel(@bitCast(vp.leftPane()), "Selection Components");
        _ = ray.GuiPanel(@bitCast(vp.rightPane()), "Value Components");
        _ = ray.GuiPanel(@bitCast(vp.midTop()), "Visual Components");

        // --- 1. LEFT PANE (Checks, Radios, Toggles) ---
        const lp = vp.leftPane();
        _ = ray.GuiCheckBox(ray.Rectangle{ .x = lp.x + 20, .y = lp.y + 40, .width = 20, .height = 20 }, "Enable Feature X", &check_val);
        _ = ray.GuiToggle(ray.Rectangle{ .x = lp.x + 20, .y = lp.y + 80, .width = 120, .height = 30 }, "Master Switch", &toggle_active);
        
        ray.DrawText("Radio Group:", @intFromFloat(lp.x + 20), @intFromFloat(lp.y + 130), 10, ray.DARKGRAY);
        _ = ray.GuiToggleGroup(ray.Rectangle{ .x = lp.x + 20, .y = lp.y + 150, .width = 80, .height = 25 }, "Option A;Option B", &radio_idx);

        _ = ray.GuiComboBox(ray.Rectangle{ .x = lp.x + 20, .y = lp.y + 220, .width = 120, .height = 30 }, "Item 1;Item 2;Item 3", &combo_active);

        // --- 2. RIGHT PANE (Sliders, Spinners, Text & Lists) ---
        const rp = vp.rightPane();
        _ = ray.GuiSliderBar(ray.Rectangle{ .x = rp.x + 60, .y = rp.y + 40, .width = 100, .height = 20 }, "Vol", "100", &slider_val, 0, 100);
        _ = ray.GuiProgressBar(ray.Rectangle{ .x = rp.x + 60, .y = rp.y + 80, .width = 100, .height = 20 }, "Load", "", &prog_val, 0, 1.0);
        
        if (ray.GuiSpinner(ray.Rectangle{ .x = rp.x + 60, .y = rp.y + 120, .width = 100, .height = 25 }, "Count", &spinner_val, 0, 100, spinner_edit) != 0) {
            spinner_edit = !spinner_edit;
        }

        if (ray.GuiTextBox(ray.Rectangle{ .x = rp.x + 20, .y = rp.y + 170, .width = 160, .height = 30 }, &textbox_text, textbox_text.len, textbox_edit) != 0) {
            textbox_edit = !textbox_edit;
        }

        _ = ray.GuiListView(ray.Rectangle{ .x = rp.x + 20, .y = rp.y + 220, .width = 160, .height = 150 }, "Apple;Banana;Cherry;Date;Elderberry", &list_scroll, &list_active);

        // --- 3. MID TOP (Color Picker & Visuals) ---
        const mt = vp.midTop();
        _ = ray.GuiColorPicker(ray.Rectangle{ .x = mt.x + 20, .y = mt.y + 40, .width = 120, .height = 120 }, "Color Picker", &color_picker_val);
        
        // Draw a circle that reacts to the slider and color picker
        ray.DrawCircleV(ray.Vector2{ .x = mt.x + 350, .y = mt.y + 125 }, slider_val, color_picker_val);

        // --- 4. MID CENTER (Scroll Panel - Vertical) ---
        const mc = vp.midCenter();
        var view_mid: ray.Rectangle = undefined;
        // Content is taller than the pane to force a vertical scrollbar
        const content_mid = ray.Rectangle{ .x = 0, .y = 0, .width = mc.width - 25, .height = 1000 }; 
        _ = ray.GuiScrollPanel(@bitCast(mc), "Middle Pane (V-Scroll)", content_mid, &scroll_mid, &view_mid);

        // --- 5. MID BOTTOM (Scroll Panel - H + V) ---
        const mb = vp.midBottom();
        var view_bot: ray.Rectangle = undefined;
        // Content is wider and taller than the pane to force both scrollbars
        const content_bot = ray.Rectangle{ .x = 0, .y = 0, .width = 1500, .height = 800 }; 
        _ = ray.GuiScrollPanel(@bitCast(mb), "Bottom Pane (H+V Scroll)", content_bot, &scroll_bot, &view_bot);

        // --- 6. STATUS BAR (Bottom Edge) ---
        _ = ray.GuiStatusBar(ray.Rectangle{ .x = 0, .y = vp.h - 25, .width = vp.w, .height = 25 }, "System Normal. All components loaded.");

        // --- 7. MENU BAR & DROPDOWNS (Drawn Last to Overlap) ---
        _ = ray.GuiPanel(@bitCast(vp.menuBar()), "");
        if (ray.GuiButton(ray.Rectangle{ .x = vp.w - 60, .y = 2, .width = 50, .height = 26 }, "Exit") != 0) exit_requested = true;
        
        if (ray.GuiDropdownBox(ray.Rectangle{ .x = 5, .y = 2, .width = 140, .height = 26 }, "FILE;Open;Save;Save As;Exit", &file_menu_active, file_menu_edit) != 0) {
            file_menu_edit = !file_menu_edit;
            if (!file_menu_edit and file_menu_active == 4) exit_requested = true;
        }
    }
}
