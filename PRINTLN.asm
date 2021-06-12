PRINTLN PROC
	;prints the number in the stack in decimal format
	PUSH BP
	MOV BP, SP
	;load the parameter in the stack in register AX
	MOV AX, WORD PTR [BP+4]
    
;if AX < 0
	TEST AX, 8000H  ;Checks whether the sign bit is 1
	JZ PRINTLN_END_IF   ;skip this if AX>=0
	PUSH AX ;Saving AX since printing a character will change AX

	;print minus sign
	MOV AH, 2
	MOV DL, '-'
	INT 21H

	POP AX
	NEG AX; Replace AX with its two's complement

PRINTLN_END_IF:
	;BX is initialized as 10D and it is the divisor
	MOV BX, 10D
	;CX counts the number of times we need to pop the stack later
	XOR CX, CX  ;CX initialized to 0
                    
PRINTLN_REPEAT:
	XOR DX, DX  ;DX is reset since only AX is enough to hold the dividend
		;Otherwise incorrect output will be produced
	DIV BX  ;Divide AX by BX, AX holds the quotient, DX holds the remainder
	PUSH DX ;Store the remainder in the stack
	INC CX  ;Increase counter by 1
    
;while AX != 0    
	XOR AX, 0   ;if quotient AX = 0, we've stored every digit in the stack
	JNZ PRINTLN_REPEAT 

	MOV AH, 2

PRINTLN_PRINT_AX:   ;remainders/digits are stored in reverse order, so pop the stack and print the values
	POP DX
	OR DL, 30H
	INT 21H
	LOOP PRINTLN_PRINT_AX

	;Display CRLF
	MOV DL, 0DH
	MOV AH, 2
	INT 21H

	MOV DL, 0AH
	MOV AH, 2
	INT 21H

	POP BP
	RET 2
            
PRINTLN ENDP
