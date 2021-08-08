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
.eqv PURPLE 0x7F00FF
.eqv YELLOW 0xFFFF00
.eqv LIGHTBLUE 0x009ACD
.eqv THIRTYSIX 36
.eqv THIRTYTWO 32
.eqv TWELVE 12
.eqv SIXTY 60
.eqv SLEEP 40
.eqv WHITE 0xFFFFFF
.eqv HPMAX 128
.eqv LEVEL1 1
.eqv LEVEL2 2
.eqv LEVEL3 3


.data 
	bulletToggle: .word 0
	bulletArray: .word 0, 0, 0
	# obstacle arrays will store position of obstacles, first element is x position. Rest is  position in base_add
	obstacleColor: .word GREY
	level: .word 1 # initial level
	obstacleCount: .word 32 # once this hits 0, enter next level
	invinsibility: .word 0 # 0 means off
	hpLoss: .word 0
	invinsibilityCounter: .word 50 # 25 * 40ms = 1s
	ggToggle: .word 0
	strObstacle1: .asciiz "obstacleArray1"
	strObstacle2: .asciiz "obstacleArray2"
	strObstacle3: .asciiz "obstacleArray3"
	strObstacle4: .asciiz "obstacleArray4"
	strObstacles: .asciiz "obstacleArray1", "obstacleArray2", "obstacleArray3", "obstacleArray4"
	obstacleArray1: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 31, 0 
	obstacleArray2: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 31, 0 
	obstacleArray3: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 31, 0 
	obstacleArray4: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 31, 0 
	
	# different generators for different obstacles
	obstacleArrayX: .word 0, 0, 0, -1, -1, -1, -2, -2, -2
	obstacleArrayY: .word 0, -1, -2, 0, -1, -2, 0, -1, -2
	obstacleArrayXa: .word -4, -3, -2, -1, 0, -2, -2, -2 ,-2
	obstacleArrayYa: .word 0, 0, 0, 0, 0, -1, -2, 1, 2
	obstacleArrayXb: .word 0, -1, -2, -3, -4, -5, -6, -7 ,-8
	obstacleArrayYb: .word 0, 0, 0, 0, 0, 0, 0, 0, 0
	
	x_regen: .word 1

	shipArray: .word 1792, 1920, 2048, 2176, 2304, 1924, 2052, 2180, 2056
	shipArrayImut: .word 1792, 1920, 2048, 2176, 2304, 1924, 2052, 2180, 2056
	speed1: .word 1
	speed2: .word 2
	 # topBorder
	 # rightBorder
	 # bottomBorder
	 # leftBorder
.text

.globl main

main:
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
		
	# generate initial location of ship
	la $a1, shipArrayImut
	jal generate_ship
	
	lw $a0, hpLoss # 0 at first, incremenet by 8
	jal set_hp

	
main_loop:	
	
	la $s0, strObstacles
	la $s1, strObstacle1
	
	# check if we go to next level
	lw $t1, obstacleCount
	bgtz $t1, sameLevel
	jal incrementLevel


sameLevel:
	li $t9, 0xffff0000 
	lw $t8, 0($t9)
	beq $t8, 1, keypress_happened
	# check if gg toggle is on
check_gg:
	lw $t1, ggToggle
	bnez $t1, main_loop
	j obst

incrementLevel:
	# increment level difficulty 
	lw $t1, level
	addi $t1, $t1, 1
	sw $t1, level
	
	li $t3, LIGHTBLUE
	beq $t1, LEVEL2, level_increase # remember to change bge to beq if i'm gonna add more levels
	li $t3, PURPLE
	beq $t1, LEVEL3, level_increase # 
	#li $t3, RED
	#bgt $t1, LEVEL3, level_increase # perma increase
	j incrementLevelEnd
level_increase:
	# udpate speed 1
	lw $t2, speed1
	addi $t2, $t2, 1
	sw $t2, speed1
	
	# update speed 2
	lw $t2, speed2
	addi $t2, $t2, 1
	sw  $t2, speed2
	
	# update obstacle color
	sw $t3, obstacleColor
	
incrementLevelEnd:
	addi $t3, $0, 16
	sw $t3, obstacleCount
	jr $ra
keypress_happened:
	lw $t2, 4($t9) # this assumes $t9 is set to 0xfff0000 from before
	beq $t2, 0x70, respond_to_p
	
	# wasd keys
	lw $t1, ggToggle
	bnez $t1, main_loop
	beq $t2, 0x77, respond_to_w
	beq $t2, 0x61, respond_to_a
	beq $t2, 0x73, respond_to_s
	beq $t2, 0x64, respond_to_d
	
	lw $t1, bulletToggle
	bnez $t1, obst
	beq $t2, 0x6f, respond_to_o
	j obst
	
generate_ship:
	# push ra to stack
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	# draw the body part
	# check if invinsibility is on
	lw $t2, invinsibility 
	bnez $t2, invins_on_body
	li $a3, RED
	j invins_on_body_end
invins_on_body: 
	li $a3, BLUE	
invins_on_body_end:
	add $a2, $a1, $0
	move $t9, $a1

	addi $a0, $0, 36
	jal draw
	
	lw $t2, invinsibility 
	bnez $t2, invins_on_tip
	# draw  tip now 
	lw $t2, 32($t9)
	add $t2, $t2, $t0
	li $t1, BLUE 
	sw $t1, 0($t2)	
	j invins_on_tip_end
invins_on_tip:
	# draw  tip now 
	lw $t2, 32($t9)
	add $t2, $t2, $t0
	li $t1, RED
	sw $t1, 0($t2)	
invins_on_tip_end:
	# pop ra from stack and then return
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra	

respond_to_o:
	# get position to the right of blue tip
	la $t1, shipArray
	lw $t1, 32($t1)
	addi $t1, $t1, 4 
	
	la $t3, bulletArray
	addi $t2, $0, 0 # initialize i value
respond_to_o_loop:
	bge $t2, TWELVE, respond_to_o_end
	# get index for array
	add $t4, $t3, $t2
	add $t5, $t1, $t2 # get position want to add
	
	sw $t5, 0($t4)

	addi $t2, $t2 4
	j respond_to_o_loop
respond_to_o_end:
	la $a2, bulletArray
	li $a3, YELLOW
	addi $a0, $0, TWELVE
	jal draw
	# turn on bulletToggle
	addi $t1, $0, 1
	sw $t1, bulletToggle
	
	j check_gg

respond_to_w:
 	# check if at border
	la $t1, shipArray
	lw $t1, 0($t1) # t1 now stores position of top left corner of ship
	
	# get x,y value
	move $a0, $t1
	jal get_xy # x,y stored in v0,v1

	# address_xy = 4x
	move $t2, $v0 
	addi $t3, $0, 4
	
	mult $t2, $t3	

	mflo $t2 # 4x
	
	beq $t2, $t1, obst # if t2 == t1 means we're at top border, jump to obst

	
	# erase ship
	li $a3, BLACK
	la $a2, shipArray

	addi $a0, $0, 36
	jal draw
	
	# update position
	addi $a0, $0, 0 # x
	addi $a1, $0, -128 # y
	
	jal move_ship
	
	la $a1, shipArray
	jal generate_ship
	
	j check_gg
	
respond_to_a:
        # check if at border
	la $t1, shipArray
	lw $t1, 0($t1) # t1 now stores position of top left corner of ship
	
	# get x,y value
	move $a0, $t1
	jal get_xy # x,y stored in v0,v1

	# address_xy = (y * width) * 4
	move $t2, $v1 
	addi $t3, $0, 4
	addi $t4, $0, WIDTH
	
	mult $t2, $t4	
	mflo $t2 # y * width	
	mult $t2, $t3 	
	mflo $t2 # (y * width) * 4
	
	beq $t2, $t1, obst # if t2 == t1 means we're at left border, jump to obst

	# erase ship
	li $a3, BLACK
	la $a2, shipArray

	addi $a0, $0, 36
	jal draw
	
	# update position
	addi $a0, $0, -4 # x
	addi $a1, $0, 0 # y

	jal move_ship
	
	# redraw ship now
	
	la $a1, shipArray
	jal generate_ship
	
	j check_gg
	
respond_to_s:
	# check if at border
	la $t1, shipArray
	lw $t1, 16($t1) # t1 now stores position of bottom left corner of ship
	
	# get x,y value
	move $a0, $t1
	jal get_xy # x,y stored in v0,v1
	
	# address_xy = (31*width + x)*4
	move $t2, $v0 
	addi $t3, $0, 4
	addi $t4, $0, WIDTH
	addi $t5, $0, 30
	
	
	mult $t5, $t4 
	mflo $t6 # 31 * width	
	add $t6, $t6, $t2 # 31 * width	+ x
	mult $t6, $t3 	
	mflo $t2 # (31 * width + x) * 4
	
	beq $t2, $t1, obst # if t2 == t1 means we're at bottom border, jump to obst

	# erase ship
	li $a3, BLACK
	la $a2, shipArray

	addi $a0, $0, 36
	jal draw
	
	# update position
	addi $a0, $0, 0 # x
	addi $a1, $0, 128 # y

	jal move_ship
	
	la $a1, shipArray
	jal generate_ship
	
	j check_gg
	
respond_to_d:
	# check if at border
	la $t1, shipArray
	lw $t1, 32($t1) # t1 now stores position of bottom left corner of ship
	
	# get x,y value
	move $a0, $t1
	jal get_xy # x,y stored in v0,v1
	
	# address_xy = (y*width + 31)*4
	move $t2, $v1 
	addi $t3, $0, 4
	addi $t4, $0, WIDTH
	addi $t5, $0, 31
	
	
	mult $t2, $t4 
	mflo $t6 # y * width	
	add $t6, $t6, $t5 # y * width + 31
	mult $t6, $t3 	
	mflo $t2 # (y * width + 31) * 4
	
	beq $t2, $t1, obst # if t2 == t1 means we're at right border, jump to obst

	
	# erase ship
	li $a3, BLACK
	la $a2, shipArray
	
	addi $a0, $0, 36
	jal draw
	
	# update position
	addi $a0, $0, 4 # x
	addi $a1, $0, 0 # y
	jal move_ship
	
	la $a1, shipArray
	jal generate_ship
	
	j check_gg
	
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
	
	sw $0, ggToggle
	
	# pop from stack and return
	lw $ra, 0($sp)
	addi, $sp, $sp, 4
	jr $ra
respond_to_p:
	jal reset_data
	j main_loop
reset_ship:
	addi $s4, $0, 0 # initialize iteratable i 
	addi $sp, $sp, -4 
	sw $ra, 0($sp)
	
	# erase ship
	li $a3, BLACK
	add $a2, $a0, $0

	move $t7, $a0
	addi $a0, $0, 36
	jal draw
	move $a0, $t7
	
reset_ship_loop:
	# loop to reset all shipArray values to initial
	bge $s4, THIRTYSIX, reset_ship_end
	
	add $t7, $s4, $a0 # a0: shipArray
	add $t8, $s4, $a1 # a0: shipArrayImut
	
	# store elements of shipArrayImut to shipArray
	lw $t6, 0($t8)
	sw $t6, 0($t7)
	
	addi $s4, $s4, 4
	j reset_ship_loop
reset_ship_end:
	# regenerate ship
	jal generate_ship
	# pop from stack
	lw $ra, 0($sp)
	addi, $sp, $sp, 4
	jr $ra
	
reset_obstacle:
	# a0 is obstalce array
	addi $s4, $0, 0 # initialize iteratable i 
	addi $sp, $sp, -4 
	sw $ra, 0($sp)
	
	li $a3, BLACK
	add $a2, $a0, $0
	
	move $t7, $a0
	addi $a0, $0, 36
	
	jal draw
	move $a0, $t7
reset_obstacle_loop:
	# reset x unit 
	addi $t7, $0, 31
	sw $t7, 36($a0)
	
	# reset rest to 0
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
	lw $t1, level

	addi $t2, $0, 2
	beq $t1, $t2, obstacles_a
	bgt $t1, $t2, obstacles_b
	
	la $s6, obstacleArrayX # mem address of obstacleArrayX
	la $s7, obstacleArrayY # mem addresss of obstacleArrayY
	j regular_obstacles
	
obstacles_a:
	la $s6, obstacleArrayXa # mem address of obstacleArrayXa
	la $s7, obstacleArrayYa # mem addresss of obstacleArrayYa
	
	addi $t3, $0, 2
	sw $t3, x_regen

	j regular_obstacles
obstacles_b:
	la $s6, obstacleArrayXb # mem address of obstacleArrayXa
	la $s7, obstacleArrayYb # mem addresss of obstacleArrayYa
	
	addi $t3, $0, 7
	sw $t3, x_regen

	j regular_obstacles
		
regular_obstacles:
	addi $s4, $0, 0 # s4 for main function, t2 for helper function
obst_loop:
	bge $s4, SIXTY, main_end
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
	lw $t3, x_regen
	addi $t3, $0, 1
	ble $t4, $t3, if_regen
	lw $a1, speed1 # how much units they move left
	j main_else
	
obstacle2:
	la $s5, obstacleArray2 # mem addr of obstacleArray1
	add $a2, $s5, $0 # send mem addresses as parameters for generate_obst
	lw $t4, 36($s5) # t4 is x position
	# check if we generate obstacles or move them
	addi $t3, $0, 31
	beq $t4, $t3, if
	lw $t3, x_regen
	ble $t4, $t3, if_regen
	lw $a1, speed2
	j main_else
	
obstacle3:
	la $s5, obstacleArray3 # mem addr of obstacleArray1
	add $a2, $s5, $0 # send mem addresses as parameters for generate_obst
	lw $t4, 36($s5) # t4 is x position
	# check if we generate obstacles or move them
	addi $t3, $0, 31
	beq $t4, $t3, if
	lw $t3, x_regen
	ble $t4, $t3, if_regen
	lw $a1, speed1
	j main_else
	
obstacle4:
	la $s5, obstacleArray4 # mem addr of obstacleArray1
	add $a2, $s5, $0 # send mem addresses as parameters for generate_obst
	lw $t4, 36($s5) # t4 is x position
	# check if we generate obstacles or move them
	addi $t3, $0, 31
	beq $t4, $t3, if
	lw $t3, x_regen
	ble $t4, $t3, if_regen
	lw $a1, speed2
	j main_else
	
if_regen:

	jal regenerate_obst
	lw $t1, obstacleCount
	subi $t1, $t1, 1
	sw $t1, obstacleCount
	
	j obst_next
	
if:
	jal generate_obst
	# e draw-out the initial generated obstacles
	add $a2, $s5, $0 
	lw $a3, obstacleColor

	addi $a0, $0, 36
	jal draw
	
	li $v0, 32
	li $a0, SLEEP # Wait one second (1000 milliseconds)
	syscall
	
	j obst_next
	
main_else:
	# move obstacles
	# a1 is how much the obstacles move
	# a2 is memory address of obstacle
	li $a3, BLACK
	
	move $s2, $a2 # save obstacle mem into s2 for now
	
	addi $a0, $0, 36
	jal draw
	jal update_obst

main_else_return:
	lw $a3, obstacleColor
	addi $a0, $0, 36
	jal draw
	
	# bullet stuff (excluding collision with obstacle)
	lw $t1, bulletToggle
	beqz $t1, after_bullet
	# update bullet location
	la $a2, bulletArray
	
	li $a3, BLACK
	addi $a0, $0, 12
	jal draw
	
	jal move_bullet
	
	li $a3, YELLOW
	addi $a0, $0, 12
	jal draw
	
	# check bullet collision (at end)
	la $a2, bulletArray
	jal bullet_at_end
check_bullet_obstacle_collision:
	# check bullet collision (at obstacle)
	# move obstacle array to $a2
	move $a2, $s2
	la $a3, bulletArray
	addi $a1, $0, 12
	jal collisions_check
	
	beqz $v0, after_bullet # no collisions
	# yes collision
	la $a2, bulletArray
	jal reset_bullet
	
	move $a0, $s2
	jal reset_obstacle
after_bullet:
	move $a2, $s2 # s2 has obstacle array
	
	lw $t1, invinsibility
	bnez $t1, invinsibility_on
	# check for collisions
	la $a3, shipArray
	addi $a1, $0, 36
	jal collisions_check
	# check if collisions_check returned true
	addi $t1, $0, 1
	beq  $v0, $t1, collision_occur
	j obst_next
invinsibility_on:
	# update invinsibility counter
	lw $t1, invinsibilityCounter
	subi $t1, $t1, 1
	sw $t1, invinsibilityCounter
	
	beqz $t1, reset_invinsibility
	# if not zero, ignore
	j obst_next
reset_invinsibility:
	# reset counter
	addi $t1, $0, 50
	sw $t1, invinsibilityCounter
	# turn off invinsibility
	sw $0, invinsibility
	# redraw ship
	la $a1, shipArray
	jal generate_ship
main_else_end:
	
	j obst_next

bullet_at_end:
	# a2 is array 
	# push ra to stack
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	addi $t8, $0, 0 # initialize i to 0
bullet_at_end_loop:
	bge $t8, TWELVE, bullet_at_end_false
	
	add $t1, $a2, $t8 # the index of bullet position in t1	
	lw $t1, 0($t1) # get position of bullets
	# get x,y value
	move $a0, $t1
	jal get_xy # x,y stored in v0,v1
	
	# check if unit location is at x = 31
	# address_xy = (y*width + 31)*4
	move $t7, $v1 
	addi $t3, $0, 4
	addi $t4, $0, WIDTH
	addi $t5, $0, 31

	mult $t7, $t4 
	mflo $t6 # y * width	
	add $t6, $t6, $t5 # y * width + 31
	mult $t6, $t3 	
	mflo $t7 # (y * width + 31) * 4
	
	beq $t7, $t1, bullet_at_end_true # if t2 == t1 means bullet is at border
	# reset bullet, turn off bulletToggle and draw it to black
	addi $t8, $t8, 4
	j bullet_at_end_loop
bullet_at_end_true:
	# exit
	# a2 has bullet array
	# a3 will have color
	la $a2, bulletArray
	jal reset_bullet
	
	lw $ra, 0($sp)
	addi, $sp, $sp, 4
	jr $ra
bullet_at_end_false:
	# exit
	lw $ra, 0($sp)
	addi, $sp, $sp, 4
	jr $ra
	
collisions_check:
	# push ra to stack
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	addi $t2, $0, 0 # initialize i for loop
collisions_check_loop:
	# a2 stores the obstacle mem addresss for positions
	# a3 stores the ship/bullet mem address for positions
	# a1 stores the ship/bullet array size
	bge $t2, THIRTYSIX, collisions_check_end
	
	add $t4, $t2, $a2 # t4 obstaclle index
	addi $t3, $0, 0 # initialize j for inner loop
collisions_check_inner:
	bge $t3, $a1, collisions_check_inner_end
	
	add $t5, $t3, $a3 # t5 ship/bullet index
	
	lw $t6, 0($t4) # load obsctale position into t6
	lw $t7, 0($t5) # load ship position into t7
	
	
	beq $t6, $t7, collisions_check_true # if collisions occurs, set return value to true, and exit loop
	
	addi $t3, $t3, 4
	j collisions_check_inner
	
collisions_check_inner_end:		
	addi $t2, $t2,4 
	j collisions_check_loop
collisions_check_end:	
	# should only arrive here if there are no collisions
	addi $v0, $0, 0 # set return value to false
	lw $ra, 0($sp)
	addi, $sp, $sp, 4
	jr $ra
collisions_check_true:
	addi $v0, $0, 1 # set return value to true
	lw $ra, 0($sp)
	addi, $sp, $sp, 4
	jr $ra
	
collision_occur:
	# update hp_loss and redraw hp 
	lw $t1, hpLoss
	addi $t1, $t1, 8
	sw $t1, hpLoss
	
	lw $a0, hpLoss
	jal set_hp
	# check if hp = 0, aka hp_loss = 32
	lw $t1, hpLoss
	bge $t1, THIRTYTWO, game_over
	
	# turn invinsibility on
	addi $t1, $0, 1
	sw $t1, invinsibility
	
	# draw ship
	la $a1, shipArray
	jal generate_ship
	
	# if not gg, jump back
	j obst_next
	
generate_obst:	
	# push ra to stack
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	# generate obst x,y positions then draw them (same parameters)
	li $v0, 42
	li $a0, 0
	li $a1, 29
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
	# next we goes to erase the obstacle
	addi $a0, $0, 36
	
draw:
	# a0 is loop size
	# a2 array
	# a3 color
	addi $sp, $sp, -4 
	sw $ra, 0($sp)
	addi, $t2, $0, 0 # load i variable
draw_loop:
	bge $t2, $a0, draw_end
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

	move $t8, $a1, # move a1 to t7 since we'll need a1 for calling address_xy
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
	sub $t2, $t2, $t8 # how much obstacle moves
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
	# new position to add
	add $t4, $t4, $a0 
	add $t4, $t4, $a1 
	
	# update mem location with new position	
	sw $t4, 0($t3) # store the new position in shipArray	
	
	addi $t2, $t2, 4
	j move_ship_loop
move_ship_end:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

move_bullet:
	addi $sp, $sp, -4 
	sw $ra, 0($sp)
	
	addi $t2, $0, 0  # initialize 1
move_bullet_loop:
	# a1 is bulletArray
	bge $t2, 12, move_bullet_end
	
	add $t3, $a2, $t2 # get index of bullet array
	
	# load new bullet position
	lw $t4, 0($t3)
	addi $t4, $t4, 4 # move it right 1 unit
	sw $t4, 0($t3)
	
	addi $t2, $t2, 4
	j move_bullet_loop
move_bullet_end:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
address_xy:
	# stack $ra for returning from address_xy
	# a0: x 
	# a1: y
	
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
get_xy:
	# stack $ra for returning from address_xy
	addi $sp, $sp, -4 
	sw $ra, 0($sp)
	
	# to get y, do position // 128. Realize that address(x,y) is Quotient remainder form
	add $t2, $0, $a0
	addi $t3, $0, 128
	div $t2, $t3
	
	mflo $v1 # v1 will contain y value (take quotient)
	
	# per QRT remainder // 4 is X
	mfhi $t4
	addi $t5, $0, 4
	div $t4, $t5
	
	mflo $v0 # move x to v0
	
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
  	
main_end:
	# the end of main function, jump back to main_loop
	li $v0, 32
	li $a0, SLEEP # Wait one second (1000 milliseconds)
	syscall
	
	j main_loop
	
set_hp: 
	# stack $ra for returning from address_xy
	addi $sp, $sp, -4 
	sw $ra, 0($sp)
	
	# erase hp first
	# a0 how much hp is lost (multiple of 8)
	# t0 is the base address
	
	addi $t2, $0, 0 # t2 is i value
	addi $t3, $0, 32 # t3 is 32
	sub  $t3, $t3, $a0 
	
	addi $t4, $0, 4
	
	mult $t3, $t4 # the max we're going to 
	
	mflo $t3 # for loop condition(max we're going to)
	
	addi $t5, $0, 3968 # first unit of health bar 
	add $t5, $t5, $t0
set_hp_loop:
	bge $t2, $t3, erase_missing_hp
	
	li $t1, 0xFF0000 # bright red as health bar
	add $t6, $t5, $t2
	sw $t1, 0($t6)
	
	addi $t2, $t2, 4
	j set_hp_loop
	
erase_missing_hp:
	bge $t2, HPMAX, set_hp_end
	
	li $t1, 0x000000
	add $t6, $t5, $t2
	sw $t1, 0($t6)
		
	addi $t2, $t2, 4
	j erase_missing_hp
set_hp_end:
	# pop $ra from stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

game_over:
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
	
	# toggle esc
	addi $t1, $0, 1
	sw $t1, ggToggle
	# continue looping in main_loop until player presses "p" to reset game
	j main_loop
reset_data:
	# stack $ra for returning from address_xy
	addi $sp, $sp, -4 
	sw $ra, 0($sp)
	
	# reset x_regen
	addi $t1, $0, 1
	sw $t1, x_regen

	# reset hpLoss
	sw $0, hpLoss
	lw $a0, hpLoss
	jal set_hp

	# reset level modifier
	addi $t1, $0, 1
	sw $t1, level
	
	# reset obstacle color
	addi $t1, $0, GREY
	sw $t1,  obstacleColor
	
	# reset obstacle count 
	addi $t1, $0, 16
	sw $t1, obstacleCount
	
	# reset speed
	addi $t1, $0, 1
	sw $t1, speed1
	
	addi $t1, $0, 2
	sw $t1, speed2
	
	# change all obstacle and ship arrays	
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
	
	# reset ship
	la $a0, shipArray
	la $a1, shipArrayImut
	jal reset_ship
	
	# reset bullet 
	la $a2, bulletArray
	jal reset_bullet
	
	# change ggToggle to 0 if need to
	lw $t1, ggToggle
	beqz  $t1, noChangeEsc
	sw $0, ggToggle
	jal erase_gg
noChangeEsc:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

bullet_obst:
	# check if obstalce hits bullet 
	# a2 is obstacle array mem address
	# a3 is bullet array mem address
	
	addi $t2, $0, 0 # initialize $t2
	
	move $t7, $a2 # t7 is now obstalce array
	move $t8, $a3 # t8 is now bullet array
bullet_obst_loop:
	bge $t2, 36, bullet_obst_end
	
	# load color of obstacle 
	add $t1, $t2, $t7
	lw $t1, 0($t1) #  the obstalce position
	add $t3, $t1, $t0 
	lw $t4, 0($t3) 
 
 	li $t1, YELLOW
	bne $t1, $t6, bullet_obst_no_collision # no collision if that position is not yellow
	
	# reset obstacle 
	# a0 is obstacle array
	
	move $a0, $t2
	jal reset_obstacle
	
	# there's collision
	# a2 is bullet array
	move $a2, $t8
	jal reset_bullet
	
	j bullet_obst_end # once there's collision, we leave
bullet_obst_no_collision:
	addi $t2, $t2, 4
	j bullet_obst_loop
bullet_obst_end:
	jr $ra
	
reset_bullet:
	# a2 is bullet array
	# stack $ra for returning from draw
	addi $sp, $sp, -4 
	sw $ra, 0($sp)
	
	li $a3, BLACK
	addi $a0, $0, 12
	jal draw 
	
	sw $0, bulletToggle
	
	# pop ra from stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
end:
	li $v0, 1 # terminate the program gracefully
	addi $t0, $0, 69
	move $a0, $t0
	syscall
	li $v0, 10 # terminate the program gracefully
	syscall
