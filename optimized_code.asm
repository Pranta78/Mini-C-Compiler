.MODEL SMALL
.STACK 100H
.DATA
	var_1_1_x	DW	?
	var_1_2_x	DW	?
	var_1_3_a	DW	?
	var_1_3_b	DW	?
	t0	DW	?
	t1	DW	?
.CODE

_fib PROC
	PUSH BP
	MOV BP, SP

	;if(x==0||x==1)
	MOV AX, WORD PTR [BP+4]
	CMP AX, 0
	JNE L0
	MOV t0, 1
	JMP L1
L0:
	AND t0, 0
L1:
	MOV AX, WORD PTR [BP+4]
	CMP AX, 1
	JNE L2
	MOV t1, 1
	JMP L3
L2:
	AND t1, 0
L3:
	CMP t0, 0
	JNE L4
	CMP t1, 0
	JNE L4
	AND t0, 0
	JMP L5
L4:
	MOV t0, 1
L5:
	CMP t0, 0
	JE L6
	MOV DX, 1
	POP BP
	RET 2
L6:
	;if-block finished
	;saving local variables in the stack before function call
;arguments:
	MOV AX, WORD PTR [BP+4]
	SUB AX, 1
	MOV t0, AX
	PUSH t0
	CALL _fib
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	;restoring local variables from the stack after function call
	;saving local variables in the stack before function call
	PUSH t0
;arguments:
	MOV AX, WORD PTR [BP+4]
	SUB AX, 2
	MOV t1, AX
	PUSH t1
	CALL _fib
	;saving the return value in DX in a temporary variable
	MOV t1, DX
	;restoring local variables from the stack after function call
	MOV AX, t0
	ADD AX, t1
	MOV t0, AX
	MOV DX, t0
	POP BP
	RET 2

	POP BP
	RET 2
_fib ENDP

_square PROC
	PUSH BP
	MOV BP, SP

	MOV AX, WORD PTR [BP+4]
	IMUL WORD PTR [BP+4]
	MOV t0, AX
	MOV DX, t0
	POP BP
	RET 2

	POP BP
	RET 2
_square ENDP

MAIN PROC
	MOV AX, @DATA
	MOV DS, AX

	;a=fib(4)
;arguments:
	MOV AX, 4
	PUSH AX
	CALL _fib
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	MOV AX, t0
	MOV var_1_3_a, AX

	;b=fib(5)
;arguments:
	MOV AX, 5
	PUSH AX
	CALL _fib
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	MOV AX, t0
	MOV var_1_3_b, AX


	;exit program
	MOV AH, 4CH
	INT 21H
MAIN ENDP

INCLUDE PRINTLN.asm
	END MAIN
