.MODEL SMALL
.STACK 100H
.DATA
	var_1_1_n	DW	?
	var_1_2_a	DW	?
	var_1_2_b	DW	?
	var_1_2_c	DW	?
	t0	DW	?
	t1	DW	?
	t2	DW	?
.CODE

_fib PROC
	PUSH BP
	MOV BP, SP

	MOV AX, WORD PTR [BP+4]
	CMP AX, 1
	JNE L0
	MOV t0, 1
	JMP L1
L0:
	AND t0, 0
L1:
	MOV AX, WORD PTR [BP+4]
	CMP AX, 0
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
;argument:
	MOV AX, WORD PTR [BP+4]
	SUB AX, 1
	MOV t1, AX

	PUSH t1
	CALL _fib
	MOV t1, DX
;argument:
	MOV AX, WORD PTR [BP+4]
	SUB AX, 2
	MOV t2, AX

	PUSH t2
	CALL _fib
	MOV t2, DX
	MOV AX, t1
	ADD AX, t2
	MOV t1, AX
	MOV DX, t1
	POP BP
	RET 2
_fib ENDP

MAIN PROC
	MOV AX, @DATA
	MOV DS, AX

	;a=fib(1)
;argument:

	MOV AX, 1
	PUSH AX
	CALL _fib
	MOV t2, DX
	MOV AX, t2
	MOV var_1_2_a, AX

	;b=fib(4)
;argument:

	MOV AX, 4
	PUSH AX
	CALL _fib
	MOV t2, DX
	MOV AX, t2
	MOV var_1_2_b, AX

	;c=fib(5)
;argument:

	MOV AX, 5
	PUSH AX
	CALL _fib
	MOV t2, DX
	MOV AX, t2
	MOV var_1_2_c, AX


	;exit program
	MOV AH, 4CH
	INT 21H
MAIN ENDP
	END MAIN
