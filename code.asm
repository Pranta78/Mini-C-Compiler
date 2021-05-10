.MODEL SMALL
.STACK 100H
.DATA
	var_1_1_a	DW	?
	var_1_1_b	DW	?
	var_1_1_c	DW	?
	var_1_1_k	DW	?
	var_1_1_n	DW	?
	var_1_2_a	DW	?
	var_1_2_b	DW	?
	var_1_2_c	DW	?
	var_1_2_d	DW	?
	var_1_2_e	DW	?
	var_1_2_f	DW	?
	t0	DW	?
	t1	DW	?
.CODE

_binom PROC
	PUSH BP
	MOV BP, SP

	MOV AX, WORD PTR [BP+4]
	CMP AX, WORD PTR [BP+6]
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
	RET 4
L6:
	;a=binom(n-1,k)
	;saving local variables in the stack before function call
		PUSH var_1_1_a
;arguments:
	MOV AX, WORD PTR [BP+6]
	SUB AX, 1
	MOV t0, AX
	PUSH t0
	PUSH WORD PTR [BP+4]
	CALL _binom
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	;restoring local variables from the stack after function call
		POP var_1_1_a
	MOV AX, t0
	MOV var_1_1_a, AX

	;b=binom(n-1,k-1)
	;saving local variables in the stack before function call
		PUSH var_1_1_a
		PUSH var_1_1_b
;arguments:
	MOV AX, WORD PTR [BP+6]
	SUB AX, 1
	MOV t0, AX
	PUSH t0
	MOV AX, WORD PTR [BP+4]
	SUB AX, 1
	MOV t0, AX
	PUSH t0
	CALL _binom
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	;restoring local variables from the stack after function call
		POP var_1_1_b
		POP var_1_1_a
	MOV AX, t0
	MOV var_1_1_b, AX

	;c=a+b
	MOV AX, var_1_1_a
	ADD AX, var_1_1_b
	MOV t0, AX
	MOV AX, t0
	MOV var_1_1_c, AX

	MOV DX, var_1_1_c
	POP BP
	RET 4
_binom ENDP

MAIN PROC
	MOV AX, @DATA
	MOV DS, AX

	;a=binom(3,0)
	;saving local variables in the stack before function call
;arguments:
	MOV AX, 3
	PUSH AX
	MOV AX, 0
	PUSH AX
	CALL _binom
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	;restoring local variables from the stack after function call
	MOV AX, t0
	MOV var_1_2_a, AX

	;b=binom(3,1)
	;saving local variables in the stack before function call
;arguments:
	MOV AX, 3
	PUSH AX
	MOV AX, 1
	PUSH AX
	CALL _binom
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	;restoring local variables from the stack after function call
	MOV AX, t0
	MOV var_1_2_b, AX

	;c=binom(3,2)
	;saving local variables in the stack before function call
;arguments:
	MOV AX, 3
	PUSH AX
	MOV AX, 2
	PUSH AX
	CALL _binom
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	;restoring local variables from the stack after function call
	MOV AX, t0
	MOV var_1_2_c, AX

	;d=binom(3,3)
	;saving local variables in the stack before function call
;arguments:
	MOV AX, 3
	PUSH AX
	MOV AX, 3
	PUSH AX
	CALL _binom
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	;restoring local variables from the stack after function call
	MOV AX, t0
	MOV var_1_2_d, AX

	;e=binom(4,2)
	;saving local variables in the stack before function call
;arguments:
	MOV AX, 4
	PUSH AX
	MOV AX, 2
	PUSH AX
	CALL _binom
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	;restoring local variables from the stack after function call
	MOV AX, t0
	MOV var_1_2_e, AX

	;f=binom(4,3)
	;saving local variables in the stack before function call
;arguments:
	MOV AX, 4
	PUSH AX
	MOV AX, 3
	PUSH AX
	CALL _binom
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	;restoring local variables from the stack after function call
	MOV AX, t0
	MOV var_1_2_f, AX


	;exit program
	MOV AH, 4CH
	INT 21H
MAIN ENDP
	END MAIN
