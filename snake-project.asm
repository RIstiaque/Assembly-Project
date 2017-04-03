.data
lghtRed:	.word 0xFF6666
drkGry:		.word 0xA9A9A9
lghrGry:	.word 0xD3D3D3
help: .asciiz "I am here."


.text
lw $t1, lghtRed($0)
addi $t0, $gp, 132
addi $t2, $0, 0
addi $t3, $0, 30
jal top.bottom.border
jal sides
addi $t2, $0, 0
addi $t3, $0, 30
jal top.bottom.border
j exit




top.bottom.border:
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	addi $t2, $t2, 1
	bne $t2, $t3, top.bottom.border
	jr $ra

sides:
	addi $t4, $0, 0
	addi $t5, $0, 27
	addi $t0, $t0, 8
	jumpsides:
	addi $t4, $t4, 1
	sw $t1, 0($t0)
	addi $t0, $t0, 116
	sw $t1, 0($t0)
	addi $t0, $t0, 12
	bne $t4, $t5, jumpsides
	jr $ra


exit:
	li $v0, 10
	syscall		# syscall to exit program
