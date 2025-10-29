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
