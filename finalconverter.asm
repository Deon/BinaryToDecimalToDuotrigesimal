; By: Deon Hua
; Date: 17 November 2013
; Description: A program that converts from binary to decimal.

	org 100h

section .text

;Start of program
start:
	jmp print_prep	;Jump to next label to prepare to print a prompt.

;Prepares to print the prompt.
print_prep:
	mov bx, prompt	;Point BX at the variable prompt
	sub cx, cx		;Set CX to 0
	jmp print		;Jump to the next label to print the prompt
	
;Displays prompt to enter 10-digit binary number.
print:
	mov dl, [bx]		;Move BX to DL
	inc bx				;Point BX at the next value
	cmp dl, 0			;Compare DL to 0
	je take_input_prep	;If it is 0, jump to the next label.
	mov ah, 02h			;Move service number 02h to AH
	int 21h				;Call interrupt 21h
	jmp print			;Jump back to the beginning of the label.

;Prepares to take input.
take_input_prep:
	mov bx, input		;Point BX at input
	jmp take_input		;Jump to next label to take input.
	
;Take input from the user.
take_input:
	mov ah, 00h 		;Service number
	int 16h 			;Take input from user
	inc cx				;CX acts as a counter for input to determine the number of characters.
	
	;Displays input LIVE
	mov dl, al  ;Move to DL to display entered character
	mov ah, 06h ;Service number to display
	int 21h     ;Display value in DL	
		
	cmp al, 0Dh ;If character entered is CR
	je input_validation   
	
	cmp al, 49  ;If larger than ASCII 1
	jg start	;then Restart
	
	cmp al, 48  ;If smaller than ASCII 0
	jl start	;then Restart
	
	sub al, 30h		;Convert the ASCII-stored string into binary.
		
	mov [bx], al   	;Move inputted value to BX
	inc bx         	;Point to next value of BX
	jmp take_input 	;Back to the beginning of this loop

;Validates input as 10 characters. 
input_validation:
	cmp cx, 11					;Check to see that the string is 10-digit + null
	je convert_to_decimal_prep 	;If it is, then convert it to a decimal.
	jne start 					;If it isn't, restart.

;Prepares to convert to a decimal.
convert_to_decimal_prep:
	sub ax, ax						;Make AX 0 to prepare for it being used to act as a sum.
	mov bx, input 					;Point BX at input
	mov cl, 9						;Set CL to 9 to shift left & for loop counting
	sub dx, dx						;Set DX to 0
	jmp convert_to_decimal_part1	;Jump to next label to convert to a decimal.
	
;Conversion to decimal (part 2)
convert_to_decimal_part1:
	mov dx, [bx]
	shl dx, cl							;Shift BX left by CL's value
	add ax, dx							;Add BX to AX
	inc bx								;Point BX at next value	
	
	dec cl								;Reduce CL by 1.
	cmp cl, 7							;If CL is 0, then:
	je convert_to_decimal_part2_prep 	;Moves to the next label which prepares registers for converting to a decimal string.
		
	jmp convert_to_decimal_part1		;Jump back to beginning of label
	
;Prepares for part 2 of the conversion to decimal.
convert_to_decimal_part2_prep:
	sub dx, dx							;Set DX to 0
	je convert_to_decimal_part2 		;Jump to next label.

;Converts to decimal (part 2)	
convert_to_decimal_part2:
	mov dl, [bx]						;Move the current value in BX to DL
	shl dl, cl							;Shift DL left by CL's value
	add ax, dx							;Add DX to AX
	inc bx								;Point BX at next value	
	
	cmp cl, 0							;If CL is 0, then:
	je convert_to_decimal_string_prep 	;Moves to the next label which prepares registers for converting to a decimal string.
	
	dec cl								;Reduce CL by 1.
	
	jmp convert_to_decimal_part2		;Jump back to beginning.

;Prepare to convert to a decimal string.
convert_to_decimal_string_prep:
	mov [decimal], ax 		;Store AX into decimal for conversion to string.
	mov bx, decimal_string	;Points BX at decimal_string
	sub dx, dx				;Set DX to 0
	jmp convert_to_decimal_string	

;Convert to a decimal string.
convert_to_decimal_string:
	mov cx, 1000	;Move 1000 to CX
	div cx			;Divide AX by CX
	add al, 30h		;Add 30h to AL
	mov [bx], al	;Move AL to the value BX represents
	inc bx			;Point BX at next value
	mov ax, dx		;Move DX to AX
	sub dx, dx		;Set DX to 0
	
	mov cx, 100		;Set CX to 100
	div cx			;Divide AX by CX
	add al, 30h		;Add 30h to AL
	mov [bx], al	;Move AL to the value BX represents
	inc bx			;Point BX at next value
	mov ax, dx		;Move DX to AX
	sub dx, dx		;Set DX to 0

	mov cx, 10		;Set CX to 10
	div cx			;Divide AX by CX
	add al, 30h		;Add 30h to AL
	mov [bx], al	;Move AL to the value BX represents
	inc bx			;Point BX at next value

	add dl, 30h		;Add 30h to DL
	mov [bx], dl	;Move DL to the value BX represents
	
	jmp display_decimal_string_prep ;Jump to the next label to output the decimal string. 

;Prepares to display the decimal string.
display_decimal_string_prep:
	mov ah, 02h 				;Move service number 02h to AH
	mov dl, 10					;Move 10 to DL
	int 21h						;Call interrupt 21h
	mov dl, 13					;Move 13 to DL
	int 21h						;Call interrupt 21h
	mov bx, decimal_string 		;Move the decimal string to BX
	jmp display_decimal_string	;Jump to the next label to display the string.

;Displays the decimal string.
display_decimal_string:
	mov dl, [bx]							;Move the current value in BX to DX
	inc bx									;Increment BX to point at the next value
	cmp dl, 0								;Compare DL to 0
	je convert_to_duotrigesimal_string_prep	;If it is, prepare to convert to a duotrigesimal string.
	mov ah, 02h								;Move service number 02h to AH
	int 21h									;Call interrupt 21h
	jmp display_decimal_string				;Jump back to the beginning of the label.

;Prepares to convert to a duotrigesimal string.
convert_to_duotrigesimal_string_prep:
	mov ax, [decimal]							;Store decimal into AX for conversion to duotrigesimal.
	mov bx, duotrigesimal_string				;Points BX at duotrigesimal_string
	sub dx, dx									;Set DX to 0
	jmp convert_to_duotrigesimal_string_part1	;Jump to next label.
	
;Part 1 of the conversion to a duotrigesimal string.
convert_to_duotrigesimal_string_part1:
	mov cx, 32			;Set CX to 32
	div cx				;Divide AX by CX
	cmp al, 9			;Compare AL to 9
	jle duotrig_num1	;If it is less than or equal to 9, jump to duotrig_num1
	jg duotrig_alpha1	;If it is grater than 9, jump to duotrig_alpha1
	
;If it is a number (0-9), this runs.
duotrig_num1:
	add al, 30h									;Add 30h to AL
	mov [bx], al								;Move AL to the value BX represents
	inc bx										;Point BX at next value
	jmp convert_to_duotrigesimal_string_part2	;Jump to next label.

;If it is an alphabetical letter (A-V), this runs.
duotrig_alpha1:
	add al, 37h									;Add 37h to AL.
	mov [bx], al								;Move AL to the value BX represents
	inc bx										;Point BX at next value
	jmp convert_to_duotrigesimal_string_part2	;Jump to next label.

;Part 2 of the conversion to a duotrigesimal string.
convert_to_duotrigesimal_string_part2:
	cmp dl, 9			;Compare DL to 9
	jle duotrig_num2	;If it is less than or equal to 9, jump to duotrig_num2
	jg duotrig_alpha2	;If it is grater than 9, jump to duotrig_alpha2

;If it is a number (0-9), this runs.
duotrig_num2:
	add dl, 30h								;Add 30h to DL
	mov [bx], dl							;Move DL to the value BX represents
	jmp display_duotrigesimal_string_prep 	;Jump to the next label to output the duotrigesimal string. 

;If it is an alphabetical letter (A-V), this runs.
duotrig_alpha2:
	add dl, 37h								;Add 37h to AL.
	mov [bx], dl							;Move DL to the value BX represents
	jmp display_duotrigesimal_string_prep 	;Jump to the next label to output the decimal string. 

;Prepares to display the duotrigesimal string.
display_duotrigesimal_string_prep:
	mov ah, 02h 						;Move service number 02h to AH
	mov dl, 10							;Move 10 to DL
	int 21h								;Call interrupt 21h
	mov dl, 13							;Move 13 to DL
	int 21h								;Call interrupt 21h
	mov bx, duotrigesimal_string		;Move duotrigesimal_string to BX
	jmp display_duotrigesimal_string	;Jump to next label
	
;Displays the duotrigesimal string.
display_duotrigesimal_string:
	mov dl, [bx]						;Move the current value in BX to DX
	inc bx								;Increment BX to point at the next value
	cmp dl, 0							;Compare DL to 0
	je quit								;If it is, quit
	mov ah, 02h							;Move service number 02h to AH
	int 21h								;Call interrupt 21h
	jmp display_duotrigesimal_string	;Jump back to the beginning of the label.

;Quit
quit:
	int 20h

section .data	
	input 	TIMES 11 	db 	0
	prompt 	db 	10,13,"Enter a 10 digit binary number.", 10, 13, 0
	decimal dw 0
	decimal_string TIMES 5 db 0
	duotrigesimal_string TIMES 3 db 0

	