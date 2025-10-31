	.data
msg_result: 	.asciiz "Result: "
newline:        .asciiz "\n"

	.text
main:
	# Test 1: move instruction
	li $t0, 42
	move $t1, $t0        # $t1 = $t0 = 42

	li $v0, 4
	la $a0, msg_result
	syscall

	li $v0, 1
	move $a0, $t1
	syscall

	li $v0, 4
	la $a0, newline
	syscall

	# Test 2: sll instruction - shift left by 1 (multiply by 2)
	li $t2, 10
	sll $t3, $t2, 1      # $t3 = 10 << 1 = 20

	li $v0, 4
	la $a0, msg_result
	syscall

	li $v0, 1
	move $a0, $t3
	syscall

	li $v0, 4
	la $a0, newline
	syscall

	# Test 3: sll instruction - shift left by 2 (multiply by 4)
	li $t4, 7
	sll $t5, $t4, 2      # $t5 = 7 << 2 = 28

	li $v0, 4
	la $a0, msg_result
	syscall

	li $v0, 1
	move $a0, $t5
	syscall

	li $v0, 4
	la $a0, newline
	syscall

	# Test 4: sll instruction - shift left by 4 (multiply by 16)
	li $t6, 5
	sll $t7, $t6, 4      # $t7 = 5 << 4 = 80

	li $v0, 4
	la $a0, msg_result
	syscall

	li $v0, 1
	move $a0, $t7
	syscall

	li $v0, 4
	la $a0, newline
	syscall

	# Test 5: combining move and sll
	li $t8, 3
	move $t9, $t8        # $t9 = 3
	sll $t9, $t9, 3      # $t9 = 3 << 3 = 24

	li $v0, 4
	la $a0, msg_result
	syscall

	li $v0, 1
	move $a0, $t9
	syscall

	li $v0, 4
	la $a0, newline
	syscall
