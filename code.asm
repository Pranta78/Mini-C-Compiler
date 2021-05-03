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
	t3	DW	?
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

L0:
	MOV AX, var_1_1_a
	MOV t0, AX
	DEC var_1_1_a
	CMP t0, 0
	JE L1
	;b++
	MOV AX, var_1_1_b
	MOV t1, AX
	INC var_1_1_b

	;c--
	MOV AX, var_1_1_c
	MOV t0, AX
	DEC var_1_1_c

	JMP L0
L1:
	;a=10
	MOV var_1_1_a, 10

L2:
	MOV AX, var_1_1_a
	MOV t0, AX
	DEC var_1_1_a
	CMP t0, 0
	JE L3
	;d++
	MOV AX, var_1_1_d
	MOV t1, AX
	INC var_1_1_d

	JMP L2
L3:
	;a=10
	MOV var_1_1_a, 10

L11:
	MOV AX, var_1_1_a
	MOV t0, AX
	DEC var_1_1_a
	CMP t0, 0
	JE L12
	MOV AX, var_1_1_a
	CMP AX, 5
	JNG L4
	MOV t1, 1
	JMP L5
L4:
	AND t1, 0
L5:
	CMP t1, 0
	JE L10
	MOV AX, var_1_1_b
	CMP AX, 0
	JNG L6
	MOV t2, 1
	JMP L7
L6:
	AND t2, 0
L7:
	CMP t2, 0
	JE L8
	;b=b-4
	PUSH AX
	MOV AX, var_1_1_b
	SUB AX, 4
	MOV t3, AX
	POP AX
	PUSH AX
	MOV AX, t3
	MOV var_1_1_b, AX
	POP AX

	JMP L9
L8:
	;e=1
	MOV var_1_1_e, 1

L9:
L10:
	JMP L11
L12:
	MOV AH, 4CH
	INT 21H
MAIN ENDP
	END MAIN