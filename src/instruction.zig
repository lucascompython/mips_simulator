const std = @import("std");

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
