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

    var instructions: std.ArrayList(Instruction.Instruction) = .empty;
    defer instructions.deinit(allocator);

    for (parsed.text) |line| {
        const instr = Instruction.decode(line) orelse {
            std.debug.print("Warning: could not decode instruction: {s}\n", .{line});
            continue;
        };
        try instructions.append(allocator, instr);
    }

    const TEXT_START = @import("memory.zig").TEXT_START;

    // TODO: extract this loop to a function, this is also used in wasm.zig
    while (true) {
        if (cpu.pc < TEXT_START) break;
        const pc_offset = cpu.pc - TEXT_START;
        const instr_idx = pc_offset / 4;

        if (instr_idx >= instructions.items.len) break;

        const instr = instructions.items[instr_idx];
        const old_pc = cpu.pc;

        exec.execute(instr, &cpu, &mem, &parsed.labels);

        // if PC wasn't modified by a jump/branch, advance to next instruction
        if (cpu.pc == old_pc) {
            cpu.pc += 4;
        }
    }
}
