#####################################################################
#
# CSC258 Summer 2021 Assembly Final Project
# University of Toronto
#
# Student: Tao Lin, Student Number, 1006444304
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8 (update this as needed)
# - Unit height in pixels: 8 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3 (choose the one that applies)
# - MILESTONE 1 
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes / no / yes, and please share this project github link as well!
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################



# Bitmap Display Configuration:
# - Unit width in pixels: 8 
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
.eqv BASE_ADDRESS 0x10008000
.eqv WIDTH 32
.eqv RED 0xe63946
.eqv BLUE 0x457B9D
.eqv GREY 0x697278
.eqv BLACK 0x000000
.eqv THIRTYSIX 36
.eqv SIXTY 60
.eqv SLEEP 40
.eqv WHITE 0xFFFFFF

.data 
	# obstacle arrays will store position of obstacles, first element is x position. Rest is  position in base_add

	escToggle: .word 0
	strObstacle1: .asciiz "obstacleArray1"
	strObstacle2: .asciiz "obstacleArray2"
	strObstacle3: .asciiz "obstacleArray3"
	strObstacle4: .asciiz "obstacleArray4"
	strObstacles: .asciiz "obstacleArray1", "obstacleArray2", "obstacleArray3", "obstacleArray4"
	obstacleArray1: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 31, 0 
	obstacleArray2: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 31, 0 
	obstacleArray3: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 31, 0 
	obstacleArray4: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 31, 0 
	obstacleArrayX: .word 0, 0, 0, -1, -1, -1, -2, -2, -2
	obstacleArrayY: .word 0, -1, -2, 0, -1, -2, 0, -1, -2
	shipArray: .word 1792, 1920, 2048, 2176, 2304, 1924, 2052, 2180, 2056
	shipArrayImut: .word 1792, 1920, 2048, 2176, 2304, 1924, 2052, 2180, 2056
.text

.globl main

main:
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
		
	# generate initial location of ship
	la $a1, shipArrayImut
	jal generate_ship

	la $s6, obstacleArrayX # mem address of obstacleArrayX
	la $s7, obstacleArrayY # mem addresss of obstacleArrayY
	
main_loop:	
	
	la $s0, strObstacles
	la $s1, strObstacle1
	
	li $t9, 0xffff0000 
	lw $t8, 0($t9)
	beq $t8, 1, keypress_happened
	# check if esc toggle is on
	lw $t1, escToggle
	bnez $t1, main_loop
	j obst
	
keypress_happened:
	lw $t2, 4($t9) # this assumes $t9 is set to 0xfff0000 from before
	beq $t2, 0x70, respond_to_p
	beq $t2, 0x1b, respond_to_esc
	
	# wasd keys
	beq $t2, 0x77, respond_to_w
	beq $t2, 0x61, respond_to_a
	beq $t2, 0x73, respond_to_s
	beq $t2, 0x64, respond_to_d
	
generate_ship:
	
	# push ra to stack
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	# draw the red part
	li $a3, RED 
	add $a2, $a1, $0
	
	jal draw
	
	# draw blue tip now 
	lw $t2, 32($a1)
	add $t2, $t2, $t0
	li $t1, BLUE 
	sw $t1, 0($t2)	
	# pop ra from stack and then return
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra	
	
respond_to_w:
	# update position
	addi $a0, $0, 0 # x
	addi $a1, $0, -128 # y
	
	# erase ship
	li $a3, BLACK
	la $a2, shipArray
	jal draw
	
	jal move_ship
	
	# redraw ship now
	li $a3, RED
	la $a2, shipArray
	
	jal draw
	
	# redraw blue tip 
	lw $t2, 32($a2)
	add $t2, $t2, $t0
	li $t1, BLUE 
	sw $t1, 0($t2)	
	
	j obst
	
respond_to_a:
	# update position
	addi $a0, $0, -4 # x
	addi $a1, $0, 0 # y
	
	# erase ship
	li $a3, BLACK
	la $a2, shipArray
	jal draw
	
	jal move_ship
	
	# redraw ship now
	li $a3, RED
	la $a2, shipArray
	
	jal draw
	
	# redraw blue tip 
	lw $t2, 32($a2)
	add $t2, $t2, $t0
	li $t1, BLUE 
	sw $t1, 0($t2)	
	
	j obst
	
respond_to_s:
	# update position
	addi $a0, $0, 0 # x
	addi $a1, $0, 128 # y

	# erase ship
	li $a3, BLACK
	la $a2, shipArray
	jal draw
	
	jal move_ship
	
	# redraw ship now
	li $a3, RED
	la $a2, shipArray
	
	jal draw
	
	# redraw blue tip 
	lw $t2, 32($a2)
	add $t2, $t2, $t0
	li $t1, BLUE 
	sw $t1, 0($t2)	
	
	j obst
	
respond_to_d:
	# update position
	addi $a0, $0, 4 # x
	addi $a1, $0, 0 # y
	
	# erase ship
	li $a3, BLACK
	la $a2, shipArray
	jal draw
	
	jal move_ship
	
	# redraw ship now
	li $a3, RED
	la $a2, shipArray
	
	jal draw
	
	# redraw blue tip 
	lw $t2, 32($a2)
	add $t2, $t2, $t0
	li $t1, BLUE 
	sw $t1, 0($t2)	
	
	j obst
	
respond_to_esc:
	li $t1, WHITE # t1 stores red 
	
	sw $t1, 1692($t0)
	sw $t1, 1696($t0)
	sw $t1, 1700($t0)
	sw $t1, 1816($t0)
	sw $t1, 1828($t0)
	sw $t1, 1956($t0)
	sw $t1, 1944($t0)
	sw $t1, 2084($t0)
	sw $t1, 2076($t0)
	sw $t1, 2080($t0)
	sw $t1, 2212($t0)
	sw $t1, 2332($t0)
	sw $t1, 2336($t0)
	
	sw $t1, 1712($t0)
	sw $t1, 1716($t0)
	sw $t1, 1720($t0)
	sw $t1, 1836($t0)
	sw $t1, 1848($t0)
	sw $t1, 1976($t0)
	sw $t1, 1964($t0)
	sw $t1, 2104($t0)
	sw $t1, 2096($t0)
	sw $t1, 2100($t0)
	sw $t1, 2232($t0)
	sw $t1, 2352($t0)
	sw $t1, 2356($t0)
	
	sw $t1, 1736($t0)
	sw $t1, 1748($t0)
	sw $t1, 2248($t0)
	sw $t1, 2124($t0)
	sw $t1, 2128($t0)
	sw $t1, 2260($t0)
	
	addi $t1, $0, 1
	sw $t1, escToggle
	
	j main_loop
erase_gg:
	# push ra to stack
	addi $sp, $sp, -4 
	sw $ra, 0($sp)
	li $t1, BLACK # t1 stores red 
	
	sw $t1, 1692($t0)
	sw $t1, 1696($t0)
	sw $t1, 1700($t0)
	sw $t1, 1816($t0)
	sw $t1, 1828($t0)
	sw $t1, 1956($t0)
	sw $t1, 1944($t0)
	sw $t1, 2084($t0)
	sw $t1, 2076($t0)
	sw $t1, 2080($t0)
	sw $t1, 2212($t0)
	sw $t1, 2332($t0)
	sw $t1, 2336($t0)
	
	sw $t1, 1712($t0)
	sw $t1, 1716($t0)
	sw $t1, 1720($t0)
	sw $t1, 1836($t0)
	sw $t1, 1848($t0)
	sw $t1, 1976($t0)
	sw $t1, 1964($t0)
	sw $t1, 2104($t0)
	sw $t1, 2096($t0)
	sw $t1, 2100($t0)
	sw $t1, 2232($t0)
	sw $t1, 2352($t0)
	sw $t1, 2356($t0)
	
	sw $t1, 1736($t0)
	sw $t1, 1748($t0)
	sw $t1, 2248($t0)
	sw $t1, 2124($t0)
	sw $t1, 2128($t0)
	sw $t1, 2260($t0)
	
	sw $0, escToggle
	
	# pop from stack and return
	lw $ra, 0($sp)
	addi, $sp, $sp, 4
	jr $ra
respond_to_p:
	# change all obstacle arrays	
	la $a1, shipArrayImut
	jal generate_ship
	
	la $a0, obstacleArray1
	jal reset_obstacle
	
	la $a0, obstacleArray2
	jal reset_obstacle
	
	la $a0, obstacleArray3
	jal reset_obstacle
	
	la $a0, obstacleArray4
	jal reset_obstacle
	
	# change escToggle to 0 if need to
	lw $t1, escToggle
	beqz  $t1, noChangeEsc
	sw $0, escToggle
	jal erase_gg
noChangeEsc:
	j main_loop
reset_obstacle:
	addi $s4, $0, 0 # initialize iteratable i 
	addi $sp, $sp, -4 
	sw $ra, 0($sp)
	
	li $a3, BLACK
	add $a2, $a0, $0
	jal draw
reset_obstacle_loop:
	# reset x unit 
	addi $t7, $0, 31
	sw $t7, 36($a0)
	
	bge $s4, THIRTYSIX, reset_obstacle_end	
	
	add $t7, $s4, $a0
	sw $0, 0($t7)
	
	addi $s4, $s4, 4
	j reset_obstacle_loop
	
reset_obstacle_end:
	# pop from stack
	lw $ra, 0($sp)
	addi, $sp, $sp, 4
	jr $ra
	
obst:
	addi $s4, $0, 0 # s4 for main function, t2 for helper function
obst_loop:
	bge $s4, SIXTY, obst_loop_end
	add $t7, $s4, $s0 # specify element in array
	# check if element is obstacle 1
	add $a0, $0, $t7
	add $a1, $0, $s1
	
	jal strcmp
	bnez  $v0, obstacle1
	# check if element is obstacle 2
	la $s1, strObstacle2
	add $a0, $0, $t7
	add $a1, $0, $s1
	
	jal strcmp
	bnez  $v0, obstacle2
	# check if element is obstacle 3
	la $s1, strObstacle3
	add $a0, $0, $t7
	add $a1, $0, $s1
	
	jal strcmp
	bnez  $v0, obstacle3
	# check if element is obstacle 4 
	la $s1, strObstacle4
	add $a0, $0, $t7
	add $a1, $0, $s1
	
	jal strcmp
	bnez  $v0, obstacle4
obst_next:
	# go to next iteration
	addi $s4, $s4, 15
	j obst_loop
	
obstacle1:
	la $s5, obstacleArray1 # mem addr of obstacleArray1
	add $a2, $s5, $0 # send mem addresses as parameters for generate_obst
	lw $t4, 36($s5) # t4 is x position
	# check if we generate obstacles or move them
	addi $t3, $0, 31
	beq $t4, $t3, if
	addi $t3, $0, 1
	ble $t4, $t3, if_regen
	j main_else
	
obstacle2:
	la $s5, obstacleArray2 # mem addr of obstacleArray1
	add $a2, $s5, $0 # send mem addresses as parameters for generate_obst
	lw $t4, 36($s5) # t4 is x position
	# check if we generate obstacles or move them
	addi $t3, $0, 31
	beq $t4, $t3, if
	addi $t3, $0, 1
	ble $t4, $t3, if_regen
	j main_else
	
obstacle3:
	la $s5, obstacleArray3 # mem addr of obstacleArray1
	add $a2, $s5, $0 # send mem addresses as parameters for generate_obst
	lw $t4, 36($s5) # t4 is x position
	# check if we generate obstacles or move them
	addi $t3, $0, 31
	beq $t4, $t3, if
	addi $t3, $0, 1
	ble $t4, $t3, if_regen
	j main_else
	
obstacle4:
	la $s5, obstacleArray4 # mem addr of obstacleArray1
	add $a2, $s5, $0 # send mem addresses as parameters for generate_obst
	lw $t4, 36($s5) # t4 is x position
	# check if we generate obstacles or move them
	addi $t3, $0, 31
	beq $t4, $t3, if
	addi $t3, $0, 1
	ble $t4, $t3, if_regen
	j main_else

if_regen:
	jal regenerate_obst
	j obst_next
	
if:
	jal generate_obst
	# e draw-out the initial generated obstacles
	add $a2, $s5, $0 
	li $a3, GREY
	jal draw
	
	li $v0, 32
	li $a0, SLEEP # Wait one second (1000 milliseconds)
	syscall
	
	j obst_next
	
main_else:
	# move obstacles
	li $a3, BLACK
	jal draw
	jal update_obst
main_else_return:
	li $a3, GREY
	jal draw
	j obst_next
	
generate_obst:	
	# push ra to stack
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	# generate obst x,y positions then draw them (same parameters)
	li $v0, 42
	li $a0, 0
	li $a1, 31
	syscall
	
	addi $t2, $0, 0 # initialize i value
	add $t3, $0, $a0 # the random y value
	sw $t3, 40($a2)
	
generate_obst_loop: 
	# loop through t8 and t9 to set positions 
	bge  $t2, THIRTYSIX, generate_obst_end
	# get x and y index from arrayX, arrayY
	add $t4, $s6, $t2 
	add $t5, $s7, $t2 
	# load x and y values in units
	lw $t4, 0($t4) # X
	lw $t5, 0($t5) # Y
	
	addi $a0, $t4, 31 # x
	add $a1, $t5, $t3 # y
	
	jal address_xy
	
	add $t6, $v0, $0
	# store in obstacleArray
	add $t7, $a2, $t2
	sw $t6, 0($t7)
	
	addi $t2, $t2, 4
	j generate_obst_loop
	
generate_obst_end:
	lw $t2, 36($a2)
	subi $t2, $t2, 1
	sw $t2, 36($a2)
	
	# pop from stack
	lw $ra, 0($sp)
	addi, $sp, $sp, 4
	jr $ra
	
regenerate_obst:
	addi $t3, $0, 31
	sw $t3, 36($a2)
	li $a3, BLACK
	
draw:
	addi $sp, $sp, -4 
	sw $ra, 0($sp)
	addi, $t2, $0, 0 # load i variable
	
draw_loop:
	bge $t2, THIRTYSIX, draw_end
	add $t1, $a3, $0
	
	add $t4, $a2, $t2 # t4: the index in the array
	lw $t5, 0($t4) # get element from array
	add $t6, $t0, $t5 # sum position number with base addr
	sw $t1, 0($t6) # store color at that addr
	
	addi $t2, $t2, 4
	j draw_loop
	
draw_end:
	# jump back to main function
	lw $ra, 0($sp)
	addi, $sp, $sp, 4
	jr $ra
	
update_obst:	
	addi $t2, $0, 0 # initialize i
	
update_obst_loop:
	# stack $ra for main_loop
	bge $t2, THIRTYSIX, update_obst_end
	
	# fetch x,y unit into t3 and t4
	lw $t3, 36($a2) # X unit
	lw $t4, 40($a2) # Y unit
	# get x and y coefficient from arrayX, arrayY
	add $t5, $s6, $t2 
	add $t6, $s7, $t2 
	lw $t5, 0($t5)
	lw $t6, 0($t6)
		
	add $a0, $t5, $t3 # x
	add $a1, $t6, $t4 # y

	jal address_xy
	
	add $t5, $v0, $0 # store updated value to t5
	
	add $t6, $t2, $a2 
	sw $t5, 0($t6)
	
	addi $t2, $t2, 4
	j update_obst_loop
	
update_obst_end:
	lw $t2, 36($a2)
	subi $t2, $t2, 1
	sw $t2, 36($a2)
	
	# pop $ra from stack
	j main_else_return

move_ship:
	# a0 - x change 
	# a1 - y change
	addi $sp, $sp, -4 
	sw $ra, 0($sp)
	la $t1, shipArray
	addi $t2, $0, 0 # initialize i for loop
move_ship_loop:
	bge $t2, THIRTYSIX, move_ship_end
	
	add $t3, $t2, $t1 # t3 is the current position
	
	lw $t4, 0($t3)	
	# update mem location with new position	
	add $t4, $t4, $a0 
	add $t4, $t4, $a1 
	
	sw $t4, 0($t3) # store the new position in shipArray	
	
	addi $t2, $t2, 4
	j move_ship_loop
move_ship_end:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
address_xy:
	# stack $ra for returning from address_xy
	addi $sp, $sp, -4 
	sw $ra, 0($sp)
	
	addi $t6, $0, WIDTH
	mult $t6, $a1 # address(x,y) 
	mflo $t6
	add $t6, $a0, $t6
	addi $t7, $0, 4 # reinitialize t7 to 4
	mult $t7, $t6
	mflo $v0
	# pop $ra from stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
strcmp:
	# load words from parameter
	addi $t2, $0, 0 
	
str_cmploop: 
	add $t3, $t2, $a0
	add $t4, $t2, $a1
	lb $t5, 0($t3)
	lb $t6, 0($t4)

	beqz $t5, str_check
	beqz $t6, str_check
	
	bne $t5, $t6, str_neql
	
	addi $t2, $t2, 1
	j str_cmploop	

str_check:
	bne  $t5, $t6, str_neql
	j str_eql
	
str_neql: 
	addi $v0, $0, 0
	jr $ra
	
str_eql: 
	addi $v0, $0, 1
	jr $ra
  	
obst_loop_end:
	li $v0, 32
	li $a0, SLEEP # Wait one second (1000 milliseconds)
	syscall
	
	j main_loop
	
end:
	li $v0, 1 # terminate the program gracefully
	addi $t0, $0, 69
	move $a0, $t0
	syscall
	li $v0, 10 # terminate the program gracefully
	syscall
