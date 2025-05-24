# Teste de instruções M (MUL/DIV/REM)
.section .text
.global _start
_start:
    li t0, 12345
    li t1, 54321
    mul t2, t0, t1      # t2 = t0 * t1
    mulh t3, t0, t1     # t3 = parte alta signed
    mulhu t4, t0, t1    # t4 = parte alta unsigned
    mulhsu t5, t0, t1   # t5 = parte alta signed/unsigned
    div t6, t1, t0      # t6 = t1 / t0
    divu t0, t1, t0     # t0 = t1 / t0 unsigned
    rem t1, t1, t0      # t1 = t1 % t0
    remu t2, t1, t0     # t2 = t1 % t0 unsigned
    # Resultado final para verificação
    sw t2, 0x100(zero)  # salva resultado MUL em RAM
    sw t3, 0x104(zero)  # salva resultado MULH
    sw t4, 0x108(zero)  # salva resultado MULHU
    sw t5, 0x10c(zero)  # salva resultado MULHSU
    sw t6, 0x110(zero)  # salva resultado DIV
    sw t0, 0x114(zero)  # salva resultado DIVU
    sw t1, 0x118(zero)  # salva resultado REM
    sw t2, 0x11c(zero)  # salva resultado REMU
    j .
