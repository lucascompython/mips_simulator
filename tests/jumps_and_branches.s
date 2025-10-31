	.data
msg_positive: 	.asciiz "Number is positive or zero\n"
msg_negative: 	.asciiz "Number is negative\n"
msg_equal:      .asciiz "Numbers are equal\n"
msg_not_equal:  .asciiz "Numbers are not equal\n"
msg_loop:       .asciiz "Loop iteration\n"
msg_done:       .asciiz "Done!\n"

	.text
main:
	# Test 1: bgez instruction
	li $t0, 5
	bgez $t0, positive
	j skip_positive

positive:
	li $v0, 4
	la $a0, msg_positive
	syscall

skip_positive:
	# Test 2: bgez with negative number (should not branch)
	li $t1, -3
	bgez $t1, skip_negative
	li $v0, 4
	la $a0, msg_negative
	syscall

skip_negative:
	# Test 3: beq instruction
	li $t2, 10
	li $t3, 10
	beq $t2, $t3, equal
	j not_equal

equal:
	li $v0, 4
	la $a0, msg_equal
	syscall
	j after_equal

not_equal:
	li $v0, 4
	la $a0, msg_not_equal
	syscall

after_equal:
	# Test 4: bne instruction
	li $t4, 7
	li $t5, 9
	bne $t4, $t5, different
	j after_bne

different:
	li $v0, 4
	la $a0, msg_not_equal
	syscall

after_bne:
	# Test 5: simple loop with counter
	li $t6, 0        # counter
	li $t7, 3        # max count

loop:
	beq $t6, $t7, end_loop

	li $v0, 4
	la $a0, msg_loop
	syscall

	addi $t6, $t6, 1
	j loop

end_loop:
	li $v0, 4
	la $a0, msg_done
	syscall

	# Exit (infinite loop or syscall depending on implementation)
	j exit

exit:
	j exit
