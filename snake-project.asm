.data
lghtRed:	.word 0xFF6666
drkGray:	.word 0xA9A9A9
lghtGray:	.word 0xD3D3D3
white:		.word 0xFFFFFF
black:		.word 0x000000
help: 		.asciiz "I am here."


.text

# Border Start
lw $t1, drkGray($0)
addi $t0, $gp, 132
jal top.bottom.border
jal sides
jal top.bottom.border
# Border end

# Snake-Start

# Store snake parts in memory, with tail first starting at the first location after the display ends.

# s4 = first memory position of the tail.
addi $s4, $gp, 4096
# s5 = snakeLength | Equals 4 because there will be at least 4 parts in default.
li $s5, 4

# Create Head
lw $t1, white($0)
addi $t0, $gp, 1984
sw $t1, 0($t0)

# Store head position
sb $t1, 4($s4)

j draw_body


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

input: # Returns one input
	li $s1, 0xffff0000
	lw $s2, 0($s1)
	bnez $s2, read_val
	li $v0, 0 # If $s2 has zero, there is no value to read, ret 0	
	jr $ra
	read_val:
		# Read value cause there is something there!
		lw $v0, 4($s1)
		jr $ra

#other: #increasing head by one
#	lw $t1, black($0)
#	sw $t1, 0($t0)
#	subi $t0, $t0, 4
#	lw $t1, whte($0)
#	sw $t1, 0($t0)
#	j initial
	

draw_body:
	# $s3 is previous key.
	li $s3, 0
	wait:
	jal input
	li $s6, 119
	beq $v0, $s6, body2
	li $s6, 97
	beq $v0, $s6, body2
	li $s6, 100
	beq $v0, $s6, body2
	li $s6, 115
	bne $v0, $s6, wait
	body2:
	jal valid_move
	jal nxt_Square
	lw $t1, lghtRed($0)
	sw $t1, 0($t0)
	# Stores the first body part in the third position
	sb $t0, 3($s4)
	# $t4 is the new location from nxt_Square
	move $t0, $t4
	lw $t1, white($0)
	sw $t1, 0($t0)
	# Enter new head location in memList
	sb $t0, 4($s4)
	j exit
	jal input
	jal valid_move
	#third body part
	
	
	
	
valid_move:
	li $t4, 97
	beq $t4, $v0, a_valid
	li $t4, 119
	beq $t4, $v0, w_valid
	li $t4, 100
	beq $t4, $v0, d_valid
	li $t4, 115
	beq $t4, $v0, s_valid
	a_valid: # Also is the go to if no input is regsitered (aka input/$v0 = 0).
		li $t4, 100
		beq $t4, $v0, a_here # a is not an acceptable input to d
		move $s3, $v0 # w or s is the input - acceptable.
		a_here:
		jr $ra
	w_valid:
		li $t4, 115
		beq $t4, $v0, w_here # w is not an acceptable input to s
		move $s3, $v0 # a or d is the input - acceptable.
		w_here:
		jr $ra
	d_valid:
		li $t4, 97
		beq $t4, $v0, d_here # d is not an acceptable input to a
		move $s3, $v0 # w or s is the input - acceptable.
		d_here:
		jr $ra
	s_valid:
		li $t4, 119
		beq $t4, $v0, s_here # s is not an acceptable input to w
		move $s3, $v0 # a or d is the input - acceptable.
		s_here:
		jr $ra
		
nxt_Square:
	# Subs if a
	li $t4, 97
	bne $t4, $s3, add_w
	subi $t4, $t0, 4
	jr $ra
	# Subs if w
	add_w:
	li $t4, 119
	bne $t4, $s3, add_s
	subi $t4, $t0, 128
	jr $ra
	# Adds if s
	add_s:
	li $t4, 115
	bne $t4, $s3, add_d
	addi $t4, $t0, 128
	jr $ra
	# Adds if d
	add_d:
	addi $t4, $t0, 4
	jr $ra


eat_yummy_juicy_fruit:
	

	
	
	
	
	
	

	
	
	

exit:
	li $v0, 10
	syscall		# syscall to exit program
