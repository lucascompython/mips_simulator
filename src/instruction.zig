const std = @import("std");
const parseReg = @import("cpu.zig").parseReg;

pub const Instruction = union(enum) {
    Add: struct { rd: u8, rs: u8, rt: u8 },
    Addi: struct { rt: u8, rs: u8, imm: i16 },
    Lui: struct { rt: u8, imm: u16 },
    Ori: struct { rt: u8, rs: u8, imm: u16 },
    Syscall: void,

    // pseudo instructions (expanded before execution)
    Li: struct { rt: u8, imm: i32 },
    La: struct { rt: u8, label: []const u8 },
};

pub const OpCode = std.meta.Tag(Instruction);

fn toLowerComptime(comptime input: []const u8) []const u8 {
    const result = blk: {
        var buf: [input.len]u8 = undefined;
        for (input, 0..) |c, i| {
            buf[i] = std.ascii.toLower(c);
        }
        const final = buf;
        break :blk final;
    };
    return &result;
}

pub const OPCODE_MAP = blk: {
    const fields = @typeInfo(Instruction).@"union".fields;
    var kvs: [fields.len]struct { []const u8, OpCode } = undefined;

    for (fields, 0..) |field, i| {
        kvs[i] = .{ toLowerComptime(field.name), @field(OpCode, field.name) };
    }

    break :blk std.StaticStringMap(OpCode).initComptime(kvs);
};

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
