.data
lghtRed:	.word 0xFF6666
drkGray:	.word 0xA9A9A9
lghtGray:	.word 0xD3D3D3
whte:		.word 0xFFFFFF
black:		.word 0x000000
help: .asciiz "I am here."


.text

# Border Start
lw $t1, drkGray($0)
addi $t0, $gp, 132
jal top.bottom.border
jal sides
jal top.bottom.border
# Border end

# Snake-Start
#t5 - head
#t6 - tail
#t7 - last direction




lw $t1, whte($0)
addi $t0, $gp, 1984
sw $t1, 0($t0)

j initial

# New slate





j exit




top.bottom.border:
	addi $t2, $0, 0
	addi $t3, $0, 30
	t.b.loop:
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	addi $t2, $t2, 1
	bne $t2, $t3, t.b.loop
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

initial: # wsad controls for beginning movement
	li $s1, 0xffff0000
	lw $s2, 0($s1)
	bnez $s2, read_val
	li $v0, 0 # If $s2 has zero, there is no value to read, ret 0	
	j initial
	read_val:
		# Read value cause there is something there!
		lw $v0, 4($s1)
		li $s3, 97
		beq $v0, $s3, other
		j initial

other: #increasing head by one
	lw $t1, black($0)
	sw $t1, 0($t0)
	subi $t0, $t0, 4
	lw $t1, whte($0)
	sw $t1, 0($t0)
	j initial
	

	
	
	

exit:
	li $v0, 10
	syscall		# syscall to exit program
