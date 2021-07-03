.MODEL SMALL
.STACK 100H
.DATA
	var_1_1_n	DW	?
	var_1_2_x	DW	?
	var_1_3_x	DW	?
	var_1_3_a	DW	?
	var_1_3_b	DW	?
	var_1_3_c	DW	?
	var_1_4_a	DW	?
	t0	DW	?
	t1	DW	?
.CODE

_fact PROC
	PUSH BP
	MOV BP, SP

	;if(n==0||n==1)
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
;arguments:
	MOV AX, WORD PTR [BP+4]
	SUB AX, 1
	MOV t0, AX
	PUSH t0
	CALL _fact
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	MOV AX, t0
	IMUL WORD PTR [BP+4]
	MOV t0, AX
	MOV DX, t0
	POP BP
	RET 2

	POP BP
	RET 2
_fact ENDP

_fib PROC
	PUSH BP
	MOV BP, SP

	;if(x==0)
	MOV AX, WORD PTR [BP+4]
	CMP AX, 0
	JNE L7
	MOV t0, 1
	JMP L8
L7:
	AND t0, 0
L8:
	CMP t0, 0
	JE L9
	MOV DX, 0
	POP BP
	RET 2
L9:
	;if-block finished
	;if(x==1)
	MOV AX, WORD PTR [BP+4]
	CMP AX, 1
	JNE L10
	MOV t0, 1
	JMP L11
L10:
	AND t0, 0
L11:
	CMP t0, 0
	JE L12
	MOV DX, 1
	POP BP
	RET 2
L12:
	;if-block finished
;arguments:
	MOV AX, WORD PTR [BP+4]
	SUB AX, 1
	MOV t0, AX
	PUSH t0
	CALL _fib
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	PUSH t0
;arguments:
	MOV AX, WORD PTR [BP+4]
	SUB AX, 2
	MOV t1, AX
	PUSH t1
	CALL _fib
	;saving the return value in DX in a temporary variable
	MOV t1, DX
	POP t0
	MOV AX, t0
	ADD AX, t1
	MOV t0, AX
	MOV DX, t0
	POP BP
	RET 2

	POP BP
	RET 2
_fib ENDP

_fib_local_var PROC
	PUSH BP
	MOV BP, SP

	;if(x==0)
	MOV AX, WORD PTR [BP+4]
	CMP AX, 0
	JNE L13
	MOV t0, 1
	JMP L14
L13:
	AND t0, 0
L14:
	CMP t0, 0
	JE L15
	MOV DX, 0
	POP BP
	RET 2
L15:
	;if-block finished
	;if(x==1)
	MOV AX, WORD PTR [BP+4]
	CMP AX, 1
	JNE L16
	MOV t0, 1
	JMP L17
L16:
	AND t0, 0
L17:
	CMP t0, 0
	JE L18
	MOV DX, 1
	POP BP
	RET 2
L18:
	;if-block finished
	;a=fib_local_var(x-1)
	;saving local variables in the stack before function call
	PUSH var_1_3_a
;arguments:
	MOV AX, WORD PTR [BP+4]
	SUB AX, 1
	MOV t0, AX
	PUSH t0
	CALL _fib_local_var
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	;restoring local variables from the stack after function call
	POP var_1_3_a
	MOV AX, t0
	MOV var_1_3_a, AX

	;b=fib_local_var(x-2)
	;saving local variables in the stack before function call
	PUSH var_1_3_a
	PUSH var_1_3_b
;arguments:
	MOV AX, WORD PTR [BP+4]
	SUB AX, 2
	MOV t0, AX
	PUSH t0
	CALL _fib_local_var
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	;restoring local variables from the stack after function call
	POP var_1_3_b
	POP var_1_3_a
	MOV AX, t0
	MOV var_1_3_b, AX

	;c=a+b
	MOV AX, var_1_3_a
	ADD AX, var_1_3_b
	MOV t0, AX
	MOV var_1_3_c, AX

	MOV DX, var_1_3_c
	POP BP
	RET 2

	POP BP
	RET 2
_fib_local_var ENDP

MAIN PROC
	MOV AX, @DATA
	MOV DS, AX

	;a=fact(7)
;arguments:
	MOV AX, 7
	PUSH AX
	CALL _fact
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	MOV AX, t0
	MOV var_1_4_a, AX

	PUSH var_1_4_a
	CALL PRINTLN
	;a=fib(5)
;arguments:
	MOV AX, 5
	PUSH AX
	CALL _fib
	;saving the return value in DX in a temporary variable
	MOV t0, DX
	MOV AX, t0
	MOV var_1_4_a, AX

	PUSH var_1_4_a
	CALL PRINTLN
	;a=fib_local_var(5)
;arguments:
	MOV AX, 5
	PUSH AX
	CALL _fib_local_var
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
