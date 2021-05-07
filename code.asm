.MODEL SMALL
.STACK 100H
.DATA
	var_1_1_n	DW	?
	var_1_2_a	DW	?
	var_1_2_b	DW	?
	var_1_2_c	DW	?
	var_1_2_d	DW	?
	t0	DW	?
	t1	DW	?
	t2	DW	?
	t3	DW	?
	t4	DW	?
	t5	DW	?
	t6	DW	?
	t7	DW	?
	t8	DW	?
	t9	DW	?
	t10	DW	?
	t11	DW	?
	t12	DW	?
	t13	DW	?
	t14	DW	?
	t15	DW	?
	t16	DW	?
	t17	DW	?
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
	AND t2, 0
	JMP L5
L4:
	MOV t2, 1
L5:
	CMP t2, 0
	JE L6
	MOV DX, 1
	POP BP
	RET 2
L6:
;argument:
	MOV AX, WORD PTR [BP+4]
	SUB AX, 1
	MOV t3, AX

	PUSH t3
	CALL _fib
	MOV t5, DX
;argument:
	MOV AX, WORD PTR [BP+4]
	SUB AX, 2
	MOV t6, AX

	PUSH t6
	CALL _fib
	MOV t8, DX
	MOV AX, t5
	ADD AX, t8
	MOV t9, AX
	MOV DX, t9
	POP BP
	RET 2
_fib ENDP

MAIN PROC
	MOV AX, @DATA
	MOV DS, AX

	;a=fib(4)
;argument:

	MOV AX, 4
	PUSH AX
	CALL _fib
	MOV t10, DX
	MOV AX, t10
	MOV var_1_2_a, AX

	;b=fib(5)
;argument:

	MOV AX, 5
	PUSH AX
	CALL _fib
	MOV t12, DX
	MOV AX, t12
	MOV var_1_2_b, AX

	;c=fib(6)
;argument:

	MOV AX, 6
	PUSH AX
	CALL _fib
	MOV t14, DX
	MOV AX, t14
	MOV var_1_2_c, AX

	;d=fib(7)
;argument:

	MOV AX, 7
	PUSH AX
	CALL _fib
	MOV t16, DX
	MOV AX, t16
	MOV var_1_2_d, AX


	;exit program
	MOV AH, 4CH
	INT 21H
MAIN ENDP
	END MAIN
