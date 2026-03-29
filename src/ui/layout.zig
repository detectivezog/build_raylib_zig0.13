const std = @import("std");

pub const Rect = extern struct { x: f32, y: f32, width: f32, height: f32 };

pub const Viewport = struct {
    w: f32,
    h: f32,
    menu_h: f32 = 30,
    side_w: f32 = 220,
    top_fixed_h: f32 = 250,

    pub fn init(w: f32, h: f32) Viewport {
        return .{ .w = w, .h = h };
    }

    pub fn menuBar(self: Viewport) Rect { return .{ .x = 0, .y = 0, .width = self.w, .height = self.menu_h }; }
    pub fn leftPane(self: Viewport) Rect { return .{ .x = 0, .y = self.menu_h, .width = self.side_w, .height = self.h - self.menu_h - 25 }; }
    pub fn rightPane(self: Viewport) Rect { return .{ .x = self.w - self.side_w, .y = self.menu_h, .width = self.side_w, .height = self.h - self.menu_h - 25 }; }
    pub fn midTop(self: Viewport) Rect { return .{ .x = self.side_w, .y = self.menu_h, .width = self.w - (self.side_w * 2), .height = self.top_fixed_h }; }
    
    pub fn midCenter(self: Viewport) Rect {
        const avail = self.h - self.menu_h - self.top_fixed_h - 25;
        return .{ .x = self.side_w, .y = self.menu_h + self.top_fixed_h, .width = self.w - (self.side_w * 2), .height = avail * 0.75 };
    }
    
    pub fn midBottom(self: Viewport) Rect {
        const avail = self.h - self.menu_h - self.top_fixed_h - 25;
        return .{ .x = self.side_w, .y = self.menu_h + self.top_fixed_h + (avail * 0.75), .width = self.w - (self.side_w * 2), .height = avail * 0.25 };
    }
};
