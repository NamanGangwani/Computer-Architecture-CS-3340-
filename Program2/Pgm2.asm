# File Name: Pgm2.asm
# Author: Naman Gangwani
# Procedures	readLine	This function will multiply the integers read on every line and display them
#		strlen		This function will return the length of an inputted string
#		readNum		This function will read the integer on the current line in the file

	.data
buffer: .space 1024		# For storing the filename
file:	.space 1024		# For storing the contents of the file
multip: .asciiz " * "		# For visual representation in the output
equal: 	.asciiz " = "		# For visual representation in the output
	
	.text
	li $v0, 8		# System call code for read_string
	la $a0, buffer		# Will be stored in the space allocated by buffer
	li $a1, 199		# Maximum number of characters is 199
	syscall			# Takes in a string from the user
	
	jal strlen		# Gets the length of the inputted string
  	
  	addi $t0, $t0, -1	# Subtracts 1 to get position of the last index of the string
	sb $0, buffer($t0)	# Changes last character (nl) to a null character
	la $a0, buffer		# Updates the first argument to the adjusted string
  	
	li $v0, 13		# System call code for opening a file
	li $a1, 0		# flags are 0
	li $a2, 0		# mode is 0
	syscall			# Opens the file based on system call code
	move $a0, $v0		# Moves the file descriptor to the first argument
	
	li $v0, 14		# System call code to read from file
	la $a1, file		# Contents of the file will be stored in file variable
	li $a2, 20		# Reads 11 characters maximum
	syscall			# Reads file based on system call code
	
	addi $t5, $t5, 1	# Final result = 1

###################################
## Procedure 	readLine	This function will multiply the integers read on every line and display them
## Author: Naman Gangwani
##	O/P	int		This value will be the integer on the line (for every loop)
##	O/P	string		This value will be the multiplication sign (between each integer printed)
###################################
readLine:
	jal readNum		# Read the number on the current line
  	
  	li $v0, 1		# System call code for print_int
  	move $a0, $s1		# Puts the read integer into the register for the first argument
  	syscall			# Prints the integer based on system call code
  	
	mul $t5, $t5, $s1	# Multiplies the read integer by the current result
	beqz $t2, exit		# If it has reached the end of the file, stop reading the file
	
	li $v0, 4		# System call cod efor print_string
  	la $a0, multip		# Puts the multiplication sign into the register for the first argument
  	syscall			# Prints the string based on system call code
  	
	j readLine		# Move on to the next line
exit:
  	li $v0, 4		# System call code for print_string
  	la $a0, equal		# Puts the equal sign into the register for the first argument
  	syscall			# Prints the string based on system call code
  	
  	li $v0, 1		# System call code for print_int
  	move $a0, $t5		# Puts the final result of multiplication into the register for the first argument
  	syscall			# Prints the integer based on system call code

	li $v0, 10		# System call code for exit
	syscall			# Exits the program based on system call code
	
###################################
## Procedure 	strlen		This function will return the length of an inputted string
## Author: Naman Gangwani
## $a0	I/P	string		This value will be string passed through the function
##	O/P	int		This value will be the length of the string passed through as an argument
###################################
strlen: 
	li $t0, 0 		# Initialize the counter to zero
loop:	
	lb $t1, 0($a0) 		# Load the next character into t1
	beqz $t1, return 	# Check for the null character
	addi $a0, $a0, 1 	# Increment the string pointer
	addi $t0, $t0, 1 	# Increment the counter
	j loop 			# Return to the top of the loop
return:	
	jr $ra			# Returns back to the thread that called it

###################################
## Procedure 	readNum		This function will read the integer on the current line in the file
## Author: Naman Gangwani
## $a1	I/P	string		This value will be contents of the file passed through the function
##	O/P	int		This value will be the parsed integer on the current line in the file
###################################
readNum:
	li $s1, 0 		# Return value = 0 initially
	li $t3, 1		# Sign = 1
loop2:	
	lb $t2, 0($a1)
	beqz $t2, incReturn	# If char is a null terminator, exit
	beq $t2, 10, incReturn	# If char is a new line (cr), exit
	beq $t2, 13, incReturn	# If char is a new line (nl), exit
	bne $t2, 45, continue	# If it's not a negative sign (-), continue to parse the number
	
	li $t3, -1		# Changes sign if it begins with a negative sign (-)
	addi $a1, $a1, 1	# Increment the string pointer
	j loop2
continue:
	addi $a1, $a1, 1	# Increment the string pointer
	
	mul $s1, $s1, 10	# Shifts current number to the left by one
	addi $t4, $t2, -48	# Subtracts ASCII value of current char by ACII value of char '0'
	add $s1, $s1, $t4	# Adds to the current number
	
	j loop2			# Continue searching for more numbers
incReturn:
	addi $a1, $a1, 1	# Increments to the next character
	lb $t2 0($a1)		# Reads the new character it just incremented to
	beq $t2, 10, incReturn	# If char is a new line (cr), keep incrementing
	beq $t2, 13, incReturn	# If char is a new line (nl), keep incrementing
	mul $s1, $s1, $t3	# Multiplies the retrieved value by the sign
	jr $ra			# Returns back to the thread that called it
