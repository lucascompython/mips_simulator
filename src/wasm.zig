const std = @import("std");
const Cpu = @import("cpu.zig").Cpu;
const Memory = @import("memory.zig").Memory;
const parser = @import("parser.zig");
const Instruction = @import("instruction.zig").Instruction;
const decode = @import("instruction.zig").decode;
const Register = @import("cpu.zig").Register;
const LabelTable = @import("labels.zig").LabelTable;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var cpu: Cpu = undefined;
var mem: Memory = undefined;
var output_buffer: [4096]u8 = undefined;
var output_len: usize = 0;
var input_buffer: [256]u8 = undefined;
var input_len: usize = 0;
var waiting_for_input: bool = false;
var parsed_labels: LabelTable = undefined;
var current_instruction: usize = 0;
var instructions: []const []const u8 = undefined;

export fn init() void {
    cpu = Cpu.init();
    mem = Memory.init();
    output_len = 0;
    input_len = 0;
    waiting_for_input = false;
    current_instruction = 0;
}

export fn getOutputPtr() [*]const u8 {
    return &output_buffer;
}

export fn getOutputLen() usize {
    return output_len;
}

export fn clearOutput() void {
    output_len = 0;
}

export fn isWaitingForInput() bool {
    return waiting_for_input;
}

export fn provideInput(ptr: [*]const u8, len: usize) void {
    const bytes = ptr[0..len];
    const to_copy = @min(len, input_buffer.len);
    @memcpy(input_buffer[0..to_copy], bytes[0..to_copy]);
    input_len = to_copy;
    waiting_for_input = false;
}

export fn getInputValue() i32 {
    if (input_len == 0) return 0;
    const value = std.fmt.parseInt(i32, input_buffer[0..input_len], 10) catch 0;
    input_len = 0;
    return value;
}

fn appendOutput(str: []const u8) void {
    const remaining = output_buffer.len - output_len;
    const to_copy = @min(remaining, str.len);
    @memcpy(output_buffer[output_len .. output_len + to_copy], str[0..to_copy]);
    output_len += to_copy;
}

fn handleSyscallWasm(cpu_ptr: *Cpu, mem_ptr: *Memory) void {
    const v0 = cpu_ptr.regs[@intFromEnum(Register.v0)];
    const a0 = cpu_ptr.regs[@intFromEnum(Register.a0)];

    switch (v0) {
        1 => { // print_int
            var buf: [32]u8 = undefined;
            const str = std.fmt.bufPrint(&buf, "{d}", .{cpu_ptr.regs[@intFromEnum(Register.a0)]}) catch "?";
            appendOutput(str);
        },
        4 => { // print_str
            var addr = a0;
            const DATA_START = @import("memory.zig").DATA_START;
            while (addr < DATA_START + mem_ptr.data.len) {
                const c = mem_ptr.data[addr - DATA_START];
                if (c == 0) break;
                appendOutput(&[_]u8{c});
                addr += 1;
            }
        },
        5 => { // read_int
            waiting_for_input = true;
        },
        else => {},
    }
}

fn executeInstruction(instr: Instruction, cpu_ptr: *Cpu, mem_ptr: *Memory, labels: *const LabelTable) void {
    switch (instr) {
        .Add => |i| cpu_ptr.regs[i.rd] = cpu_ptr.regs[i.rs] + cpu_ptr.regs[i.rt],
        .Addi => |i| cpu_ptr.regs[i.rt] = cpu_ptr.regs[i.rs] +% @as(u32, @bitCast(@as(i32, i.imm))),
        .Lui => |i| cpu_ptr.regs[i.rt] = @as(u32, i.imm) << 16,
        .Ori => |i| cpu_ptr.regs[i.rt] = cpu_ptr.regs[i.rs] | @as(u32, i.imm),
        .Li => |i| cpu_ptr.regs[i.rt] = @bitCast(i.imm),
        .La => |i| {
            const addr = labels.get(i.label) orelse 0;
            cpu_ptr.regs[i.rt] = addr;
        },
        .Syscall => handleSyscallWasm(cpu_ptr, mem_ptr),
    }
}

export fn run(code_ptr: [*]const u8, code_len: usize) i32 {
    init();

    const allocator = gpa.allocator();
    const code = code_ptr[0..code_len];

    const parsed = parser.parseProgram(allocator, code, &mem) catch {
        const err_msg = "Parse error\n";
        appendOutput(err_msg);
        return -1;
    };

    parsed_labels = parsed.labels;
    instructions = parsed.text;
    current_instruction = 0;

    // execute all instructions
    while (current_instruction < instructions.len) {
        const line = instructions[current_instruction];
        const instr = decode(line) orelse {
            current_instruction += 1;
            continue;
        };

        executeInstruction(instr, &cpu, &mem, &parsed_labels);

        if (waiting_for_input) {
            // save state and return, will continue from next instruction
            current_instruction += 1;
            return 1; // signal that we're waiting for input
        }

        current_instruction += 1;
    }

    return 0;
}

export fn continueAfterInput() i32 {
    // set the input value in the register
    const value = getInputValue();
    cpu.regs[@intFromEnum(Register.v0)] = @bitCast(value);
    waiting_for_input = false;

    // continue execution from where we left off
    while (current_instruction < instructions.len) {
        const line = instructions[current_instruction];
        const instr = decode(line) orelse {
            current_instruction += 1;
            continue;
        };

        executeInstruction(instr, &cpu, &mem, &parsed_labels);

        if (waiting_for_input) {
            current_instruction += 1;
            return 1;
        }

        current_instruction += 1;
    }

    const allocator = gpa.allocator();
    allocator.free(instructions);

    return 0;
}

export fn getRegister(reg: u8) u32 {
    if (reg >= 32) return 0;
    return cpu.regs[reg];
}

export fn getPC() u32 {
    return cpu.pc;
}
