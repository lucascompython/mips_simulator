const std = @import("std");

pub const Register = enum(u8) {
    zero = 0,
    at,
    v0,
    v1,
    a0,
    a1,
    a2,
    a3,
    t0,
    t1,
    t2,
    t3,
    t4,
    t5,
    t6,
    t7,
    s0,
    s1,
    s2,
    s3,
    s4,
    s5,
    s6,
    s7,
    t8,
    t9,
    k0,
    k1,
    gp,
    sp,
    fp,
    ra,
};

pub fn parseReg(name: []const u8) u8 {
    if (name.len < 2 or name[0] != '$') return 0;

    const map = comptime std.StaticStringMap(u8).initComptime(.{
        .{ "zero", @intFromEnum(Register.zero) },
        .{ "at", @intFromEnum(Register.at) },
        .{ "v0", @intFromEnum(Register.v0) },
        .{ "v1", @intFromEnum(Register.v1) },
        .{ "a0", @intFromEnum(Register.a0) },
        .{ "a1", @intFromEnum(Register.a1) },
        .{ "a2", @intFromEnum(Register.a2) },
        .{ "a3", @intFromEnum(Register.a3) },
        .{ "t0", @intFromEnum(Register.t0) },
        .{ "t1", @intFromEnum(Register.t1) },
        .{ "t2", @intFromEnum(Register.t2) },
        .{ "t3", @intFromEnum(Register.t3) },
        .{ "t4", @intFromEnum(Register.t4) },
        .{ "t5", @intFromEnum(Register.t5) },
        .{ "t6", @intFromEnum(Register.t6) },
        .{ "t7", @intFromEnum(Register.t7) },
        .{ "s0", @intFromEnum(Register.s0) },
        .{ "s1", @intFromEnum(Register.s1) },
        .{ "s2", @intFromEnum(Register.s2) },
        .{ "s3", @intFromEnum(Register.s3) },
        .{ "s4", @intFromEnum(Register.s4) },
        .{ "s5", @intFromEnum(Register.s5) },
        .{ "s6", @intFromEnum(Register.s6) },
        .{ "s7", @intFromEnum(Register.s7) },
        .{ "t8", @intFromEnum(Register.t8) },
        .{ "t9", @intFromEnum(Register.t9) },
        .{ "k0", @intFromEnum(Register.k0) },
        .{ "k1", @intFromEnum(Register.k1) },
        .{ "gp", @intFromEnum(Register.gp) },
        .{ "sp", @intFromEnum(Register.sp) },
        .{ "fp", @intFromEnum(Register.fp) },
        .{ "ra", @intFromEnum(Register.ra) },
    });

    const r = name[1..]; // remove '$'
    return map.get(r) orelse 0;
}

pub const Cpu = struct {
    regs: [32]u32,
    pc: u32,

    pub fn init() Cpu {
        var cpu = Cpu{
            .regs = [_]u32{0} ** 32,
            .pc = 0x00400000, // default start for .text
        };
        cpu.regs[@intFromEnum(Register.sp)] = 0x7fffeffc; // stack pointer
        return cpu;
    }
};
