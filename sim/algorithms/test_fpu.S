# Teste de FPU: soma, sub, mul, div
.section .data
float_a: .word 0x41200000 # 10.0
float_b: .word 0x40a00000 # 5.0
.section .text
.global _start
_start:
    la t0, float_a
    lw t1, 0(t0)      # t1 = 10.0
    la t0, float_b
    lw t2, 0(t0)      # t2 = 5.0
    # FPU custom: opcode 0x1010011, funct3 define operação
    # ADD
    .word 0x0020a053  # custom: fadd t0, t1, t2 (funct3=000)
    sw t0, 0x200(zero)
    # SUB
    .word 0x0020a153  # custom: fsub t0, t1, t2 (funct3=001)
    sw t0, 0x204(zero)
    # MUL
    .word 0x0020a253  # custom: fmul t0, t1, t2 (funct3=010)
    sw t0, 0x208(zero)
    # DIV
    .word 0x0020a353  # custom: fdiv t0, t1, t2 (funct3=011)
    sw t0, 0x20c(zero)
    j .
