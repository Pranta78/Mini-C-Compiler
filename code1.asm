.MODEL SMALL
.STACK 100H
.DATA
	var_1_1_n	DW	?
	var_1_2_a	DW	?
	var_1_2_b	DW	?
	var_1_2_c	DW	?
	t0	DW	?
.CODE

_fact PROC
	PUSH BP
	MOV BP, SP

	MOV AX, [BP+4]
	CMP AX, 1
	JNE L0
	MOV t0, 1
	JMP L1
L0:
	AND t0, 0
L1:
	CMP t0, 0
	JE L2
	MOV DX, 1
	POP BP
	RET 2
L2:
;argument: 	MOV AX, [BP+4]
	SUB AX, 1
	MOV t0, AX

	PUSH t0
	CALL _fact
	MOV t0, DX
	MOV AX, t0
	IMUL [BP+4]
	MOV t0, AX
	MOV DX, t0
	POP BP
	RET 2
_fact ENDP

MAIN PROC
	MOV AX, @DATA
	MOV DS, AX

	;a=fact(5)
;argument: 
	MOV AX, 5
	PUSH AX
	CALL _fact
	MOV t0, DX
	MOV AX, t0
	MOV var_1_2_a, AX

	;b=fact(6)
;argument: 
	MOV AX, 6
	PUSH AX
	CALL _fact
	MOV t0, DX
	MOV AX, t0
	MOV var_1_2_b, AX

	;c=fact(7)
;argument: 
	MOV AX, 7
	PUSH AX
	CALL _fact
	MOV t0, DX
	MOV AX, t0
	MOV var_1_2_c, AX


	;exit program
	MOV AH, 4CH
	INT 21H
MAIN ENDP
	END MAIN
