    	.text

li $t0, 10       # Load immediate value 10 into register $t0
li $t1, 20       # Load immediate value 20 into register $t1

and $t2, $t0, $t1   # $t2 = $t0 AND $t1
or $t3, $t0, $t1    # $t3 = $t0 OR $t1
nor $t4, $t0, $t1   # $t4 = NOT ($t0 OR $t1)
xor $t5, $t0, $t1   # $t5 = $t0 XOR $t1
