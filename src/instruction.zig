const Cpu = @import("cpu.zig").Cpu;

pub const Instruction = union(enum) {
    Add: struct { rd: u8, rs: u8, rt: u8 },
    Addi: struct { rt: u8, rs: u8, imm: i16 },
    Lw: struct { rt: u8, base: u8, offset: i16 },
    Sw: struct { rt: u8, base: u8, offset: i16 },
    Beq: struct { rs: u8, rt: u8, offset: i16 },
    J: struct { address: u32 },

    // takes in 32-bit instruction word, and figures out which instruction it is
    // for example: 000000 01000 01001 01010 00000 100000 -> add $t2, $t0, $t1
    pub fn decode(word: u32) Instruction {
        const opcode = (word >> 26) & 0x3F; // first 6 bits (intruction type)

        switch (opcode) {
            0 => { // R-type -> register to register
                const rs: u8 = @intCast((word >> 21) & 0x1F);
                const rt: u8 = @intCast((word >> 16) & 0x1F);
                const rd: u8 = @intCast((word >> 11) & 0x1F);
                const funct = word & 0x3F;
                if (funct == 0x20) return Instruction{ .Add = .{ .rs = rs, .rt = rt, .rd = rd } };
            },
            0x08 => return Instruction{ .Addi = .{
                .rs = @intCast((word >> 21) & 0x1F),
                .rt = @intCast((word >> 16) & 0x1F),
                .imm = @intCast(word & 0xFFFF),
            } },
            0x23 => return Instruction{ .Lw = .{
                .base = @intCast((word >> 21) & 0x1F),
                .rt = @intCast((word >> 16) & 0x1F),
                .offset = @intCast(word & 0xFFFF),
            } },
            0x2B => return Instruction{ .Sw = .{
                .base = @intCast((word >> 21) & 0x1F),
                .rt = @intCast((word >> 16) & 0x1F),
                .offset = @intCast(word & 0xFFFF),
            } },
            0x04 => return Instruction{ .Beq = .{
                .rs = @intCast((word >> 21) & 0x1F),
                .rt = @intCast((word >> 16) & 0x1F),
                .offset = @intCast(word & 0xFFFF),
            } },
            0x02 => return Instruction{ .J = .{
                .address = word & 0x3FFFFFF,
            } },
            else => @panic("Unknown opcode"),
        }

        @panic("Failed to decode instruction");
    }

    pub fn execute(self: Instruction, cpu: *Cpu) !void {
        switch (self) {
            .Add => |i| cpu.regs[i.rd] = cpu.regs[i.rs] + cpu.regs[i.rt],
            .Addi => |i| cpu.regs[i.rt] = cpu.regs[i.rs] + @as(u32, @intCast(i.imm)),
            .Lw => |i| cpu.regs[i.rt] = try cpu.mem.loadWord(cpu.regs[i.base] + @as(u32, @intCast(i.offset))),
            .Sw => |i| try cpu.mem.storeWord(cpu.regs[i.base] + @as(u32, @intCast(i.offset)), cpu.regs[i.rt]),
            .Beq => |i| {
                if (cpu.regs[i.rs] == cpu.regs[i.rt]) {
                    cpu.pc += @as(u32, @intCast(i.offset)) << 2;
                }
            },
            .J => |i| cpu.pc = (cpu.pc & 0xF0000000) | (i.address << 2),
        }
    }
};
