.MODEL SMALL
.STACK 100H
.DATA
	var_1_1_a	DW	?
	var_1_1_b	DW	?
	var_1_1_c	DW	?
	var_1_1_d	DW	?
	var_1_1_e	DW	?
	var_1_a	DW	?
	var_1_v	DW	?
	t0	DW	?
	t1	DW	?
	t2	DW	?
.CODE
PROC MAIN
	MOV AX, @DATA
	MOV DS, AX

	;a=10
	MOV var_1_1_a, 10

	;b=0
	MOV var_1_1_b, 0

	;c=10
	MOV var_1_1_c, 10

	;d=0
	MOV var_1_1_d, 0

	;e=0
	MOV var_1_1_e, 0

	;a=0
	MOV var_1_1_a, 0

L2:
	;a<10
	MOV AX, var_1_1_a
	CMP AX, 10
	JNL L0
	MOV t0, 1
	JMP L1
L0:
	AND t0, 0
L1:

	CMP t0, 0
	JE L3
	;b++
	MOV AX, var_1_1_b
	MOV t2, AX
	INC var_1_1_b

	MOV AX, var_1_1_a
	MOV t1, AX
	INC var_1_1_a
	JMP L2
L3:
	;b=10
	MOV var_1_1_b, 10

L6:
	;b>=0
	MOV AX, var_1_1_b
	CMP AX, 0
	JNGE L4
	MOV t0, 1
	JMP L5
L4:
	AND t0, 0
L5:

	CMP t0, 0
	JE L7
	;c++
	MOV AX, var_1_1_c
	MOV t2, AX
	INC var_1_1_c

	MOV AX, var_1_1_b
	MOV t1, AX
	DEC var_1_1_b
	JMP L6
L7:
	;b=a+c+d+0+e
	PUSH AX
	MOV AX, var_1_1_a
	ADD AX, var_1_1_c
	MOV t0, AX
	POP AX
	PUSH AX
	MOV AX, t0
	ADD AX, var_1_1_d
	MOV t0, AX
	POP AX
	PUSH AX
	MOV AX, t0
	ADD AX, 0
	MOV t0, AX
	POP AX
	PUSH AX
	MOV AX, t0
	ADD AX, var_1_1_e
	MOV t0, AX
	POP AX
	PUSH AX
	MOV AX, t0
	MOV var_1_1_b, AX
	POP AX

L10:
	;b>=(a*2*1-1*a*2)
	MOV AX, 2
	IMUL var_1_1_a
	MOV t0, AX
	MOV AX, 1
	IMUL t0
	MOV t0, AX
	MOV AX, 1
	IMUL var_1_1_a
	MOV t1, AX
	MOV AX, 2
	IMUL t1
	MOV t1, AX
	PUSH AX
	MOV AX, t0
	SUB AX, t1
	MOV t0, AX
	POP AX
	MOV AX, var_1_1_b
	CMP AX, t0
	JNGE L8
	MOV t0, 1
	JMP L9
L8:
	AND t0, 0
L9:

	CMP t0, 0
	JE L11
	;d++
	MOV AX, var_1_1_d
	MOV t2, AX
	INC var_1_1_d

	MOV AX, var_1_1_b
	MOV t1, AX
	DEC var_1_1_b
	JMP L10
L11:
	MOV t0, 1
L12:
	;0

	MOV AX, 0
	CMP AX, 0
	JE L13
	;e++
	MOV AX, var_1_1_e
	MOV t2, AX
	INC var_1_1_e

	MOV AX, var_1_1_b
	MOV t1, AX
	DEC var_1_1_b
	JMP L12
L13:
	MOV t0, 1
L14:
	;0

	MOV AX, 0
	CMP AX, 0
	JE L15
	;e++
	MOV AX, var_1_1_e
	MOV t2, AX
	INC var_1_1_e

	MOV AX, var_1_1_a
	MOV t1, AX
	INC var_1_1_a
	JMP L14
L15:
	MOV AH, 4CH
	INT 21H
MAIN ENDP
	END MAIN