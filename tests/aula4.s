        .data
pedido: .asciiz "Intruduza um numero inteiro: "
valor:  .asciiz "Valor em binario: "
zero:   .asciiz "0"
um:     .asciiz "1"

        .text

li $v0, 4
la $a0, pedido
syscall

li $v0, 5
syscall
move $t0, $v0      # Armazena o numero lido em $t0

li $v0, 4
la $a0, valor
syscall

li $t2, 0

ciclo: andi $t1, $t0, 0x80000000
bne $t1, $zero, mostra_um
li $v0, 4
la $a0, zero
syscall

j resto

mostra_um: li $v0, 4
la $a0, um
syscall

resto: sll $t0, $t0, 1

addi $t2, $t2, 1
subi  $t3, $t2, 32

bne $t3, $zero, ciclo
