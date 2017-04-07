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
# Constant 4
li $s6, 4
# s5 = snakeLength.
li $s5, 0

# Create Head
lw $t1, white($0)
addi $t0, $gp, 1984
sw $t1, 0($t0)

# Store head position
move $t1, $t0
sw $t1, 0($s4)

j draw_body

# Main part of the program.
driver:
	jal input
	jal valid_move
	jal nxt_Square
	#j collision
	j reg_move

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
	li $t1, 119
	beq $v0, $t1, body2
	li $t1, 97
	beq $v0, $t1, body2
	li $t1, 100
	beq $v0, $t1, body2
	li $t1, 115
	bne $v0, $t1, wait
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
	# Begin testing
	# End here for testing.
	j driver

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
		beq $t4, $s3, a_here # a is not an acceptable input to d
		move $s3, $v0 # w or s is the input - acceptable.
		a_here:
		jr $ra
	w_valid:
		li $t4, 115
		beq $t4, $s3, w_here # w is not an acceptable input to s
		move $s3, $v0 # a or d is the input - acceptable.
		w_here:
		jr $ra
	d_valid:
		li $t4, 97
		beq $t4, $s3, d_here # d is not an acceptable input to a
		move $s3, $v0 # w or s is the input - acceptable.
		d_here:
		jr $ra
	s_valid:
		li $t4, 119
		beq $t4, $s3, s_here # s is not an acceptable input to w
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
	mul $t5, $s5, $s6
	move $t0, $t4
	add $t5, $s4, $t5
	# Store new head at top of the list.
	sw $t0, 0($t5)
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

gen_fruit: #Generates new fruit
	random:  #loops until a suitable place for fruit gen is found
		li $a1, 991 # gen a random number with uppper bound (3964/4)
		li $v0, 42
		syscall
		
		li $t5, 4
		mul $a0, $a0, $t5  #multiply that number by four so it is a valid square address
		add $a0, $gp, $a0 #check color of that random square
		lw $t7, 0($a0)
	
		lw $t1, black
	
		bne $t7, $t1, random  #compare that color to black, try again if not
	
	lw $t1, lghtRed #turn the black square red
	sw $t1, 0($a0)
	
	j driver

reg_move:
	# Turns $t4 white, $t4 is next square.
	lw $t1, white
	sw $t1, 0($t4)
	# Turns the previous head position gray
	lw $t1, lghtGray
	sw $t1, 0($t0)
	# Turns the end of the tail black.
	lw $t1, black
	lw $t7, 0($s4)
	sw $t1, 0($t7)
	li $t7, 0
	reg_loop:
		mul $t5, $t7, $s6
		add $t5, $t5, $s4 # Current part of the tail
		lw $t6, 4($t5) # Next location
		sw $t6, 0($t5) # Stored in Current part
		addi $t7, $t7, 1
		bne $t7, $s5, reg_loop
	j driver
		
		
		
		

exit:
	li $v0, 10
	syscall		# syscall to exit program
