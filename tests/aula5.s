    .data
string: .asciiz "Mensagem de teste."

    .text

main: la $a0, string
jal strlen
move $a0, $v0
li $v0, 1
syscall

#li $v0, 10
#li $a0, 0
#syscall

strlen: li $t0, 0
while: lbu $t1, 0($a0)
beqz $t1, termina
addi $t0, $t0, 1
addi $t0, $a0, 1
j while

termina: move $v0, $t0
jr $ra
