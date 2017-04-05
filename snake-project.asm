.data
lghtRed:	.word 0xFF6666
drkGray:	.word 0xA9A9A9
lghtGray:	.word 0xD3D3D3
white:		.word 0xFFFFFF
black:		.word 0x000000
yel:		.word 0xFFFF00
help: 		.asciiz "I am here."


.text

# Border Start
lw $t1, drkGray($0)
addi $t0, $gp, 0
jal top.bottom.border
jal sides
jal top.bottom.border
# Border end

# Snake-Start

# Store snake parts in memory, with tail first starting at the first location after the display ends.

# s4 = first memory position of the list.
addi $s4, $gp, 4096
# s5 = snakeLength.
li $s5, 1

# Create Head
lw $t1, white($0)
addi $t0, $gp, 1984
move $a0, $t0
li $v0, 1
syscall
sw $t1, 0($t0)

# Store head position
sb $t1, 0($s4)

j draw_body
driver:
	jal input
	jal valid_move
	jal nxt_Square
	j collision

top.bottom.border:
	addi $t2, $0, 0
	addi $t3, $0, 32
	t.b.loop:
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	addi $t2, $t2, 1
	bne $t2, $t3, t.b.loop
	jr $ra
	
sides:
	addi $t4, $0, 0
	addi $t5, $0, 30
	#addi $t0, $t0, 4
	jumpsides:
	addi $t4, $t4, 1
	sw $t1, 0($t0)
	addi $t0, $t0, 124
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	bne $t4, $t5, jumpsides
	jr $ra

	
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
	jal eat_yummy_juicy_fruit
	jal input
	jal valid_move
	jal nxt_Square
	jal eat_yummy_juicy_fruit
	jal input
	jal valid_move
	jal nxt_Square
	jal eat_yummy_juicy_fruit
	# End here for testing.
	j exit

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
	
valid_move:
	li $t4, 97
	beq $t4, $v0, a_valid
	li $t4, 119
	beq $t4, $v0, w_valid
	li $t4, 100
	beq $t4, $v0, d_valid
	li $t4, 115
	beq $t4, $v0, s_valid
	jr $ra
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
	lw $t1, lghtGray($0)
	sw $t1, 0($t0)
	# Update snake length
	addi $s5, $s5, 1
	move $t0, $t4
	add $s6, $s4, $s5
	# Store new head at top of the "list"
	sb $t0, 0($s6)
	#sub $s4, $s4, $s5
	lw $t1 white($0)
	sw $t1, 0($t0)
	jr $ra
	
collision:
	lw $t1, lghtGray($0)
	lw $t7, 0($t4)
	beq $t1, $t7, exit
	lw $t1, drkGray($0)
	beq $t1, $t7, exit
	lw $t1, lghtRed($0)
	bne $t1, $t7, reg_move # make this shit 
	jal eat_yummy_juicy_fruit
	#j gen_fruit

reg_move:
	lw $t1, white($0)
	sw $t1, 0($t4)
	lw $t1, lghtGray($0)
	sw $t1, 0($t0)
	lw $t1, black($0)
	sw $t1, 0($s4)
	reg_loop:
	

exit:
	li $v0, 10
	syscall		# syscall to exit program
