;---------------------------------------------------------------------------------------------------------------------------------
;																												  				 |	
;										This is x64 NASM assembly language														 |
;							               																						 |
;										Using the Linux Ubuntu terminal															 |
;											   																				     |
;										I was able to compile and run my assembly code											 |
;		      																													 |
;										To be able to run this code you will need to run it on a linux machine					 |
;																																 |
;										The following commands were used to link and compile the code seen below				 |			
;																																 |	
;										Command 1: nasm -f elf64 test.asm -o ILASM.o (this says what bit version this    		 |
;                                       program is, what OS and what file the code is in. This also says what file type  		 |
;										to make with the name for the file												 		 |
;																														         |		  
;										Command 2: ld TEST.o -o PROGRAM This is what compiles the code, PROGRAM is just  		 |
;										the name for the linux executeable                                                 		 |
;																																 |
;																																 |
;---------------------------------------------------------------------------------------------------------------------------------


section .data																		;Section data holds all our pre initialsed data. db means declare bytes
	hello db "Hello, " ;8															;the part befor db is a label, a label is just a section of the program that the compiler changes into a memory location
	WIYN db "What is your name?", 10 ; 28											;this means that stuff like hello is just a pointer to a memory address. 
	dig db 0, 10																	;the 10 at the end of these lines of code just means new line which is like enter on the keyboard
	morethnF db "Your name has more than five characters! ", 10
	lessthnF db "Your name has less than five characters! ", 10 ;43

														;The comments that are numbers next to the decalred bytes is how many bytes the string has, I did this so I dont print more than the string to the console



section .bss											;Section .bss is a part of our program that reserves memory. The labels are for unitialsed memory. 
												
	name resb 16										;resb means reserved bytes, this is how many bytes we reserve for our area in memory, the number after is the amount after resb
	len resb 2
	

section .text											;Section text is the part of our program that holds all the program code, this is what is executed/executeable
	global _start										;The CPU needs to find the start of the program to start executing the program properly, NASM uses _start to identify this and that is why we use it. Its like int main(){}


_start:


	;call _PrintName									;This is a subroutine I commented out because I was using it for learning

	call _GetName										;This calls the _GetName subroutine which I wrot

	mov rax, name         							    ;This moves the data from the memory location "name" and puts it into the rax register
	xor rcx, rcx										;init rcx register as 0 (XOR rcx: a rcx: B | By xor logic this returns 0 so rcx is 0)

	call _getLen										;This calls the _getLen subroutine


	mov rax, 60											;Moving the value 60 into rax, this is because the linux system call looks for a specifc order of registers, their number in them determines what happens
	mov rdi, 0											;60 for rax means exit, 0 for rdi means no error
	syscall												;This gives control back to the kernal



_getLen:

	mov dl, byte [rax+rcx] 							    ;loads a single byte of rcx and rax into a single register
	inc rcx												;inc increments the register. rcx is the register i am using for iterating over rax, which holds name (each iteration over rax returns the data in the byte)
	cmp dl, 0											;we see if the current byte we are iterating over is equal to 0											
	jne _getLen											;If the byte is not 0, jump back to the start of subroutine
	je _loopEnd											
	syscall
	ret 												;ret returns the program to the part where the subroutine was called by the line after 
	
;Labels can also be used to name subroutines, for instance _mtF is our subroutine that prints a string
_mtF:		

	;To understand this subroutine, I will explain what syscall actually does. Syscall requests a service from the kernal. syscall looks for 
	;registers in a specific order, the data in that register says what operation does. 
	;To get a whole list of the linux system calls go to https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md

	mov rax, 1 											;this means to write
	mov rdi, 1 										    ;this means to write to the console
	mov rsi, morethnF									;this is the data that we are writing the console, it is just the memory location of the data
	mov rdx, 43											;this is the length in bytes of the string, this tells the compiler to stop looking for data after that many bytes so we arent getting random data
	syscall
	ret

_ltF:

	mov rax, 1
	mov rdi, 1											;This subroutine is the same as the one above except for the data printed to the console
	mov rsi, lessthnF
	mov rdx, 43
	syscall
	ret


_loopEnd:

	mov [len], rcx										;sqaure brackets around a memory location means the data at the memory location and not the address itself. this data is being moved into the rcx register
	cmp rcx, 5											;we compare the binary value at the index of the character, rcx is now our index. this is because we added rax and rcx together and we moved name into rax
	jl _ltF												;if rcx is less than 5 jump to _ltF subroutine				
	ja _mtF												;if rcx is more than 5 jump to _mtF subroutine
	syscall 
	ret

_GetName:
	call _what											;This calls the _what subroutine, all the code in _what is ran before the rest of _GetName is ran
	mov rax, 0											;0 in rax here means to take input
	mov rdi, 0											;0 in rdi here means to take input from the console
	mov rsi, name      									;we move the input from the console into the memory location "name"
	mov rdx, 16						
	syscall
	ret

_what:

	mov rax, 1
	mov rdi, 1
	mov rsi, WIYN										;this prints the WIYN data
	mov rdx, 20
	syscall
	ret


_PrintName:
	call _GetName

	mov rax, 1
	mov rdi, 1									;This section of the code takes the users name from input and then prints "Hello, "
	mov rsi, hello
	mov rdx, 7
	syscall


	mov rax, 1
	mov rdi, 1
	mov rsi, name     							;This section of the code prints the input from the user
	mov rdx, 16
	syscall 									;This results in "Hello, <input>"
	ret


_printDIG:										;This subroutine is irrelevant to the program but i will explain it anyway
												;To get an ASCII character, in _start you would do mov, and then the number of a character on the ASCII table
	add rax, 48									;To get the character we add 48 onto it because 0 on the ASCII table is 48. So if you move 7 into rax before this subtroutine it will print 7

	mov [dig], al 								;We move the lower end of the rax register (al) into the dig memory location, the reason for this is because dig already has data so we only edit the first bit with the number and the last part stays as the new line character		

	mov rax, 1
	mov rdi, 1
	mov rsi, dig
	mov rdx, 2
	syscall
	ret