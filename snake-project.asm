.data
lghtRed:	.word 0xFF6666
drkGray:	.word 0xA9A9A9
lghtGray:	.word 0xD3D3D3
white:		.word 0xFFFFFF
black:		.word 0x000000

.text 
	li $a0, 40
	li $a1, 1000
	li $a2, 12
	li $a3, 8
	li $v0, 31
	syscall
	
	
	
main:
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
		jal move_sound
		j collision

	# End main

top.bottom.border: # Draws the top and bottom borders.
	addi $t2, $0, 0
	addi $t3, $0, 32
	t.b.loop:
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	addi $t2, $t2, 1
	bne $t2, $t3, t.b.loop
	jr $ra
	
sides: # Draws the left and right borders.
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

	
draw_body: # Draws the 3 body parts of the snake. Note: Snake is unable to kill itself within this drawing process.
	# $s3 is previous key.
	li $s3, 0
	wait: # Waits for a valid input.
	jal input
	li $t1, 119
	beq $v0, $t1, body2
	li $t1, 97
	beq $v0, $t1, body2
	li $t1, 100
	beq $v0, $t1, body2
	li $t1, 115
	bne $v0, $t1, wait
	body2: # Starts body part 1.
	jal valid_move
	jal nxt_Square
	jal eat_yummy_juicy_fruit
	jal input # Starts body part 2.
	jal valid_move
	jal nxt_Square
	jal eat_yummy_juicy_fruit
	jal input # Starts body part 3.
	jal valid_move
	jal nxt_Square
	jal eat_yummy_juicy_fruit
	j gen_fruit

input: # Returns one input

	li $a0, 700	#waits so you can run at full speed
	li $v0, 32
	syscall

	li $s1, 0xffff0000
	lw $s2, 0($s1)
	bnez $s2, read_val
	li $v0, 0 # If $s2 has zero, there is no value to read, ret 0	
	jr $ra
	read_val:
		# Read value cause there is something there!
		lw $v0, 4($s1)
		jr $ra
	
valid_move: # Checks if the key pressed is valid or not. i.e. Can't have the snake move left from a if it is already moving to the right (d).
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
		
nxt_Square: # Calculates and makes $t4 the next square.
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


eat_yummy_juicy_fruit: # This function will increase the snake's overall length.
	lw $t1, lghtGray($0) 
	sw $t1, 0($t0) # Makes the current head gray.
	# Update snake length
	addi $s5, $s5, 1
	mul $t5, $s5, $s6
	move $t0, $t4 # Makes the current head equal to the next head.
	add $t5, $s4, $t5
	# Store new head at top of the list.
	sw $t0, 0($t5)
	lw $t1 white($0)
	sw $t1, 0($t0) # Fills in the current head to white.
	jr $ra
	
	
collision:
	lw $t1, lghtGray($0)
	lw $t7, 0($t4)
	beq $t1, $t7, exit # If the spot is light Gray, game will be over.
	lw $t1, drkGray($0)
	beq $t1, $t7, exit # If the spot is dark Gray, game will be over.
	lw $t1, lghtRed($0)
	bne $t1, $t7, reg_move # Checks for fruit.
	jal eat_sound
	jal eat_yummy_juicy_fruit
	j gen_fruit


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
	j driver # Loop to driver to continue game.


reg_move: # In the case that there is no collision with the next square.
	# Turns the end of the tail black.
	lw $t1, black
	lw $t7, 0($s4)
	move $a0, $t7
	sw $t1, 0($t7)
	# Turn old head gray.
	lw $t1, lghtGray
	sw $t1, 0($t0)
	# Turn new head white.
	lw $t1, white
	sw $t1, 0($t4)
	li $t7, 0
	# Because 0 - s5 is the snake, we go one length further to iterate through it all.
	addi $t8, $s5, 1
	reg_loop:
		mul $t5, $t7, $s6
		add $t5, $t5, $s4 # Current part of the tail
		lw $t6, 4($t5) # Next location of tail
		sw $t6, 0($t5) # Stored in Current part
		addi $t7, $t7, 1
		bne $t7, $t8, reg_loop
	# Stores new head.
	mul $t7, $s5, $s6
	add $t7, $t7, $s4
	sw $t4, 0($t7) # Stores head in memory
	
	# Move the new head to $t0.
	move $t0, $t4
	j driver

move_sound:
	li $a0, 40
	li $a1, 1000
	li $a2, 8
	li $a3, 127
	li $v0, 31
	syscall
	jr $ra
	
game_over_sound:
	li $a0, 50
	li $a1, 1000
	li $a2, 23	
	li $a3, 127
	li $v0, 31
	syscall
	li $a0, 700
	li $v0, 32
	syscall
	li $a0, 40
	li $a1, 1000
	li $a2, 23	
	li $a3, 127
	li $v0, 31
	syscall
	li $a0, 700
	li $v0, 32
	syscall
	li $a0, 35
	li $a1, 3000
	li $a2, 23	
	li $a3, 127
	li $v0, 31
	syscall
	jr $ra

eat_sound:
	li $a0, 80
	li $a1, 1000
	li $a2, 115
	li $a3, 127
	li $v0, 31
	syscall
	jr $ra

exit:
	jal game_over_sound
	li $v0, 10
	syscall		# syscall to exit program
