.MODEL SMALL
.STACK 100H
.DATA
	var_1_1_m	DW	?
	var_1_1_n	DW	?
	var_1_2_m	DW	?
	var_1_2_n	DW	?
	var_1_3_a	DW	?
	var_1_3_b	DW	?
	var_1_3_c	DW	?
	var_1_3_d	DW	?
	t0	DW	?
.CODE

_f1 PROC
	PUSH BP
	MOV BP, SP

	;m=n-1
	MOV AX, WORD PTR [BP+4]
	SUB AX, 1
	MOV t0, AX
	MOV AX, t0
	MOV var_1_1_m, AX

	MOV AX, WORD PTR [BP+4]
	CMP AX, 0
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
	;saving local variables in the stack before function call
	PUSH var_1_1_m
;arguments:
	PUSH var_1_1_m
	CALL _f2
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	;restoring local variables from the stack after function call
	POP var_1_1_m
	MOV AX, t0
	IMUL WORD PTR [BP+4]
	MOV t0, AX
	MOV DX, t0
	POP BP
	RET 2
_f1 ENDP

_f2 PROC
	PUSH BP
	MOV BP, SP

	;m=n-1
	MOV AX, WORD PTR [BP+4]
	SUB AX, 1
	MOV t0, AX
	MOV AX, t0
	MOV var_1_2_m, AX

	MOV AX, WORD PTR [BP+4]
	CMP AX, 0
	JNE L3
	MOV t0, 1
	JMP L4
L3:
	AND t0, 0
L4:
	CMP t0, 0
	JE L5
	MOV DX, 1
	POP BP
	RET 2
L5:
	;saving local variables in the stack before function call
	PUSH var_1_2_m
;arguments:
	PUSH var_1_2_m
	CALL _f1
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	;restoring local variables from the stack after function call
	POP var_1_2_m
	MOV AX, t0
	IMUL WORD PTR [BP+4]
	MOV t0, AX
	MOV DX, t0
	POP BP
	RET 2
_f2 ENDP

MAIN PROC
	MOV AX, @DATA
	MOV DS, AX

	;a=f1(4)
	;saving local variables in the stack before function call
	PUSH var_1_3_a
	PUSH var_1_3_b
	PUSH var_1_3_c
	PUSH var_1_3_d
;arguments:
	MOV AX, 4
	PUSH AX
	CALL _f1
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	;restoring local variables from the stack after function call
	POP var_1_3_d
	POP var_1_3_c
	POP var_1_3_b
	POP var_1_3_a
	MOV AX, t0
	MOV var_1_3_a, AX

	;b=f2(5)
	;saving local variables in the stack before function call
	PUSH var_1_3_a
	PUSH var_1_3_b
	PUSH var_1_3_c
	PUSH var_1_3_d
;arguments:
	MOV AX, 5
	PUSH AX
	CALL _f2
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	;restoring local variables from the stack after function call
	POP var_1_3_d
	POP var_1_3_c
	POP var_1_3_b
	POP var_1_3_a
	MOV AX, t0
	MOV var_1_3_b, AX

	;c=f1(6)
	;saving local variables in the stack before function call
	PUSH var_1_3_a
	PUSH var_1_3_b
	PUSH var_1_3_c
	PUSH var_1_3_d
;arguments:
	MOV AX, 6
	PUSH AX
	CALL _f1
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	;restoring local variables from the stack after function call
	POP var_1_3_d
	POP var_1_3_c
	POP var_1_3_b
	POP var_1_3_a
	MOV AX, t0
	MOV var_1_3_c, AX

	;d=f2(7)
	;saving local variables in the stack before function call
	PUSH var_1_3_a
	PUSH var_1_3_b
	PUSH var_1_3_c
	PUSH var_1_3_d
;arguments:
	MOV AX, 7
	PUSH AX
	CALL _f2
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	;restoring local variables from the stack after function call
	POP var_1_3_d
	POP var_1_3_c
	POP var_1_3_b
	POP var_1_3_a
	MOV AX, t0
	MOV var_1_3_d, AX


	;exit program
	MOV AH, 4CH
	INT 21H
MAIN ENDP
	END MAIN
