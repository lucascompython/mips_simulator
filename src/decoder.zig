const std = @import("std");
const Instruction = @import("instruction.zig").Instruction;
const parseReg = @import("cpu.zig").parseReg;

// TODO: use StaticStringMap for opcodes for efficiency
pub fn decode(line: []const u8) ?Instruction {
    var parts = std.mem.tokenizeAny(u8, line, " ,\t");
    const op = parts.next() orelse return null;

    if (std.mem.eql(u8, op, "add")) {
        const rd = parseReg(parts.next() orelse return null);
        const rs = parseReg(parts.next() orelse return null);
        const rt = parseReg(parts.next() orelse return null);
        return Instruction{ .Add = .{ .rd = rd, .rs = rs, .rt = rt } };
    } else if (std.mem.eql(u8, op, "addi")) {
        const rt = parseReg(parts.next() orelse return null);
        const rs = parseReg(parts.next() orelse return null);
        const imm_str = parts.next() orelse return null;
        const imm = std.fmt.parseInt(i16, imm_str, 10) catch return null;
        return Instruction{ .Addi = .{ .rt = rt, .rs = rs, .imm = imm } };
    } else if (std.mem.eql(u8, op, "lui")) {
        const rt = parseReg(parts.next() orelse return null);
        const imm_str = parts.next() orelse return null;
        const imm = std.fmt.parseInt(u16, imm_str, 10) catch return null;
        return Instruction{ .Lui = .{ .rt = rt, .imm = imm } };
    } else if (std.mem.eql(u8, op, "ori")) {
        const rt = parseReg(parts.next() orelse return null);
        const rs = parseReg(parts.next() orelse return null);
        const imm_str = parts.next() orelse return null;
        const imm = std.fmt.parseInt(u16, imm_str, 10) catch return null;
        return Instruction{ .Ori = .{ .rt = rt, .rs = rs, .imm = imm } };
    } else if (std.mem.eql(u8, op, "li")) {
        const rt = parseReg(parts.next() orelse return null);
        const imm_str = parts.next() orelse return null;
        const imm = std.fmt.parseInt(i32, imm_str, 10) catch return null;
        return Instruction{ .Li = .{ .rt = rt, .imm = imm } };
    } else if (std.mem.eql(u8, op, "la")) {
        const rt = parseReg(parts.next() orelse return null);
        const label = parts.next() orelse return null;
        return Instruction{ .La = .{ .rt = rt, .label = label } };
    } else if (std.mem.eql(u8, op, "syscall")) {
        return Instruction{ .Syscall = {} };
    }

    return null;
}
