.MODEL SMALL
.STACK 100H
.DATA
	var_1_1_x	DW	?
	var_1_2_y	DW	?
	var_1_3_z	DW	?
	var_1_4_a	DW	?
	var_1_f	DW	?
	var_1_g	DW	?
	t0	DW	?
.CODE

_f PROC
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
_f ENDP

_g PROC
	PUSH BP
	MOV BP, SP

	MOV AX, WORD PTR [BP+4]
	ADD AX, WORD PTR [BP+4]
	MOV t0, AX
	MOV DX, t0
	POP BP
	RET 2

	POP BP
	RET 2
_g ENDP

_h PROC
	PUSH BP
	MOV BP, SP

	MOV AX, 3
	IMUL WORD PTR [BP+4]
	MOV t0, AX
	MOV DX, t0
	POP BP
	RET 2

	POP BP
	RET 2
_h ENDP

MAIN PROC
	MOV AX, @DATA
	MOV DS, AX

	;a=3
	MOV var_1_4_a, 3

	;a=h(g(f(a)))
;arguments:
;arguments:
;arguments:
	PUSH var_1_4_a
	CALL _f
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	PUSH t0
	CALL _g
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	PUSH t0
	CALL _h
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	MOV AX, t0
	MOV var_1_4_a, AX

	PUSH var_1_4_a
	CALL PRINTLN

	;exit program
	MOV AH, 4CH
	INT 21H
MAIN ENDP

INCLUDE PRINTLN.asm
	END MAIN
