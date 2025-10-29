const std = @import("std");

pub const Memory = struct {
    data: []u8,

    pub fn init(allocator: std.mem.Allocator, size: usize) !Memory {
        const buf = try allocator.alloc(u8, size);
        return Memory{ .data = buf };
    }

    // read 4 bytes from memory and combines them into a single 32-bit value
    pub fn loadWord(self: *Memory, addr: u32) !u32 {
        if (addr + 3 >= self.data.len) return error.OutOfBounds;
        return (@as(u32, self.data[addr]) << 24) | (@as(u32, self.data[addr + 1]) << 16) | (@as(u32, self.data[addr + 2]) << 8) | @as(u32, self.data[addr + 3]);
    }

    // write a 32-bit value into memory, one byte at a time
    pub fn storeWord(self: *Memory, addr: u32, val: u32) !void {
        if (addr + 3 >= self.data.len) return error.OutOfBounds;
        self.data[addr] = @intCast((val >> 24) & 0xFF);
        self.data[addr + 1] = @intCast((val >> 16) & 0xFF);
        self.data[addr + 2] = @intCast((val >> 8) & 0xFF);
        self.data[addr + 3] = @intCast(val & 0xFF);
    }
};
