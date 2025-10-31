	.data
msg_result: 	.asciiz "Result: "
newline:        .asciiz "\n"

	.text
main:
	# Test 1: subi instruction
	li $t0, 100
	subi $t1, $t0, 25    # $t1 = 100 - 25 = 75

	li $v0, 4
	la $a0, msg_result
	syscall

	li $v0, 1
	move $a0, $t1
	syscall

	li $v0, 4
	la $a0, newline
	syscall

	# Test 2: subi with negative immediate
	li $t2, 50
	subi $t3, $t2, -10   # $t3 = 50 - (-10) = 60

	li $v0, 4
	la $a0, msg_result
	syscall

	li $v0, 1
	move $a0, $t3
	syscall

	li $v0, 4
	la $a0, newline
	syscall

	# Test 3: andi instruction
	li $t4, 0xFF         # 255 in binary: 11111111
	andi $t5, $t4, 0x0F  # AND with 00001111 = 15

	li $v0, 4
	la $a0, msg_result
	syscall

	li $v0, 1
	move $a0, $t5
	syscall

	li $v0, 4
	la $a0, newline
	syscall

	# Test 4: andi for bit masking
	li $t6, 170          # 10101010 in binary
	andi $t7, $t6, 85    # AND with 01010101 = 0

	li $v0, 4
	la $a0, msg_result
	syscall

	li $v0, 1
	move $a0, $t7
	syscall

	li $v0, 4
	la $a0, newline
	syscall

	# Test 5: combining operations
	li $t8, 200
	subi $t8, $t8, 50    # 150
	andi $t8, $t8, 127   # 150 AND 127 = 22 (10010110 AND 01111111 = 00010110)

	li $v0, 4
	la $a0, msg_result
	syscall

	li $v0, 1
	move $a0, $t8
	syscall

	li $v0, 4
	la $a0, newline
	syscall
