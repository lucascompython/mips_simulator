const std = @import("std");

const Instruction = @import("instruction.zig").Instruction;
const OPCODE_MAP = @import("instruction.zig").OPCODE_MAP;
const parseReg = @import("cpu.zig").parseReg;

pub fn decode(line: []const u8) ?Instruction {
    var parts = std.mem.tokenizeAny(u8, line, " ,\t");
    const op = parts.next() orelse return null;

    const opcode = OPCODE_MAP.get(op) orelse return null;

    switch (opcode) {
        .Add => {
            const rd = parseReg(parts.next() orelse return null);
            const rs = parseReg(parts.next() orelse return null);
            const rt = parseReg(parts.next() orelse return null);
            return Instruction{ .Add = .{ .rd = rd, .rs = rs, .rt = rt } };
        },
        .Addi => {
            const rt = parseReg(parts.next() orelse return null);
            const rs = parseReg(parts.next() orelse return null);
            const imm_str = parts.next() orelse return null;
            const imm = std.fmt.parseInt(i16, imm_str, 10) catch return null;
            return Instruction{ .Addi = .{ .rt = rt, .rs = rs, .imm = imm } };
        },
        .Lui => {
            const rt = parseReg(parts.next() orelse return null);
            const imm_str = parts.next() orelse return null;
            const imm = std.fmt.parseInt(u16, imm_str, 10) catch return null;
            return Instruction{ .Lui = .{ .rt = rt, .imm = imm } };
        },
        .Ori => {
            const rt = parseReg(parts.next() orelse return null);
            const rs = parseReg(parts.next() orelse return null);
            const imm_str = parts.next() orelse return null;
            const imm = std.fmt.parseInt(u16, imm_str, 10) catch return null;
            return Instruction{ .Ori = .{ .rt = rt, .rs = rs, .imm = imm } };
        },
        .Li => {
            const rt = parseReg(parts.next() orelse return null);
            const imm_str = parts.next() orelse return null;
            const imm = std.fmt.parseInt(i32, imm_str, 10) catch return null;
            return Instruction{ .Li = .{ .rt = rt, .imm = imm } };
        },
        .La => {
            const rt = parseReg(parts.next() orelse return null);
            const label = parts.next() orelse return null;
            return Instruction{ .La = .{ .rt = rt, .label = label } };
        },
        .Syscall => return Instruction{ .Syscall = {} },
    }
}
