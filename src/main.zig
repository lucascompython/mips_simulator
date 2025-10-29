const std = @import("std");
const Cpu = @import("cpu.zig").Cpu;
const Memory = @import("memory.zig").Memory;
const parser = @import("parser.zig");
const decoder = @import("decoder.zig");
const exec = @import("exec.zig");

pub fn main() !void {

    // var gpa = std.heap.ArenaAllocator.init(std.heap.smp_allocator);
    // const allocator = gpa.allocator();

    // var mem = try Memory.init(allocator, 1024 * 1024);
    // var cpu = Cpu.init(&mem);

    // // For now, manually load an instruction
    // try mem.storeWord(0, 0x20080005); // addi $t0, $zero, 5
    // try mem.storeWord(4, 0x2009000A); // addi $t1, $zero, 10
    // try mem.storeWord(8, 0x01095020); // add $t2, $t0, $t1

    // // Run 3 instructions
    // try cpu.step();
    // try cpu.step();
    // try cpu.step();

    // std.debug.print("t2 = {}\n", .{cpu.regs[10]}); // expect 15

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

    const allocator = arena.allocator();

    // TODO: load from file
    const asm_source =
        \\ .data
        \\ msg1: .asciiz "Introduza 2 numeros inteiros: "
        \\ msg2: .asciiz "A soma dos dois numeros é: "
        \\
        \\ .text
        \\ li $v0, 4 # v0 = 4 (print_str)
        \\ la $a0, msg1
        \\ syscall
        \\ li $v0, 5 # v0 = 5 (read_int)
        \\ syscall
        \\
        \\ add $t0, $zero, $v0 # t1 = first number
        \\
        \\ li $v0, 5 # v0 = 5 (read_int)
        \\ syscall
        \\
        \\ add $t1, $zero, $v0 # t2 = second number
        \\
        \\ la $a0, msg2
        \\
        \\ li $v0, 4 # v0 = 4 (print_str)
        \\ syscall
        \\
        \\ add $a0, $t0, $t1 # a0 is the input param for print_int
        \\ li $v0, 1
        \\ syscall
    ;

    var cpu = Cpu.init();
    var mem = Memory.init();
    const parsed = try parser.parseProgram(allocator, asm_source, &mem);

    for (parsed.text) |line| {
        const instr = decoder.decode(line) orelse continue;
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
