# File Name: Pgm4.asm
# Author: Naman Gangwani
# Procedures	init		This will instantiate all the values in the array to zero
#		readChar	This will read all characters in the file one by one and add to the counter if 0-9 is found
#		printHistogram	This will display all the digit frequencies in the file
#		strlen		This function will return the length of an inputted string

	.data
buffer: .space 	1024		# For storing the filename
file:	.space 	1024		# For storing the contents of the file
prompt:	.asciiz "What file contains your information? "
				# Prompting user for visual represnetation in the output
info:	.asciiz "\nThese are the digit frequencies in your file: \n"
				# For visual representation in the output
colon:	.asciiz ": "
newLine:.asciiz "\n"		# For moving on to the next line
count:	.space 	1024		# Allocates space for the count to keep count of digit occurrences
countsz:.word 	10		# Maximum size of the count
	.text
	lw $t8, countsz		# Saves the count size in a register
	la $t9, count		# Saves the count array into register $t9 
	li $t0, 0		# Counter i = 0

###################################
## Procedure 	init		This will instantiate all the values in the array to zero
## Author: Naman Gangwani
## $t0	I/P	int		This value is the counter i for incrementing through the array
## $t8	I/P	int		This value is the maximum size of the array
## $t9	I/P	array		This value will be count array that needs its values to be instatiated
## $t9	O/P	int		This value will be array after all its values are instantiated
###################################
init:
	beq $t0, $t8, continue	# If i has reached the size of the array, exit/continue with the program
	sb $t9, ($t9)		# Initialize at current array index
	addi $t9, $t9, 4	# Move to next array index
	addi $t0, $t0, 1	# Increment i by one
	b init			# Restart loop
continue:
	li $v0, 4		# System call code for print_string
  	la $a0, prompt		# Puts the new line character into the register for the first argument
  	syscall			# Prints the string based on system call code
  	
	li $v0, 8		# System call code for read_string
	la $a0, buffer		# Will be stored in the space allocated by buffer
	li $a1, 199		# Maximum number of characters is 199
	syscall			# Takes in a string from the user
	
	jal strlen		# Gets the length of the inputted string
  	
  	addi $v0, $v0, -1	# Subtracts 1 to get position of the last index of the string
	sb $0, buffer($v0)	# Changes last character (nl) to a null character
	la $a0, buffer		# Updates the first argument to the adjusted string
  	
	li $v0, 13		# System call code for opening a file
	li $a1, 0		# flags are 0
	li $a2, 0700		# mode is 0
	syscall			# Opens the file based on system call code
	move $a3, $v0		# Stores the file descriptor for later usage

###################################
## Procedure 	readChar	This will read all characters in the file one by one and add to the counter if 0-9 is found
## Author: Naman Gangwani
## $a0	I/P	file_descriptor	This value is the file descriptor for the user specified file
## $t9	I/P	array		This value will be count array that needs the digit frequencies of the file stored in it
## $t9	O/P	int		This value will be count array after all the digit frequencies have been counted in the file
###################################
readChar:
	move $a0, $a3		# Moves the file descriptor to the first argument
	li $v0, 14		# System call code to read from file
	la $a1, file		# Contents of the file will be stored in file variable
	li $a2, 1		# Reads 1 character maximum
	syscall			# Reads file based on system call code
	
	beqz $v0, exit		# If it has reached the end of the file, exit

	lb $t0, file($0)	# Loads the ASCII value of the character
	addi $t0, $t0, -48	# Subtracts 48 for convenience of reading
	bltz $t0, readChar	# If it is less than 0, do nothing and restart the loop
	bgt $t0, 9, readChar	# If it is greater than 9, do nothing and restart the loop
	
	sll $t1, $t0, 2		# Multiplies the ASCII value by 4
	add $t1, $t9, $t1	# Retrieves the address of its index position
	lb $t2, 0($t1)		# Gets the value at that array index
	addi $t2, $t2, 1	# Increments that value by one
	sb $t2, 0($t1)		# Stores new value back into the address of that array index
	
  	j readChar		# Read another character
exit:
	li $v0, 4		# System call code for print_string
  	la $a0, info		# Puts the colon sign into the register for the first argument
  	syscall			# Prints the string based on system call code
	addi $t0, $zero, 0	# Sets counter i = 0
	
###################################
## Procedure 	printHistogram	This will display all the digit frequencies in the file
## Author: Naman Gangwani
## $t0	I/P	int		This value is the counter i for incrementing through the array
## $t9	I/P	array		This value will be count array that will be incremented through and have its values printed
## 	O/P	string		The histogram printed as a result of incrementing through the count array
###################################
printHistogram:
	beq $t0, $t8, exit2	# If i = maximum size of the array, exit
	
	sll $t1, $t0, 2		# Multiplies index position by four
	add $t1, $t9, $t1	# Retrieves the address of its index position
	
	li $v0, 1		# System call code for print_int
	move $a0, $t0		# Puts i into the register for the first argument
	syscall			# Prints the integer based on system call code
	
	li $v0, 4		# System call code for print_string
  	la $a0, colon		# Puts the colon sign into the register for the first argument
  	syscall			# Prints the string based on system call code
  	
	li $v0, 1		# System call code for print_int
	lb $a0, 0($t1)		# Puts count[i] into the register for the first argument
	syscall			# Prints the integer based on system call code
	
	li $v0, 4		# System call code for print_string
  	la $a0, newLine		# Puts the new line character into the register for the first argument
  	syscall			# Prints the string based on system call code
	
	addi $t0, $t0, 1	# Increments counter i by 1
	j printHistogram	# Print next frequency
exit2:
	li $v0, 10		# System call code for exit
	syscall			# Exits the program based on system call code

###################################
## Procedure 	strlen		This function will return the length of an inputted string
## Author: Naman Gangwani
## $a0	I/P	string		This value will be string passed through the function
## $t0	O/P	int		This value will be the length of the string passed through as an argument
###################################
strlen: 
	li $v0, 0 		# Initialize the counter to zero
loop:	
	lb $t1, 0($a0) 		# Load the next character into t1
	beqz $t1, return 	# Check for the null character
	addi $a0, $a0, 1 	# Increment the string pointer
	addi $v0, $v0, 1 	# Increment the counter
	j loop 			# Return to the top of the loop
return:	
	jr $ra			# Returns back to the thread that called it
