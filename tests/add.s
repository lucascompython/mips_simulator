    	.data
msg1: 	.asciiz "Introduza 2 numeros inteiros: "
msg2:   .asciiz "Introduza o segundo numero: "
msg3: 	.asciiz "A soma dos dois numeros é: "

    	.text

li $v0, 4 # v0=4 é print_str
la $a0, msg1
syscall

li $v0, 5 # v0=5 é read_int
syscall
add $t0, $zero, $v0 # t0 = a, add com zero é so um mov

la $a0, msg2
li $v0, 4
syscall

li $v0, 5
syscall
add $t1, $zero, $v0 # t1 = b


la $a0, msg3

li $v0,4
syscall

add $a0, $t0, $t1 # a0 é parametro de entrada para o v0 que é o print int
li $v0,1
syscall
