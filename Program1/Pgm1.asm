# File Name: Pgm1.asm
# Author: Naman Gangwani
# Procedure	"Hello World"		This will print the name, birth month, and birth date of the author

	.data	
			
name:	.asciiz "Naman Gangwani "	# Stores the author's name in a string
zero:	.word 0				# Stores the number zero in an int
month:	.word 8				# Stores the author's birth month in an int
slash:	.asciiz "/"			# Stores a slash symbol in a string
day:	.word 2				# Stores the author's birth date in a string
	
	.text
	
	###################################
	## Procedure 	Procedure	"Hello World"
	## Author: Naman Gangwani
	##	O/P	string		This value will be the author's name
	##	O/P	int		This value will be the number 0 (for double digit number beginning with 0)
	##	O/P	int		This value will be the author's birth mont
	##	O/P	string		This value will the string containing the slash character
	##	O/P	int		This value will be the number 0 (for double digit number beginning with 0)
	##	O/P	int		This value will be the author's birth date
	###################################
			
	li $v0, 4			# System call code for print_string
	la $a0, name			# Puts author's name in the register for the first argument
	syscall				# Prints the first argument based on the system call code
	
	li $v0, 1			# System call code for print_int
	lw $a0, zero			# Puts the number zero in the register for the first argument
	syscall				# Prints the first argument based on the system call code
	
	li $v0, 1			# System call code for print_int
	lw $a0, month			# Puts the author's birth month in the register for the first argument
	syscall				# Prints the first argument based on the system call code
	
	li $v0, 4			# System call code for print_string
	la $a0, slash			# Puts string containing slash character in the register for the first argument
	syscall				# Prints the first argument based on the system call code
	
	li $v0, 1			# System call code for print_int
	lw $a0, zero			# Puts the number zero in the register for the first argument
	syscall				# Prints the first argument based on the system call code
	
	li $v0, 1			# System call code for print_int
	lw $a0, day			# Puts the author's birth date in the register for the first argument
	syscall				# Prints the first argument based on the system call code
	
	li $v0, 10			# System call code for exit
	syscall				# Exits the program based on the system call code
