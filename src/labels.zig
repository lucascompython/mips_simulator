const std = @import("std");

pub const LabelTable = struct {
    map: std.StringHashMap(u32),

    pub fn init(allocator: std.mem.Allocator) LabelTable {
        return LabelTable{ .map = std.StringHashMap(u32).init(allocator) };
    }

    pub fn put(self: *LabelTable, name: []const u8, addr: u32) !void {
        try self.map.put(name, addr);
    }

    pub fn get(self: *LabelTable, name: []const u8) ?u32 {
        return self.map.get(name);
    }
};
