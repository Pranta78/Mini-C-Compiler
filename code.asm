.MODEL SMALL
.STACK 100H
.DATA
	arr_1_1_fib	DW	22	DUP	(?)
	var_1_1_i	DW	?
	t0	DW	?
	t1	DW	?
	t2	DW	?
	t3	DW	?
	t4	DW	?
	t5	DW	?
	t6	DW	?
.CODE

MAIN PROC
	MOV AX, @DATA
	MOV DS, AX

	;fib[(1+3*1/1==2+3*1/1)||(1!=3*2*1/2)]=1
	MOV AX, 3
	MOV BX, 1
	IMUL BX
	MOV t0, AX
	MOV AX, t0
	CWD
	MOV BX, 1
	IDIV BX
	MOV t0, AX
	MOV AX, 1
	ADD AX, t0
	MOV t0, AX
	MOV AX, 3
	MOV BX, 1
	IMUL BX
	MOV t1, AX
	MOV AX, t1
	CWD
	MOV BX, 1
	IDIV BX
	MOV t1, AX
	MOV AX, 2
	ADD AX, t1
	MOV t1, AX
	MOV AX, t0
	CMP AX, t1
	JNE L0
	MOV t0, 1
	JMP L1
L0:
	AND t0, 0
L1:
	MOV AX, 3
	MOV BX, 2
	IMUL BX
	MOV t1, AX
	MOV AX, 1
	IMUL t1
	MOV t1, AX
	MOV AX, t1
	CWD
	MOV BX, 2
	IDIV BX
	MOV t1, AX
	MOV AX, 1
	CMP AX, t1
	JE L2
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
	MOV BX, t0
	SAL BX, 1
	MOV arr_1_1_fib[BX], 1

	;fib[!((1+3*1/1==2+3*1/1)||(1!=3*2*1/2))]=1
	MOV AX, 3
	MOV BX, 1
	IMUL BX
	MOV t0, AX
	MOV AX, t0
	CWD
	MOV BX, 1
	IDIV BX
	MOV t0, AX
	MOV AX, 1
	ADD AX, t0
	MOV t0, AX
	MOV AX, 3
	MOV BX, 1
	IMUL BX
	MOV t1, AX
	MOV AX, t1
	CWD
	MOV BX, 1
	IDIV BX
	MOV t1, AX
	MOV AX, 2
	ADD AX, t1
	MOV t1, AX
	MOV AX, t0
	CMP AX, t1
	JNE L6
	MOV t0, 1
	JMP L7
L6:
	AND t0, 0
L7:
	MOV AX, 3
	MOV BX, 2
	IMUL BX
	MOV t1, AX
	MOV AX, 1
	IMUL t1
	MOV t1, AX
	MOV AX, t1
	CWD
	MOV BX, 2
	IDIV BX
	MOV t1, AX
	MOV AX, 1
	CMP AX, t1
	JE L8
	MOV t1, 1
	JMP L9
L8:
	AND t1, 0
L9:
	CMP t0, 0
	JNE L10
	CMP t1, 0
	JNE L10
	AND t0, 0
	JMP L11
L10:
	MOV t0, 1
L11:
	MOV AX, t0
	CMP AX, 0
	JNE L12
	MOV t0, 1
	JMP L13
L12:
	AND t0, 0
L13:
	MOV BX, t0
	SAL BX, 1
	MOV arr_1_1_fib[BX], 1

	;i=2
	MOV var_1_1_i, 2

L16:
	;i<22
	MOV AX, var_1_1_i
	CMP AX, 22
	JNL L14
	MOV t0, 1
	JMP L15
L14:
	AND t0, 0
L15:

	CMP t0, 0
	JE L17
	;fib[1*i*2*1+1/2+2%2-2*i/2]=fib[4*i/2*1-i*i+i*i-i+0*1*4/2-1%4]+fib[4*i/2*1-i*i+i*i-i+0*1*4/2-2*1*1%4*1]
	MOV AX, 4
	IMUL var_1_1_i
	MOV t3, AX
	MOV AX, t3
	CWD
	MOV BX, 2
	IDIV BX
	MOV t3, AX
	MOV AX, 1
	IMUL t3
	MOV t3, AX
	MOV AX, var_1_1_i
	IMUL var_1_1_i
	MOV t4, AX
	MOV AX, t3
	SUB AX, t4
	MOV t3, AX
	MOV AX, var_1_1_i
	IMUL var_1_1_i
	MOV t4, AX
	MOV AX, t3
	ADD AX, t4
	MOV t3, AX
	MOV AX, t3
	SUB AX, var_1_1_i
	MOV t3, AX
	MOV AX, 0
	MOV BX, 1
	IMUL BX
	MOV t4, AX
	MOV AX, 4
	IMUL t4
	MOV t4, AX
	MOV AX, t4
	CWD
	MOV BX, 2
	IDIV BX
	MOV t4, AX
	MOV AX, t3
	ADD AX, t4
	MOV t3, AX
	MOV AX, 1
	CWD
	MOV BX, 4
	IDIV BX
	MOV t4, DX
	MOV AX, t3
	SUB AX, t4
	MOV t3, AX
	MOV BX, t3
	SAL BX, 1
	MOV AX, arr_1_1_fib[BX]
	MOV t4, AX
	MOV AX, 4
	IMUL var_1_1_i
	MOV t5, AX
	MOV AX, t5
	CWD
	MOV BX, 2
	IDIV BX
	MOV t5, AX
	MOV AX, 1
	IMUL t5
	MOV t5, AX
	MOV AX, var_1_1_i
	IMUL var_1_1_i
	MOV t6, AX
	MOV AX, t5
	SUB AX, t6
	MOV t5, AX
	MOV AX, var_1_1_i
	IMUL var_1_1_i
	MOV t6, AX
	MOV AX, t5
	ADD AX, t6
	MOV t5, AX
	MOV AX, t5
	SUB AX, var_1_1_i
	MOV t5, AX
	MOV AX, 0
	MOV BX, 1
	IMUL BX
	MOV t6, AX
	MOV AX, 4
	IMUL t6
	MOV t6, AX
	MOV AX, t6
	CWD
	MOV BX, 2
	IDIV BX
	MOV t6, AX
	MOV AX, t5
	ADD AX, t6
	MOV t5, AX
	MOV AX, 2
	MOV BX, 1
	IMUL BX
	MOV t6, AX
	MOV AX, 1
	IMUL t6
	MOV t6, AX
	MOV AX, t6
	CWD
	MOV BX, 4
	IDIV BX
	MOV t6, DX
	MOV AX, 1
	IMUL t6
	MOV t6, AX
	MOV AX, t5
	SUB AX, t6
	MOV t5, AX
	MOV BX, t5
	SAL BX, 1
	MOV AX, arr_1_1_fib[BX]
	MOV t6, AX
	MOV AX, t4
	ADD AX, t6
	MOV t5, AX
	MOV AX, 1
	IMUL var_1_1_i
	MOV t2, AX
	MOV AX, 2
	IMUL t2
	MOV t2, AX
	MOV AX, 1
	IMUL t2
	MOV t2, AX
	MOV AX, 1
	CWD
	MOV BX, 2
	IDIV BX
	MOV t3, AX
	MOV AX, t2
	ADD AX, t3
	MOV t2, AX
	MOV AX, 2
	CWD
	MOV BX, 2
	IDIV BX
	MOV t3, DX
	MOV AX, t2
	ADD AX, t3
	MOV t2, AX
	MOV AX, 2
	IMUL var_1_1_i
	MOV t3, AX
	MOV AX, t3
	CWD
	MOV BX, 2
	IDIV BX
	MOV t3, AX
	MOV AX, t2
	SUB AX, t3
	MOV t2, AX
	MOV BX, t2
	SAL BX, 1
	MOV AX, t5
	MOV arr_1_1_fib[BX], AX

	MOV AX, var_1_1_i
	MOV t1, AX
	INC var_1_1_i
	JMP L16
L17:

	;exit program
	MOV AH, 4CH
	INT 21H
MAIN ENDP

INCLUDE PRINTLN.asm
	END MAIN
