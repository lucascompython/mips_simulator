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
