const std = @import("std");
const Memory = @import("memory.zig").Memory;
const LabelTable = @import("labels.zig").LabelTable;
const DATA_START = @import("memory.zig").DATA_START;

pub const ParsedProgram = struct {
    text: []const []const u8, // raw instruction strings for now
    labels: LabelTable,
    data_end: u32,
};

pub fn parseProgram(allocator: std.mem.Allocator, src: []const u8, mem: *Memory) !ParsedProgram {
    var lines = std.mem.tokenizeAny(u8, src, "\r\n");
    var labels = LabelTable.init(allocator);
    var text_instructions: std.ArrayList([]const u8) = .empty;
    defer text_instructions.deinit(allocator);
    var in_data = false;
    var in_text = false;
    var data_ptr: u32 = DATA_START;
    var text_instruction_count: u32 = 0;

    while (lines.next()) |line_raw| {
        var line = std.mem.trim(u8, line_raw, " \t");
        if (line.len == 0 or line[0] == '#') continue;

        if (std.mem.eql(u8, line, ".data")) {
            in_data = true;
            in_text = false;
            continue;
        }
        if (std.mem.eql(u8, line, ".text")) {
            in_data = false;
            in_text = true;
            continue;
        }

        // handle label definitions
        if (std.mem.findScalar(u8, line, ':')) |colon_idx| {
            const label = line[0..colon_idx];
            if (in_data) {
                try labels.put(label, data_ptr);
            } else if (in_text) {
                const text_addr = @import("memory.zig").TEXT_START + (text_instruction_count * 4);
                try labels.put(label, text_addr);
            }

            if (colon_idx + 1 < line.len) {
                line = std.mem.trim(u8, line[colon_idx + 1 ..], " \t");
                // Fall through to process the rest of the line
            } else {
                continue;
            }
        }

        if (in_data) {
            // example: msg1: .asciiz "Hello"
            // or
            // msg1:
            // .asciiz "Hello"
            if (std.mem.startsWith(u8, line, ".asciiz")) {
                const quote_start = std.mem.findScalar(u8, line, '"') orelse continue;
                const quote_end = std.mem.findScalarLast(u8, line, '"') orelse continue;
                const str = line[quote_start + 1 .. quote_end];
                for (str, 0..) |c, i| {
                    mem.data[(data_ptr - DATA_START) + i] = c;
                }
                mem.data[(data_ptr - DATA_START) + str.len] = 0;
                data_ptr += @intCast(str.len + 1);
            }
        } else if (in_text) {
            try text_instructions.append(allocator, line);
            text_instruction_count += 1;
        }
    }

    return ParsedProgram{
        .text = try text_instructions.toOwnedSlice(allocator),
        .labels = labels,
        .data_end = data_ptr,
    };
}
