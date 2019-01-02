# File Name: Pgm5.asm
# Author: Naman Gangwani
# Procedures	readLine	This will read all lines in the file and decode their instructions
#		readBits	This function will return the decimal representation of the specified bits in a bit string
#		binToDec	This function will return the decimal representation of a bit string
#		strlen		This function will return the length of an inputted string
#		printString	This function will print a specified string
#		printInt	This function will print a specified integer
	.data
buffer: .space 	1024		# For storing the linename
line:	.space 	1024		# For storing the contents of the line
prompt:	.asciiz "What file contains your information? "
				# Prompting user for visual represnetation in the output
rType:	.asciiz "R-type: "	# To identify the R-types in the output
iType:	.asciiz "I-type: "	# To identify the I-types in the output
jType:	.asciiz "J-type: "	# To identify the J-types in the output
frType:	.asciiz "FR-type: "	# To identify the FR-types in the output
fiType:	.asciiz "FI-type: "	# To identify the FI-types in the output
invalid:.asciiz "Invalid: "	# To identify out invalid instruction types in the ouput
opcode:	.asciiz "opcode: "	# To identify the opcodes in the output
rs:	.asciiz " rs: "		# To identify the rs's of R-types & I-types in the output
rt:	.asciiz " rt: "		# To identify the rt's of R-types & I-types in the output
rd:	.asciiz " rd: "		# To identify the rd's of R-types in the output
shamt:	.asciiz " shamt: "	# To identify the shamts of R-types in the output
funct:	.asciiz " funct: "	# To identify the functs of R-types and FR-types in the output
imm:	.asciiz " imm: "	# To identify out the imms of I-types and FI-types in the output
address:.asciiz	" address: "	# To identify out the addresses of J-types in the output
fmt:	.asciiz " fmt: "	# To identify out the fmts of FR-types and FI-types in the output
ft:	.asciiz " ft: "		# To identify out the fts of FR-types and FI-types in the output
fs:	.asciiz " fs: "		# To identify out the fs's of FR-types in the output
fd:	.asciiz " fd: "		# To identify out the fds of FR-types in the output
re:	.asciiz " remainder: "	# To identify out the remainders of invalids in the output
comma:	.asciiz ","		# To print out commas in the output
newLine:.asciiz "\n"		# For moving on to the next line in the output
	.text
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
	move $t9, $v0		# Stores the file descriptor for later usage

	la $a0, newLine		# Print new line
	jal printString		# Prints string in the $a0 register
	
###################################
## Procedure 	readLine	This will read all lines in the file and decode their instructions
## Author: Naman Gangwani
## $a0	I/P	file_descriptor	This value is the file descriptor for the user specified file
##	O/P	string		This will be the instruction type (R, I, J, FR, FI, or Invalid) along with their respective contents for each line
###################################
readLine:
	move $a0, $t9		# Moves the file descriptor to the first argument
	li $v0, 14		# System call code to read from file
	la $a1, line		# Contents of the line will be stored in line variable
	li $a2, 34		# Argument that says it wants 34 characters read (including cr and nl characters)
	syscall			# Reads line based on system call code
	
	blt $v0, 33, exit	# If it didn't read an entire line's number of characters, exit
	
	li $t0, 33		# Register representing 34th character
	sb $zero, line($t0)	# Changes new line character to null
	li $t0, 32		# Register representing 33rd character
	sb $zero, line($t0)	# Changes carriage return character to null
	
	la $a0, line		# Stores bit string into register
	li $a1, 0		# Wants to mask up to (but not including) index position 6 with 0s
	li $a2, 26		# Shift 21 bits afterwards
	jal readBits		# Retrieves the decimal format of the bits starting at bit $a1
	move $v1, $v0		# Stores the opcode into $v1 for printing it later
	
	beqz $v0, readRType	# Reads the rest of the line as an R-type if opcode = 0
	
	beq $v0, 2, readJType	# Reads the rest of the line as a J-type if opcode = 2
	beq $v0, 3, readJType	# Reads the rest of the line as a J-type if opcode = 3	
	
	beq $v0, 17, readFRType	# Reads the rest of the line as an R-type if opcode = 17
	
	beq $v0, 49, readFIType	# Reads the rest of the line as an FI-type if opcode = 49
	beq $v0, 53, readFIType	# Reads the rest of the line as an FI-type if opcode = 53	
	beq $v0, 57, readFIType	# Reads the rest of the line as an FI-type if opcode = 57
	beq $v0, 61, readFIType	# Reads the rest of the line as an FI-type if opcode = 61
	
	blt $v0, 16, readIType	# Reads the rest of the line as an I-type if 4 <= opcode <= 15
	sub $t0, $v0, 32	# Subtracts 32 from the opcode
	bltz $t0, default	# If it's not in the range, it's invalid
	blt $t0, 6, readIType	# Reads the rest of the line as an I-type if 32 <= opcode <= 37
	beq $v0, 40, readIType	# Reads the rest of the line as an FI-type if opcode = 40
	beq $v0, 41, readIType	# Reads the rest of the line as an FI-type if opcode = 41
	beq $v0, 43, readIType	# Reads the rest of the line as an FI-type if opcode = 42
default:
	la $a0, invalid		# Print invalid
	jal printString		# Prints string in the $a0 register
	
	la $a0, opcode		# Print opcode
	jal printString		# Prints string in the $a0 register
	move $a0, $v1		# Stores results in first argument
	jal printInt		# Prints %d for opcode
	la $a0, comma		# Print comma
	jal printString		# Prints string in the $a0 register
	
	la $a0, re		# Print remainder
	jal printString		# Prints string in the $a0 register
	la $a0, line		# Stores bit string into register
	li $a1, 6		# Wants to mask up to (but not including) index position 6 with 0s
	li $a2, 21		# Shift 21 bits afterwards
	jal readBits		# Retrieves the decimal format of the bits starting at bit $a1
	move $a0, $v0		# Stores results in first argument
	jal printInt		# Prints %d for opcode
	
	j continue		# Move on to the next line
readRType:
	la $a0, rType		# Print the R-type
	jal printString		# Prints string in the $a0 register
	
	la $a0, opcode		# Print opcode
	jal printString		# Prints string in the $a0 register
	move $a0, $v1		# Stores results in first argument
	jal printInt		# Prints %d for opcode
	la $a0, comma		# Print comma
	jal printString		# Prints string in the $a0 register
	
	la $a0, rs		# Print rs
	jal printString		# Prints string in the $a0 register
	la $a0, line		# Stores bit string into register
	li $a1, 6		# Wants to mask up to (but not including) index position 6 with 0s
	li $a2, 21		# Shift 21 bits afterwards
	jal readBits		# Retrieves the decimal format of the bits starting at bit $a1
	move $a0, $v0		# Stores results in first argument
	jal printInt		# Prints %d for rs	
	la $a0, comma		# Print comma
	jal printString		# Prints string in the $a0 register
	
	la $a0, rt		# Print rt
	jal printString		# Prints string in the $a0 register
	la $a0, line		# Stores bit string into register
	li $a1, 11		# Wants to mask up to (but not including) index position 11 with 0s
	li $a2, 16		# Shift 16 bits afterwards
	jal readBits		# Retrieves the decimal format of the bits starting at bit $a1
	move $a0, $v0		# Stores results in first argument
	jal printInt		# Prints %d for rt
	la $a0, comma		# Print comma
	jal printString		# Prints string in the $a0 register
	
	la $a0, rd		# Print rd
	jal printString		# Prints string in the $a0 register
	la $a0, line		# Stores bit string into register
	li $a1, 16		# Wants to mask up to (but not including) index position 16 with 0s
	li $a2, 11		# Shift 11 bits afterwards
	jal readBits		# Retrieves the decimal format of the bits starting at bit $a1
	move $a0, $v0		# Stores results in first argument
	jal printInt		# Prints %d for rd
	la $a0, comma		# Print comma
	jal printString		# Prints string in the $a0 register
	
	la $a0, shamt		# Print shamt
	jal printString		# Prints string in the $a0 register
	la $a0, line		# Stores bit string into register
	li $a1, 21		# Wants to mask up to (but not including) index position 21 with 0s
	li $a2, 6		# Shift 6 bits afterwards
	jal readBits		# Retrieves the decimal format of the bits starting at bit $a1
	move $a0, $v0		# Stores results in first argument
	jal printInt		# Prints %d for shamt
	la $a0, comma		# Print comma
	jal printString		# Prints string in the $a0 register
	
	la $a0, funct		# Print funct
	jal printString		# Prints string in the $a0 register
	la $a0, line		# Stores bit string into register
	li $a1, 26		# Wants to mask up to (but not including) index position 26 with 0s
	li $a2, 0		# Shift 0 bits afterwards
	jal readBits		# Retrieves the decimal format of the bits starting at bit $a1
	move $a0, $v0		# Stores results in first argument
	jal printInt		# Prints %d for shamt
	
	j continue		# Move on to the next line
readIType:
	la $a0, iType		# Print the I-type
	jal printString		# Prints string in the $a0 register
	
	la $a0, opcode		# Print opcode
	jal printString		# Prints string in the $a0 register
	move $a0, $v1		# Stores results in first argument
	jal printInt		# Prints %d for opcode
	la $a0, comma		# Print comma
	jal printString		# Prints string in the $a0 register
	
	la $a0, rs		# Print rs
	jal printString		# Prints string in the $a0 register
	la $a0, line		# Stores bit string into register
	li $a1, 6		# Wants to mask up to (but not including) index position 6 with 0s
	li $a2, 21		# Shift 21 bits afterwards
	jal readBits		# Retrieves the decimal format of the bits starting at bit $a1
	move $a0, $v0		# Stores results in first argument
	jal printInt		# Prints %d for rs	
	la $a0, comma		# Print comma
	jal printString		# Prints string in the $a0 register
	
	la $a0, rt		# Print rt
	jal printString		# Prints string in the $a0 register
	la $a0, line		# Stores bit string into register
	li $a1, 11		# Wants to mask up to (but not including) index position 11 with 0s
	li $a2, 16		# Shift 16 bits afterwards
	jal readBits		# Retrieves the decimal format of the bits starting at bit $a1
	move $a0, $v0		# Stores results in first argument
	jal printInt		# Prints %d for rt
	la $a0, comma		# Print comma
	jal printString		# Prints string in the $a0 register
	
	la $a0, imm		# Print imm
	jal printString		# Prints string in the $a0 register
	la $a0, line		# Stores bit string into register
	li $a1, 16		# Wants to mask up to (but not including) index position 16 with 0s
	li $a2, 0		# Shift 11 bits afterwards
	jal readBits		# Retrieves the decimal format of the bits starting at bit $a1
	move $a0, $v0		# Stores results in first argument
	jal printInt		# Prints %d for imm
	
	j continue		# Move on to the next line
readJType:
	la $a0, jType		# Print the J-type
	jal printString		# Prints string in the $a0 register
	
	la $a0, opcode		# Print opcode
	jal printString		# Prints string in the $a0 register
	move $a0, $v1		# Stores results in first argument
	jal printInt		# Prints %d for opcode
	la $a0, comma		# Print comma
	jal printString		# Prints string in the $a0 register
	
	la $a0, address		# Print address
	jal printString		# Prints string in the $a0 register
	la $a0, line		# Stores bit string into register
	li $a1, 6		# Wants to mask up to (but not including) index position 6 with 0s
	li $a2, 0		# Shift 0 bits afterwards
	jal readBits		# Retrieves the decimal format of the bits starting at bit $a1
	move $a0, $v0		# Stores results in first argument
	jal printInt		# Prints %d for address
	
	j continue		# Move on to the next line
readFRType:
	la $a0, frType		# Print the FR-type
	jal printString		# Prints string in the $a0 register
	
	la $a0, opcode		# Print opcode
	jal printString		# Prints string in the $a0 register
	move $a0, $v1		# Stores results in first argument
	jal printInt		# Prints %d for opcode
	la $a0, comma		# Print comma
	jal printString		# Prints string in the $a0 register
	
	la $a0, fmt		# Print fmt
	jal printString		# Prints string in the $a0 register
	la $a0, line		# Stores bit string into register
	li $a1, 6		# Wants to mask up to (but not including) index position 6 with 0s
	li $a2, 21		# Shift 21 bits afterwards
	jal readBits		# Retrieves the decimal format of the bits starting at bit $a1
	move $a0, $v0		# Stores results in first argument
	jal printInt		# Prints %d for fmt	
	la $a0, comma		# Print comma
	jal printString		# Prints string in the $a0 register
	
	la $a0, ft		# Print ft
	jal printString		# Prints string in the $a0 register
	la $a0, line		# Stores bit string into register
	li $a1, 11		# Wants to mask up to (but not including) index position 11 with 0s
	li $a2, 16		# Shift 16 bits afterwards
	jal readBits		# Retrieves the decimal format of the bits starting at bit $a1
	move $a0, $v0		# Stores results in first argument
	jal printInt		# Prints %d for ft
	la $a0, comma		# Print comma
	jal printString		# Prints string in the $a0 register
	
	la $a0, fs		# Print fs
	jal printString		# Prints string in the $a0 register
	la $a0, line		# Stores bit string into register
	li $a1, 16		# Wants to mask up to (but not including) index position 16 with 0s
	li $a2, 11		# Shift 11 bits afterwards
	jal readBits		# Retrieves the decimal format of the bits starting at bit $a1
	move $a0, $v0		# Stores results in first argument
	jal printInt		# Prints %d for fs
	la $a0, comma		# Print comma
	jal printString		# Prints string in the $a0 register
	
	la $a0, fd		# Print fd
	jal printString		# Prints string in the $a0 register
	la $a0, line		# Stores bit string into register
	li $a1, 21		# Wants to mask up to (but not including) index position 21 with 0s
	li $a2, 6		# Shift 6 bits afterwards
	jal readBits		# Retrieves the decimal format of the bits starting at bit $a1
	move $a0, $v0		# Stores results in first argument
	jal printInt		# Prints %d for fd
	la $a0, comma		# Print comma
	jal printString		# Prints string in the $a0 register
	
	la $a0, funct		# Print funct
	jal printString		# Prints string in the $a0 register
	la $a0, line		# Stores bit string into register
	li $a1, 26		# Wants to mask up to (but not including) index position 26 with 0s
	li $a2, 0		# Shift 0 bits afterwards
	jal readBits		# Retrieves the decimal format of the bits starting at bit $a1
	move $a0, $v0		# Stores results in first argument
	jal printInt		# Prints %d for funct
	
	j continue		# Move on to the next line
readFIType:
	la $a0, fiType		# Print the FI-type
	jal printString		# Prints string in the $a0 register
	
	la $a0, opcode		# Print opcode
	jal printString		# Prints string in the $a0 register
	move $a0, $v1		# Stores results in first argument
	jal printInt		# Prints %d for opcode
	la $a0, comma		# Print comma
	jal printString		# Prints string in the $a0 register
	
	la $a0, rs		# Print rs
	jal printString		# Prints string in the $a0 register
	la $a0, line		# Stores bit string into register
	li $a1, 6		# Wants to mask up to (but not including) index position 6 with 0s
	li $a2, 21		# Shift 21 bits afterwards
	jal readBits		# Retrieves the decimal format of the bits starting at bit $a1
	move $a0, $v0		# Stores results in first argument
	jal printInt		# Prints %d for rs	
	la $a0, comma		# Print comma
	jal printString		# Prints string in the $a0 register
	
	la $a0, rt		# Print rt
	jal printString		# Prints string in the $a0 register
	la $a0, line		# Stores bit string into register
	li $a1, 11		# Wants to mask up to (but not including) index position 11 with 0s
	li $a2, 16		# Shift 16 bits afterwards
	jal readBits		# Retrieves the decimal format of the bits starting at bit $a1
	move $a0, $v0		# Stores results in first argument
	jal printInt		# Prints %d for rt
	la $a0, comma		# Print comma
	jal printString		# Prints string in the $a0 register
	
	la $a0, imm		# Print imm
	jal printString		# Prints string in the $a0 register
	la $a0, line		# Stores bit string into register
	li $a1, 16		# Wants to mask up to (but not including) index position 16 with 0s
	li $a2, 0		# Shift 11 bits afterwards
	jal readBits		# Retrieves the decimal format of the bits starting at bit $a1
	move $a0, $v0		# Stores results in first argument
	jal printInt		# Prints %d for imm
	
	j continue		# Move on to the next line
continue:
	la $a0, newLine		# Print new line
	jal printString		# Prints string in the $a0 register
	
	j readLine		# Read the next line
exit:
	li $v0, 10		# System call code for exit
	syscall			# Exits the program based on system call code

###################################
## Procedure 	readBits	This function will return the decimal representation of the specified bits in a bit string
## Author: Naman Gangwani
## $a0	I/P	string		This will be the bit string passed through the function
## $a1	I/P	int		This value will be the length of the index position the bit string will mask 0s up to (but not including)
## $a2	I/P	int		This value will be how far the bits will be shifted right logically
## $v0	O/P	int		This value will be the decimal representation of of the specified bits in the bit string
###################################
readBits:
	move $v1, $ra		# Preserves the return address
	li $t0, 0		# Index position in the bit string
	li $t1, 48		# Represents 0 ASCII code
mask:
	beq $t0, $a1, returnVal	# If it has reached the index position, stop masking
	sb $t1, 0($a0)		# Mask current index to be 0
	addi $a0, $a0, 1	# Increment next index by one
	addi $t0, $t0, 1	# Increment index counter by one
	j mask			# Continue masking
returnVal:
	sub $a0, $a0, $t0	# Returns bit string back to index position 0
	li $a1, 32		# Parse a bit string of length 32
	jal binToDec		# Retrieves decimal version of bit string
	srlv $v0, $v0, $a2	# Shifts it right by $a2 amount
	jr $v1			# Returns back to the thread that called it

###################################
## Procedure 	binToDec	This function will return the decimal representation of a bit string
## Author: Naman Gangwani
## $a0	I/P	string		This will be the bit string passed through the function
## $a1	I/P	int		This value will be the length of the bit string passed through the function
## $v0	O/P	int		This value will be the decimal representation of the bit string
###################################
binToDec:
	move $t0, $a1		# Saves length into a temporary register
	addi $v0, $zero, 0	# Total = 0
	addi $a0, $a0, 32	# Start at the LSB of the bit string
parse:
	addi $t0, $t0, -1	# Decrease length and parsed gap by 1
	addi $a0, $a0, -1	# Subtracts one to get to the next string index (moving towards MSB)
	lb $t1, 0($a0)		# Retrieves the byte at the index position
	beqz $t1, returnDec	# If it has read the entire string, return
	
	addi $t1, $t1, -48	# Subtracts 48 from the ASCII value to retrieve actual number for arithmetic
	
	sub $t2, $a1, $t0	# Subtracts from total length to get index position
	addi $t2, $t2, -1	# Subtracts one more to get accurate index position (which starts with 0)
	
	addi $t3, $zero, 1	# Multiplier = 1 initially
	sllv $t3, $t3, $t2	# Get the multiplier at the specific bit
	mul $t1, $t1, $t3	# Multiply the value at the bit by the multiplier
	add $v0, $v0, $t1	# Add to decimal representation
	
	j parse			# Continue parsing more bits
returnDec:
	jr $ra			# Returns back to the thread that called it
	
###################################
## Procedure 	strlen		This function will return the length of an inputted string
## Author: Naman Gangwani
## $a0	I/P	string		This value will be string passed through the function
## $v0	O/P	int		This value will be the length of the string passed through as an argument
###################################
strlen: 
	li $v0, 0 		# Initialize the counter to zero
loop:	
	lb $t0, 0($a0) 		# Load the next character into t1
	beqz $t0, returnLen 	# Check for the null character
	addi $a0, $a0, 1 	# Increment the string pointer
	addi $v0, $v0, 1 	# Increment the counter
	j loop 			# Return to the top of the loop
returnLen:	
	jr $ra			# Returns back to the thread that called it

###################################
## Procedure 	printString	This function will print a specified string
## Author: Naman Gangwani
## $a0	I/P	string		This value will be the string passed through the function
## 	O/P	string		This value will be $a0 printed to the output
###################################
printString:
	li $v0, 4		# System call code for print_string
	syscall			# Prints the string based on system call code
	jr $ra			# Returns back to the thread that called it

###################################
## Procedure 	printInt	This function will print a specified integer
## Author: Naman Gangwani
## $a0	I/P	int		This value will be the integer passed through the function
## 	O/P	string		This value will be $a0 printed to the output
###################################
printInt:
	li $v0, 1		# System call code for print_int
	syscall			# Prints the string based on system call code
	jr $ra			# Returns back to the thread that called it
