# File Name: Project.asm
# Author: Naman Gangwani
# Procedures	readLine	This will read all lines in the file and decode their instructions
#		binToDec	This function will return the decimal representation of a bit string
#		strlen		This function will return the length of an inputted string
#		printString	This function will print a specified string
#		printInt	This function will print a specified integer
	.data
file: 	.space 	1024		# For storing the filename
line:	.space 	1024		# For storing the contents of the line
prompt:	.asciiz "What file contains your information? "
				# Prompting user for visual represnetation in the output
invalid:.asciiz "Invalid: "	# To identify out invalid instruction types in the ouput
opcode:	.asciiz "opcode: "	# To indicate the opcodes of invalids
funct:	.asciiz "funct: "	# To indicate the functs of invalids
newLine:.asciiz "\n"		# For moving on to the next line in the output
comma:	.asciiz ","		# To print out commas in the output
dot:	.asciiz "."		# To print out the .s after the FI types
s:	.asciiz	"s"		# To signify single point precision of FR types
d:	.asciiz	"d"		# To signify double point precision of FR types
w:	.asciiz	"w"		# To signify words of FR types
l:	.asciiz	"    l::"	# To signify labels in the output
open:	.asciiz "("		# To show an open parenthesis for FI types
close:	.asciiz ")"		# To show a close parenthesis for FI types
indent:	.asciiz	"    "		# To make indentations for a cleaner looking output
empty:	.asciiz "       "	# For checking to see if an opcode is invalid in the table
				# Contains all the instructions corresponding to the opcodes
column0:.asciiz	"       ", "       ", "      j", "    jal", "    beq", "    bne", "   blez", "   bgtz",
		"   addi", "  addiu", "   slti", "  sltiu", "   andi", "    ori", "   xori", "    lui",
		"       ", "       ", "       ", "       ", "       ", "       ", "       ", "       ",
		"       ", "       ", "       ", "       ", "       ", "       ", "       ", "       ",
		"     lb", "     lh", "    lwl", "     lw", "    lbu", "    lhu", "    lwr", "       ",
		"     sb", "     sh", "    swl", "     sw", "       ", "       ", "    swr", "  cache",
		"     ll", "   lwc1", "   lwc2", "   pref", "       ", "   ldc1", "   ldc2", "       ",
		"     sc", "   swc1", "   swc2", "       ", "       ", "   sdc1", "   sdc2", "       "
				# Contains all the instructions corresponding to the function codes of R-types
column1:.asciiz "    sll", "       ", "    srl", "    sra", "       ", "   sllv", "   srlv", "   srav",
		"     jr", "   jalr", "   movz", "   movn", "syscall", "  break", "       ", "   sync",
		"   mfhi", "   mthi", "   mflo", "   mtlo", "       ", "       ", "       ", "       ",
		"   mult", "  multu", "    div", "   divu", "       ", "       ", "       ", "       ",
		"    add", "   addu", "    sub", "   subu", "    and", "     or", "    xor", "    nor",
		"       ", "       ", "    slt", "   sltu", "       ", "       ", "       ", "       ",
		"    tge", "   tgeu", "    tlt", "   tltu", "    teq", "       ", "    tne", "       ",
		"       ", "       ", "       ", "       ", "       ", "       ", "       ", "       "
				# Contains all the instructions corresponding to the function codes of FR-types
column2:.asciiz "    add", "    sub", "    mul", "    div", "   sqrt", "    abs", "    mov", "    neg",
		"       ", "       ", "       ", "       ", "round.w", "trunc.w", "ceil.w ", "floor.w",
		"       ", "       ", "   movz", "   movn", "       ", "       ", "       ", "       ",
		"       ", "       ", "       ", "       ", "       ", "       ", "       ", "       ",
		"  cvt.s", "  cvt.d", "       ", "       ", "  cvt.w", "       ", "       ", "       ",
		"       ", "       ", "       ", "       ", "       ", "       ", "       ", "       ",
		"    c.f", "   c.un", "   c.eq", "  c.ueq", "  c.olt", "  c.ult", "  c.ole", "  c.ule",
		"   c.sf", " c.nlge", "  c.seq", "  c.ngl", "   c.lt", "  c.nge", "   c.le", "  c.ngt"
				# Contains all the registers corresponding to their numbers
reg:	.asciiz "  $zero", "    $at", "    $v0", "    $v1", "    $a0", "    $a1", "    $a2", "    $a3",
		"    $t0", "    $t1", "    $t2", "    $t3", "    $t4", "    $t5", "    $t6", "    $t7",
		"    $s0", "    $s1", "    $s2", "    $s3", "    $s4", "    $s5", "    $s6", "    $s7",
		"    $t8", "    $t9", "    $k0", "    $k1", "    $gp", "    $sp", "    $fp", "    $ra"
				# Contains all the coprocessor registers corresponding to their numbers
coproc:	.asciiz "    $f0", "    $f1", "    $f2", "    $f3", "    $f4", "    $f5", "    $f6", "    $f7",
		"    $f8", "    $f9", "   $f10", "   $f11", "   $f12", "   $f13", "   $f14", "   $f15",
		"   $f16", "   $f17", "   $f18", "   $f19", "   $f20", "   $f21", "   $f22", "   $f23",
		"   $f24", "   $f25", "   $f26", "   $f27", "   $f28", "   $f29", "   $f30", "   $f31"
	.text
	li $v0, 4		# System call code for print_string
  	la $a0, prompt		# Puts the new line character into the register for the first argument
  	syscall			# Prints the string based on system call code
  	
	li $v0, 8		# System call code for read_string
	la $a0, file		# Will be stored in the space allocated by buffer
	li $a1, 199		# Maximum number of characters is 199
	syscall			# Takes in a string from the user
	
	jal strlen		# Gets the length of the inputted string
  	
  	addi $v0, $v0, -1	# Subtracts 1 to get position of the last index of the string
	sb $0, file($v0)	# Changes last character (nl) to a null character
	la $a0, file		# Updates the first argument to the adjusted string
  	
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
	jal binToDec		# Converts the bit string just read to decimal
	move $t8, $v0		# Saves the content of the lines for later interpretation
	srl $v0, $v0, 26	# Shifts it right by 26 to retrieve the opcode
	move $t6, $v0		# Saves the opcode later for printing for invalid if necessary
	
	beqz $v0, readRType	# Reads the rest of the line as an R-type if opcode = 0
	beq $v0, 2, readJType	# Reads the rest of the line as a J-type if opcode = 2
	beq $v0, 3, readJType	# Reads the rest of the line as a J-type if opcode = 3	
	beq $v0, 17, readFRType	# Reads the rest of the line as an FR-type if opcode = 17
	
	sll $t3, $v0, 3		# Multiplies opcode by 8 to get its index in the opcode table
	la $t0, column0($t3)	# Retrieves opcode's string representation from the table
	la $t1, empty		# Loads empty string for comparison
	beq $t0, $t1, default	# If it is empty, it is invalid
	
	beq $v0, 49, readFIType	# Reads the rest of the line as an FI-type if opcode = 49
	beq $v0, 50, readFIType	# Reads the rest of the line as an FI-type if opcode = 50
	beq $v0, 53, readFIType	# Reads the rest of the line as an FI-type if opcode = 53
	beq $v0, 54, readFIType	# Reads the rest of the line as an FI-type if opcode = 54
	beq $v0, 57, readFIType	# Reads the rest of the line as an FI-type if opcode = 57
	beq $v0, 58, readFIType	# Reads the rest of the line as an FI-type if opcode = 58
	beq $v0, 61, readFIType	# Reads the rest of the line as an FI-type if opcode = 61
	beq $v0, 62, readFIType	# Reads the rest of the line as an FI-type if opcode = 62
	
	j readIType		# Rest of the uncovered ones are I-types
default:
	la $a0, invalid		# Puts invalid string in the $a0 register
	jal printString		# Prints invalid
	
	beqz $v0, printFunct	# Print function code instead if it is an R-Type
	beq $v0, 17, printFunct	# Print function code instead if it is an FR-type
	la $a0, opcode		# Load opcode
	j printType		# Print opcode
	printFunct:
		la $a0, funct	# Print funct
	printType:
		jal printString		# Prints string in the $a0 register
	move $a0, $t6		# Stores opcode or funct in first argument
	jal printInt		# Prints %d for opcode or funct
	
	j continue		# Move on to the next line
readRType:
	# rs
	sll $t2, $t8, 6		# Mask first 6 bits to 0
	srl $t2, $t2, 27	# Get rid of extra 27 bits at the end
	# rt
	sll $t3, $t8, 11	# Mask first 11 bits to 0
	srl $t3, $t3, 27	# Get rid of extra 27 bits at the end
	# rd
	sll $t4, $t8, 16	# Mask first 16 bits to 0
	srl $t4, $t4, 27	# Get rid of extra 27 bits at the end
	# shamt
	sll $t5, $t8, 21	# Mask first 21 bits to 0
	srl $t5, $t5, 27	# Get rid of extra 27 bits at the end
	# funct
	sll $t6, $t8, 26	# Mask first 26 bits to 0
	srl $t6, $t6, 26	# Get rid of extra 26 bits at the end

	sll $t0, $t6, 3		# Multiplies function code by 8 to retrieve its index position in the function code table
	la $t1, column1($t0)	# Retrieves the string representation of the function code
	la $t0, empty		# Loads empty string for comparison
	beq $t0, $t1, default	# If it is empty in the table, it is invalid
	move $a0, $t1		# Store it into the first argument
	jal printString		# Print the string representation of the function code
	
	beq $t6, 12, continue	# If it is syscall, it is done
	beq $t6, 13, continue	# If it is break, it is done
	beq $t6, 15, continue	# If it is sync, it is done
	
	beq $t6, 26, divOrTrap	# If it is div, treat it specially
	beq $t6, 26, divOrTrap	# If it is div, treat it specially
	
	beq $t6, 0, shiftType1	# If it is sll, treat it specially
	beq $t6, 2, shiftType1	# If it is srl, treat it specially
	beq $t6, 3, shiftType1	# If it is sra, treat it specially
	
	beq $t6, 4, shiftType2	# If it is sllv, treat it specially
	beq $t6, 6, shiftType2	# If it is srlv, treat it specially
	beq $t6, 7, shiftType2	# If it is srav, treat it specially
	
	beq $t6, 26, divOrTrap	# If it is div, treat it specially
	beq $t6, 27, divOrTrap	# If it is divu, treat it specially
	beq $t6, 52, divOrTrap	# If it is teq, treat it specially
	beq $t6, 54, divOrTrap	# If it is tne, treat it specially
	beq $t6, 48, divOrTrap	# If it is tge, treat it specially
	beq $t6, 49, divOrTrap	# If it is tgeu, treat it specially
	beq $t6, 50, divOrTrap	# If it is tlt, treat it specially
	beq $t6, 51, divOrTrap	# If it is tltu, treat it specially
	
	beq $t6, 9, jalrType	# If it is jalr, treat it specially
	
	beq $t6, 16, mfType	# If it is mfhi, treat it specially
	beq $t6, 18, mfType	# If it is mflo, treat it specially
	
	beq $t6, 8, jrOrMt	# If it is jr, treat it specially
	beq $t6, 17, jrOrMt	# If it is mthi, treat it specially
	beq $t6, 19, jrOrMt	# If it is mtlo, treat it specially
	
	defaultRType:
		sll $t4, $t4, 3		# Multiplies rd by 8 to retrieve its index position in the register table
		la $a0, reg($t4)	# Saves rd into first argument register
		jal printString		# Prints rd
		la $a0, comma		# Saves comma into first argument register
		jal printString		# Prints comma
		
		sll $t2, $t2, 3		# Multiplies rs by 8 to retrieve its index position in the register table
		la $a0, reg($t2)	# Saves rs into first argument register
		jal printString		# Prints rs
		la $a0, comma		# Saves comma into first argument register
		jal printString		# Prints comma
		
		sll $t3, $t3, 3		# Multiplies rt by 8 to retrieve its index position in the register table
		la $a0, reg($t3)	# Saves rt into first argument register
		jal printString		# Prints rt
		
		j continue		# Move on to the next line
	shiftType1:
		sll $t4, $t4, 3		# Multiplies rd by 8 to retrieve its index position in the register table
		la $a0, reg($t4)	# Saves rd into first argument register
		jal printString		# Prints rd
		la $a0, comma		# Saves comma into first argument register
		jal printString		# Prints comma
		
		sll $t3, $t3, 3		# Multiplies rt by 8 to retrieve its index position in the register table
		la $a0, reg($t3)	# Saves rt into first argument register
		jal printString		# Prints rt
		
		move $a0, $t5		# Saves the shamt into the first argument register
		jal printInt		# Prints shamt
		
		j continue		# Move on to the next line
	shiftType2:
		sll $t4, $t4, 3		# Multiplies rd by 8 to retrieve its index position in the register table
		la $a0, reg($t4)	# Saves rd into first argument register
		jal printString		# Prints rd
		la $a0, comma		# Saves comma into first argument register
		jal printString		# Prints comma
		
		sll $t3, $t3, 3		# Multiplies rt by 8 to retrieve its index position in the register table
		la $a0, reg($t3)	# Saves rt into first argument register
		jal printString		# Prints rt
		la $a0, comma		# Saves comma into first argument register
		jal printString		# Prints comma
		
		sll $t2, $t2, 3		# Multiplies rs by 8 to retrieve its index position in the register table
		la $a0, reg($t2)	# Saves rs into first argument register
		jal printString		# Prints rs
		
		j continue		# Move on to the next line
	divOrTrap:
		sll $t2, $t2, 3		# Multiplies rs by 8 to retrieve its index position in the register table
		la $a0, reg($t2)	# Saves rs into first argument register
		jal printString		# Prints rs
		la $a0, comma		# Saves comma into first argument register
		jal printString		# Prints comma
		
		sll $t3, $t3, 3		# Multiplies rt by 8 to retrieve its index position in the register table
		la $a0, reg($t3)	# Saves rt into first argument register
		jal printString		# Prints rt

		j continue		# Move on to the next line
	jalrType:
		sll $t2, $t2, 3		# Multiplies rs by 8 to retrieve its index position in the register table
		la $a0, reg($t2)	# Saves rs into first argument register
		jal printString		# Prints rs
		la $a0, comma		# Saves comma into first argument register
		jal printString		# Prints comma
		
		sll $t4, $t4, 3		# Multiplies rd by 8 to retrieve its index position in the register table
		la $a0, reg($t4)	# Saves rd into first argument register
		jal printString		# Prints rd
		la $a0, comma		# Saves comma into first argument register
		jal printString		# Prints comma
		
		j continue		# Move on to the next line
	mfType:
		sll $t4, $t4, 3		# Multiplies rd by 8 to retrieve its index position in the register table
		la $a0, reg($t4)	# Saves rd into first argument register
		jal printString		# Prints rd
		
		j continue		# Move on to the next line
	jrOrMt:
		sll $t2, $t2, 3		# Multiplies rs by 8 to retrieve its index position in the register table
		la $a0, reg($t2)	# Saves rs into first argument register
		jal printString		# Prints rs
		
		j continue		# Move on to the next line
readIType:
	# rs
	sll $t2, $t8, 6		# Mask first 6 bits to 0
	srl $t2, $t2, 27	# Get rid of extra 27 bits at the end
	# rt
	sll $t3, $t8, 11	# Mask first 11 bits to 0
	srl $t3, $t3, 27	# Get rid of extra 27 bits at the end
	# imm
	sll $t4, $t8, 16	# Mask first 16 bits to 0
	sra $t4, $t4, 16	# Get rid of extra 16 bits at the end
	
	sll $t0, $t6, 3		# Multiplies opcode by 8 to retrieve its index position in the function code table
	la $t1, column0($t0)	# Retrieves the string representation of the function code
	la $t0, empty		# Loads empty string for comparison
	beq $t0, $t1, default	# If it is empty in the table, it is invalid
	move $a0, $t1		# Store it into the first argument
	jal printString		# Print the string representation of the function code
	
	beq $t6, 47, continue	# If it is cache, it is done
	
	beq $t6, 4, branchType1	# If it is beq, treat it specially
	beq $t6, 5, branchType1	# If it is bne, treat it specially
	
	beq $t6, 6, branchType2	# If it is blez, treat it specially
	beq $t6, 7, branchType2	# If it is bgtz, treat it specially
	
	beq $t6, 15, loadOrStore# If it is lui, treat it specially
	beq $t6, 32, loadOrStore# If it is lb, treat it specially
	beq $t6, 33, loadOrStore# If it is lh, treat it specially
	beq $t6, 34, loadOrStore# If it is lwl, treat it specially
	beq $t6, 35, loadOrStore# If it is lw, treat it specially
	beq $t6, 36, loadOrStore# If it is lbu, treat it specially
	beq $t6, 37, loadOrStore# If it is lhu, treat it specially
	beq $t6, 38, loadOrStore# If it is lwr, treat it specially
	beq $t6, 48, loadOrStore# If it is ll, treat it specially
	beq $t6, 40, loadOrStore# If it is sb, treat it specially
	beq $t6, 41, loadOrStore# If it is sh, treat it specially
	beq $t6, 42, loadOrStore# If it is swl, treat it specially
	beq $t6, 43, loadOrStore# If it is sw, treat it specially
	beq $t6, 46, loadOrStore# If it is swr, treat it specially
	beq $t6, 56, loadOrStore# If it is sc, treat it specially
	
	defaultIType:
		sll $t3, $t3, 3		# Multiplies rt by 8 to retrieve its index position in the register table
		la $a0, reg($t3)	# Saves rt into first argument register
		jal printString		# Prints rt
		la $a0, comma		# Saves comma into first argument register
		jal printString		# Prints comma
		
		sll $t2, $t2, 3		# Multiplies rs by 8 to retrieve its index position in the register table
		la $a0, reg($t2)	# Saves rs into first argument register
		jal printString		# Prints rs
		la $a0, comma		# Saves comma into first argument register
		jal printString		# Prints comma
		
		la $a0, indent		# Saves indent into first argument to signify a label is being printed
		jal printString		# Prints indent
		move $a0, $t4		# Saves imm into the first argument register
		jal printInt		# Prints imm
		
		j continue		# Move on to the next line
	branchType1:
		sll $t2, $t2, 3		# Multiplies rs by 8 to retrieve its index position in the register table
		la $a0, reg($t2)	# Saves rs into first argument register
		jal printString		# Prints rs
		la $a0, comma		# Saves comma into first argument register
		jal printString		# Prints comma
	
		sll $t3, $t3, 3		# Multiplies rt by 8 to retrieve its index position in the register table
		la $a0, reg($t3)	# Saves rt into first argument register
		jal printString		# Prints rt
		
		la $a0, l		# Saves l into first argument to signify a label is being printed
		jal printString		# Prints l
		sll $a0, $t8, 16	# Mask first 16 bits to 0
		srl $a0, $a0, 16	# Get rid of extra 16 bits at the end
		jal printInt		# Prints imm
		
		j continue		# Move on to the next line
	branchType2:
		sll $t2, $t2, 3		# Multiplies rs by 8 to retrieve its index position in the register table
		la $a0, reg($t2)	# Saves rs into first argument register
		jal printString		# Prints rs
		la $a0, comma		# Saves comma into first argument register
		jal printString		# Prints comma
		
		la $a0, l		# Saves l into first argument to signify a label is being printed
		jal printString		# Prints l
		sll $a0, $t8, 16	# Mask first 16 bits to 0
		srl $a0, $a0, 16	# Get rid of extra 16 bits at the end
		jal printInt		# Prints imm
		
		j continue		# Move on to the next line
	loadOrStore:
		sll $t3, $t3, 3		# Multiplies rt by 8 to retrieve its index position in the register table
		la $a0, reg($t3)	# Saves rt into first argument register
		jal printString		# Prints rt
		la $a0, comma		# Saves comma into first argument register
		jal printString		# Prints comma
		
		la $a0, indent		# Saves indent into first argument
		jal printString		# Prints indent
		move $a0, $t4		# Saves imm into the first argument register
		jal printInt		# Prints imm
		
		beq $t6, 15, continue	# If it is lui, it does not need the rs register
		
		la $a0, open		# Saves open parenthesis into first argument to signify a label is being printed
		jal printString		# Prints open parenthesis
		
		sll $t3, $t2, 3		# Multiplies rs by 8 to retrieve its index position in the register table
		la $a0, reg($t3)	# Saves rs into first argument register
		jal printString		# Prints rs
		
		la $a0, indent		# Saves indent into first argument
		jal printString		# Prints indent
		la $a0, close		# Saves close parenthesis into first argument to signify a label is being printed
		jal printString		# Prints close parenthesis
	
		j continue		# Move on to the next line
readJType:
	sll $t1, $t6, 3		# Multiplies opcode by 8 to retrieve its index position in the opcode table
	la $a0, column0($t1)	# Saves j/jal into the first argument register
	jal printString		# Prints j/jal
	
	la $a0, l		# Saves l into first argument to signify a label is being printed
	jal printString		# Prints l
	
	# address
	sll $a0, $t8, 6		# Mask first 6 bits to 0
	srl $a0, $a0, 6		# Get rid of extra 6 bits at the end
	jal printInt		# Prints the target address
	
	j continue		# Move on to the next line
readFRType:
	# fmt
	sll $t2, $t8, 6		# Mask first 6 bits to 0
	srl $t2, $t2, 27	# Get rid of extra 27 bits at the end
	# ft
	sll $t3, $t8, 11	# Mask first 11 bits to 0
	srl $t3, $t3, 27	# Get rid of extra 27 bits at the end
	# fs
	sll $t4, $t8, 16	# Mask first 16 bits to 0
	srl $t4, $t4, 27	# Get rid of extra 27 bits at the end
	# fd
	sll $t5, $t8, 21	# Mask first 21 bits to 0
	srl $t5, $t5, 27	# Get rid of extra 27 bits at the end
	# funct
	sll $t6, $t8, 26	# Mask first 26 bits to 0
	srl $t6, $t6, 26	# Get rid of extra 26 bits at the end

	sll $t0, $t6, 3		# Multiplies function code by 8 to retrieve its index position in the function code table
	la $t1, column2($t0)	# Retrieves the string representation of the function code
	la $t0, empty		# Loads empty string for comparison
	beq $t0, $t1, default	# If it is empty in the table, it is invalid
	move $a0, $t1		# Store it into the first argument
	jal printString		# Print the string representation of the function code
	
	la $a0, dot		# Saves dot into first argument to signify a label is being printed
	jal printString		# Prints dot
	
	la $a0, d		# Saves s into first argument
	beq $t2, 16, changeToD	# If fmt is 1, it is double precision
	beq $t2, 20, changeToW	# If it is 20, it is w
	j printPrecision	# Otherwise, just print s
	changeToD:
		la $a0, d		# Saves d into first argument
		j printPrecision	# Print d
	changeToW:
		la $a0, w		# Saves d into first argument
	printPrecision:
		jal printString	# Prints d, s, or w
	
	beqz $t6, fdFsFt	# If it is add, treat it specially
	beq $t6, 1, fdFsFt	# If it is sub, treat it specially
	beq $t6, 2, fdFsFt	# If it is mul, treat it specially
	beq $t6, 3, fdFsFt	# If it is div, treat it specially
	
	beq $t6, 50, ccFsFt	# If it is c.eq, treat it specially
	beq $t6, 60, ccFsFt	# If it is c.lt, treat it specially
	beq $t6, 62, ccFsFt	# If it is c.le, treat it specially
	
	beq $t6, 18, fdFsRt	# If it is movz, treat it specially
	beq $t6, 19, fdFsRt	# If it is movn, treat it specially
	
	fdFs:
		sll $t5, $t5, 3		# Multiplies fd by 8 to retrieve its index position in the register table
		la $a0, coproc($t5)	# Saves fd into first argument register
		jal printString		# Prints fd
		la $a0, comma		# Saves comma into first argument register
		jal printString		# Prints comma
		
		sll $t4, $t4, 3		# Multiplies fs by 8 to retrieve its index position in the register table
		la $a0, coproc($t4)	# Saves fs into first argument register
		jal printString		# Prints fs
		
		j continue		# Move on to the next line
	fdFsFt:
		sll $t5, $t5, 3		# Multiplies fd by 8 to retrieve its index position in the register table
		la $a0, coproc($t5)	# Saves fd into first argument register
		jal printString		# Prints fd
		la $a0, comma		# Saves comma into first argument register
		jal printString		# Prints comma
		
		sll $t4, $t4, 3		# Multiplies fs by 8 to retrieve its index position in the register table
		la $a0, coproc($t4)	# Saves fs into first argument register
		jal printString		# Prints fs
		la $a0, comma		# Saves comma into first argument register
		jal printString		# Prints comma
		
		sll $t3, $t3, 3		# Multiplies ft by 8 to retrieve its index position in the register table
		la $a0, coproc($t3)	# Saves ft into first argument register
		jal printString		# Prints ft
		
		j continue		# Move on to the next line
	ccFsFt:
		# cc
		sll $t6, $t8, 21	# Mask first 26 bits to 0
		srl $t6, $t6, 29	# Get rid of extra 29 bits at the end
		
		beq $t6, 1, printCC	# If cc is 1, print it
		j moveOn		# Otherwise, don't print cc and move on
		printCC:
			la $a0, comma		# Saves indent into first argument register
			jal printString		# Prints indent
			move $a0, $t6		# Loads cc into the first argument register
			jal printString		# Prints cc
			la $a0, comma		# Saves comma into first argument register
			jal printString		# Prints comma
		moveOn:
			sll $t4, $t4, 3		# Multiplies fs by 8 to retrieve its index position in the register table
			la $a0, coproc($t4)	# Saves fs into first argument register
			jal printString		# Prints fs
			la $a0, comma		# Saves comma into first argument register
			jal printString		# Prints comma
		
			sll $t3, $t3, 3		# Multiplies ft by 8 to retrieve its index position in the register table
			la $a0, coproc($t3)	# Saves ft into first argument register
			jal printString		# Prints ft
		
		j continue		# Move on to the next line
	fdFsRt:
		sll $t5, $t5, 3		# Multiplies fd by 8 to retrieve its index position in the register table
		la $a0, coproc($t5)	# Saves fd into first argument register
		jal printString		# Prints fd
		la $a0, comma		# Saves comma into first argument register
		jal printString		# Prints comma
		
		sll $t4, $t4, 3		# Multiplies fs by 8 to retrieve its index position in the register table
		la $a0, coproc($t4)	# Saves fs into first argument register
		jal printString		# Prints fs
		la $a0, comma		# Saves comma into first argument register
		jal printString		# Prints comma
		
		sll $t3, $t3, 3		# Multiplies rt by 8 to retrieve its index position in the register table
		la $a0, reg($t3)	# Saves rt into first argument register
		jal printString		# Prints rt
		
		j continue		# Move on to the next line
readFIType:
	sll $t1, $t6, 3		# Multiplies opcode by 8 to retrieve its index position in the opcode table
	la $a0, column0($t1)	# Saves the opcode string into the first argument register
	jal printString		# Prints the opcode string
	
	# ft
	sll $t3, $t8, 11	# Mask first 11 bits to 0
	srl $t3, $t3, 27	# Get rid of extra 27 bits at the end
	sll $t1, $t3, 3		# Multiplies ft by 8 to get its index position in the coproc table
	la $a0, coproc($t1)	# Retrieves its $f value from the coproc table
	jal printString		# Prints the $f value
	# offset
	sll $a0, $t8, 16	# Mask first 11 bits to 0
	sra $a0, $a0, 16	# Get rid of extra 27 bits at the end
	jal printInt		# Prints the offset
	
	la $a0, open		# Saves open parenthesis into first argument to signify a label is being printed
	jal printString		# Prints open parenthesis
	
	# base
	sll $t2, $t8, 6		# Mask first 6 bits to 0
	srl $t2, $t2, 27	# Get rid of extra 27 bits at the end
	sll $t1, $t3, 3		# Retrieves its $t value from the coproc table
	la $a0, reg($t1)	# Retrieves its $f value from the coproc table
	jal printInt		# Prints the offset
	
	la $a0, indent		# Saves indent into first argument to signify a label is being printed
	jal printString		# Prints indent parenthesis
	la $a0, close		# Saves close parenthesis into first argument to signify a label is being printed
	jal printString		# Prints close parenthesis
	
	j continue		# Move on to the next line
continue:
	la $a0, newLine		# Print new line
	jal printString		# Prints string in the $a0 register
	
	j readLine		# Read the next line
exit:
	li $v0, 10		# System call code for exit
	syscall			# Exits the program based on system call code

###################################
## Procedure 	binToDec	This function will return the decimal representation of a bit string
## Author: Naman Gangwani
## $a0	I/P	string		This will be the bit string passed through the function
## $v0	O/P	int		This value will be the decimal representation of the bit string
###################################
binToDec:
	li $a1, 32
	li $t0, 32		# Saves length into a temporary register
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
	sub $a0, $a0, 32	# Changes its position in the address to its beginning
	jr $ra			# Returns back to the caller

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
	jr $ra			# Returns back to the caller

###################################
## Procedure 	printString	This function will print a specified string
## Author: Naman Gangwani
## $a0	I/P	string		This value will be the string passed through the function
## 	O/P	string		This value will be $a0 printed to the output
###################################
printString:
	li $v0, 4		# System call code for print_string
	syscall			# Prints the string based on system call code
	jr $ra			# Returns back to the caller

###################################
## Procedure 	printInt	This function will print a specified integer
## Author: Naman Gangwani
## $a0	I/P	int		This value will be the integer passed through the function
## 	O/P	string		This value will be $a0 printed to the output
###################################
printInt:
	li $v0, 1		# System call code for print_int
	syscall			# Prints the string based on system call code
	jr $ra			# Returns back to the caller
	