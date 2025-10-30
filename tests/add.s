    	.data
msg1: 	.asciiz "Enter the first number: "
msg2:   .asciiz "Enter the second number: "
msg3: 	.asciiz "The sum is: "

    	.text

li $v0, 4 # v0=4 is print_str
la $a0, msg1
syscall

li $v0, 5 # v0=5 is read_int
syscall
add $t0, $zero, $v0 # t0 = a, add with zero is just move

la $a0, msg2
li $v0, 4
syscall

li $v0, 5
syscall
add $t1, $zero, $v0 # t1 = b


la $a0, msg3

li $v0,4
syscall

add $a0, $t0, $t1 # a0 is the input parameter for print_int
li $v0,1
syscall
