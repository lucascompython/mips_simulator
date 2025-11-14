    .data
msg_prompt:    .asciiz "Enter a string: "

buffer:        .space 100      # Buffer to hold the input string

    .text

li $v0, 4              # syscall print string
la $a0, msg_prompt     # load address of prompt message
syscall

li $v0, 8              # syscall read string
la $a0, buffer         # load address of buffer
li $a1, 100           # maximum number of characters to read
syscall

li $v0, 4              # syscall print string
la $a0, buffer         # load address of buffer
syscall
