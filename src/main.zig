const std = @import("std");
const Cpu = @import("cpu.zig").Cpu;
const Memory = @import("memory.zig").Memory;
const parser = @import("parser.zig");
const exec = @import("exec.zig");
const Instruction = @import("instruction.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    if (args.len < 2) {
        std.debug.print("Usage: {s} <assembly_file>\n", .{args[0]});
        return;
    }
    const asm_file_path = args[1];
    const asm_source = try std.fs.cwd().readFileAlloc(asm_file_path, allocator, std.Io.Limit.unlimited);

    var cpu = Cpu.init();
    var mem = Memory.init();
    const parsed = try parser.parseProgram(allocator, asm_source, &mem);

    for (parsed.text) |line| {
        const instr = Instruction.decode(line) orelse continue;

        exec.execute(instr, &cpu, &mem, &parsed.labels);
    }
}

test "simple test" {
    const gpa = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
    try list.append(gpa, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
