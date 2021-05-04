.MODEL SMALL
.STACK 100H
.DATA
	var_1_1_a	DW	?
	var_1_1_b	DW	?
	var_1_1_i	DW	?
	t0	DW	?
	t1	DW	?
.CODE
PROC MAIN
	MOV AX, @DATA
	MOV DS, AX

	;b=0
	MOV var_1_1_b, 0

	;i=0
	MOV var_1_1_i, 0

L4:
	;i<4
	MOV AX, var_1_1_i
	CMP AX, 4
	JNL L0
	MOV t0, 1
	JMP L1
L0:
	AND t0, 0
L1:

	CMP t0, 0
	JE L5
	;a=3
	MOV var_1_1_a, 3

L2:
	MOV AX, var_1_1_a
	MOV t0, AX
	DEC var_1_1_a
	CMP t0, 0
	JE L3
	;b++
	MOV AX, var_1_1_b
	MOV t1, AX
	INC var_1_1_b

	JMP L2
L3:
	MOV AX, var_1_1_i
	MOV t1, AX
	INC var_1_1_i
	JMP L4
L5:
	MOV AH, 4CH
	INT 21H
MAIN ENDP
	END MAIN