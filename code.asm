.MODEL SMALL
.STACK 100H
.DATA
	var_1_1_x	DW	?
	var_1_1_a	DW	?
	var_1_1_b	DW	?
	var_1_2_x	DW	?
	t0	DW	?
	t1	DW	?
.CODE

_add PROC
	PUSH BP
	MOV BP, SP

	;x=a+b
	MOV AX, WORD PTR [BP+6]
	ADD AX, WORD PTR [BP+4]
	MOV t0, AX
	MOV AX, t0
	MOV var_1_1_x, AX

	MOV DX, var_1_1_x
	POP BP
	RET 4
_add ENDP

MAIN PROC
	MOV AX, @DATA
	MOV DS, AX

	;x=add(1,2)+add(2,3)+add(3,4)
;argument:

	MOV AX, 1
	PUSH AX
;argument:

	MOV AX, 2
	PUSH AX
	CALL _add
	MOV t0, DX
;argument:

	MOV AX, 2
	PUSH AX
;argument:

	MOV AX, 3
	PUSH AX
	CALL _add
	MOV t1, DX
	MOV AX, t0
	ADD AX, t1
	MOV t0, AX
;argument:

	MOV AX, 3
	PUSH AX
;argument:

	MOV AX, 4
	PUSH AX
	CALL _add
	MOV t1, DX
	MOV AX, t0
	ADD AX, t1
	MOV t0, AX
	MOV AX, t0
	MOV var_1_2_x, AX


	;exit program
	MOV AH, 4CH
	INT 21H
MAIN ENDP
	END MAIN
