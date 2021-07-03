.MODEL SMALL
.STACK 100H
.DATA
	var_1_1_a	DW	?
	var_1_2_x	DW	?
	var_1_2_a	DW	?
	var_1_2_b	DW	?
	var_1_3_a	DW	?
	var_1_3_b	DW	?
	t0	DW	?
.CODE

_f PROC
	PUSH BP
	MOV BP, SP

	MOV AX, 2
	IMUL WORD PTR [BP+4]
	MOV t0, AX
	MOV DX, t0
	POP BP
	RET 2
	;a=9
	MOV WORD PTR [BP+4], 9


	POP BP
	RET 2
_f ENDP

_g PROC
	PUSH BP
	MOV BP, SP

	;x=f(a)+a+b
;arguments:
	PUSH WORD PTR [BP+6]
	CALL _f
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	MOV AX, t0
	ADD AX, WORD PTR [BP+6]
	MOV t0, AX
	MOV AX, t0
	ADD AX, WORD PTR [BP+4]
	MOV t0, AX
	MOV AX, t0
	MOV var_1_2_x, AX

	MOV DX, var_1_2_x
	POP BP
	RET 4

	POP BP
	RET 4
_g ENDP

MAIN PROC
	MOV AX, @DATA
	MOV DS, AX

	;a=1
	MOV var_1_3_a, 1

	;b=2
	MOV var_1_3_b, 2

	;a=g(a,b)
;arguments:
	PUSH var_1_3_a
	PUSH var_1_3_b
	CALL _g
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	MOV AX, t0
	MOV var_1_3_a, AX

	PUSH var_1_3_a
	CALL PRINTLN
	MOV AH, 4CH
	INT 21H

	;exit program
	MOV AH, 4CH
	INT 21H
MAIN ENDP

INCLUDE PRINTLN.asm
	END MAIN
