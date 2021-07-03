.MODEL SMALL
.STACK 100H
.DATA
	arr_1_1_fib	DW	22	DUP	(?)
	var_1_i	DW	?
	t0	DW	?
	t1	DW	?
	t2	DW	?
	t3	DW	?
	t4	DW	?
	t5	DW	?
.CODE

_calculateFib PROC
	PUSH BP
	MOV BP, SP

	;fib[0]=1
	MOV BX, 0
	SAL BX, 1
	MOV arr_1_1_fib[BX], 1

	;fib[1]=1
	MOV BX, 1
	SAL BX, 1
	MOV arr_1_1_fib[BX], 1

	;for(i=2;i<n;i++)
	;i=2
	MOV var_1_i, 2

L2:
	;i<n
	MOV AX, var_1_i
	CMP AX, WORD PTR [BP+4]
	JNL L0
	MOV t0, 1
	JMP L1
L0:
	AND t0, 0
L1:

	CMP t0, 0
	JE L3
	;fib[i]=fib[i-1]+fib[i-2]
	MOV AX, var_1_i
	SUB AX, 1
	MOV t2, AX
	MOV BX, t2
	SAL BX, 1
	MOV AX, arr_1_1_fib[BX]
	MOV t3, AX
	MOV AX, var_1_i
	SUB AX, 2
	MOV t4, AX
	MOV BX, t4
	SAL BX, 1
	MOV AX, arr_1_1_fib[BX]
	MOV t5, AX
	MOV AX, t3
	ADD AX, t5
	MOV t4, AX
	MOV BX, var_1_i
	SAL BX, 1
	MOV AX, t4
	MOV arr_1_1_fib[BX], AX

	MOV AX, var_1_i
	MOV t1, AX
	INC var_1_i
	JMP L2
L3:
	;for loop finished

	POP BP
	RET 2
_calculateFib ENDP

MAIN PROC
	MOV AX, @DATA
	MOV DS, AX

	;calculateFib(22)
;arguments:
	MOV AX, 22
	PUSH AX
	CALL _calculateFib
	;saving the return value in DX in a temporary variable
	MOV t0, DX


	;exit program
	MOV AH, 4CH
	INT 21H
MAIN ENDP

INCLUDE PRINTLN.asm
	END MAIN
