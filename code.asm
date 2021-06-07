.MODEL SMALL
.STACK 100H
.DATA
	var_1_1_1_a	DW	?
	var_1_1_1_b	DW	?
	arr_1_1_fib	DW	22	DUP	(?)
	var_1_1_i	DW	?
	t0	DW	?
	t1	DW	?
	t2	DW	?
.CODE

MAIN PROC
	MOV AX, @DATA
	MOV DS, AX

	;fib[0]=1
	MOV BX, 0
	SAL BX, 1
	MOV arr_1_1_fib[BX], 1

	;fib[1]=1
	MOV BX, 1
	SAL BX, 1
	MOV arr_1_1_fib[BX], 1

	;i=2
	MOV var_1_1_i, 2

L2:
	;i<22
	MOV AX, var_1_1_i
	CMP AX, 22
	JNL L0
	MOV t0, 1
	JMP L1
L0:
	AND t0, 0
L1:

	CMP t0, 0
	JE L3
	;a=i-1
	MOV AX, var_1_1_i
	SUB AX, 1
	MOV t2, AX
	MOV AX, t2
	MOV var_1_1_1_a, AX

	;b=i-2
	MOV AX, var_1_1_i
	SUB AX, 2
	MOV t0, AX
	MOV AX, t0
	MOV var_1_1_1_b, AX

	;fib[i]=fib[a]+fib[b]
	MOV BX, var_1_1_1_a
	SAL BX, 1
	MOV AX, arr_1_1_fib[BX]
	MOV t0, AX
	MOV BX, var_1_1_1_b
	SAL BX, 1
	MOV AX, arr_1_1_fib[BX]
	MOV t1, AX
	MOV AX, t0
	ADD AX, t1
	MOV t0, AX
	MOV BX, var_1_1_i
	SAL BX, 1
	MOV AX, t0
	MOV arr_1_1_fib[BX], AX

	MOV AX, var_1_1_i
	MOV t1, AX
	INC var_1_1_i
	JMP L2
L3:

	;exit program
	MOV AH, 4CH
	INT 21H
MAIN ENDP

INCLUDE PRINTLN.asm
	END MAIN
