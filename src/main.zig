const std = @import("std");
const Cpu = @import("cpu.zig").Cpu;
const Memory = @import("memory.zig").Memory;
const Parser = @import("parser.zig");

pub fn bufferedPrint() !void {
    // Stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try stdout.flush(); // Don't forget to flush!

}

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    try bufferedPrint();

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
    //
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

    const allocator = arena.allocator();

    const asm_source =
        \\ .data
        \\ msg1: .asciiz "Introduza 2 numeros inteiros: "
        \\ msg2: .asciiz "A soma dos dois numeros é: "
        \\
        \\ .text
        \\ li $v0, 4
        \\ la $a0, msg1
        \\ syscall
    ;

    var mem = Memory.init();
    const parsed = try Parser.parseProgram(allocator, asm_source, &mem);

    std.debug.print("Labels:\n", .{});
    var it = parsed.labels.map.iterator();
    while (it.next()) |entry| {
        std.debug.print("  {s} = {x}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }

    std.debug.print("\nText lines:\n", .{});
    for (parsed.text) |line| {
        std.debug.print("  {s}\n", .{line});
    }
}

test "simple test" {
    const gpa = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
    try list.append(gpa, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
