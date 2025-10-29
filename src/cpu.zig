const std = @import("std");

const Memory = @import("memory.zig").Memory;
const Instruction = @import("instruction.zig").Instruction;

pub const Cpu = struct {
    regs: [32]u32,
    pc: u32,
    mem: *Memory,

    pub fn init(mem: *Memory) Cpu {
        return Cpu{
            .regs = [_]u32{0} ** 32,
            .pc = 0,
            .mem = mem,
        };
    }

    pub fn step(self: *Cpu) !void {
        const instr_word = try self.mem.loadWord(self.pc);
        const instr = Instruction.decode(instr_word);
        self.pc += 4;
        try instr.execute(self);
    }
};
