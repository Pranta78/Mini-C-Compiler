.MODEL SMALL
.STACK 100H
.DATA
	var_1_1_a	DW	?
	var_1_1_b	DW	?
	arr_1_1_c	DW	3	DUP	(?)
	t0	DW	?
	t1	DW	?
.CODE

MAIN PROC
	MOV AX, @DATA
	MOV DS, AX

	;a=1*(2+3)%3
	MOV AX, 2
	ADD AX, 3
	MOV t0, AX
	MOV AX, 1
	IMUL t0
	MOV t0, AX
	MOV AX, t0
	CWD
	MOV BX, 3
	IDIV BX
	MOV t0, DX
	MOV AX, t0
	MOV var_1_1_a, AX

	;b=1<5
	MOV AX, 1
	CMP AX, 5
	JNL L0
	MOV t0, 1
	JMP L1
L0:
	AND t0, 0
L1:
	MOV AX, t0
	MOV var_1_1_b, AX

	;c[0]=2
	MOV BX, 0
	SAL BX, 1
	MOV arr_1_1_c[BX], 2

	;if(a&&b)
	CMP var_1_1_a, 0
	JE L2
	CMP var_1_1_b, 0
	JE L2
	MOV t0, 1
	JMP L3
L2:
	AND t0, 0
L3:
	CMP t0, 0
	JE L4
	;c[0]++
	MOV BX, 0
	SAL BX, 1
	MOV AX, arr_1_1_c[BX]
	MOV t1, AX
	INC arr_1_1_c[BX]

	JMP L5
	;else
L4:
	;c[1]=c[0]
	MOV BX, 0
	SAL BX, 1
	MOV AX, arr_1_1_c[BX]
	MOV t0, AX
	MOV BX, 1
	SAL BX, 1
	MOV AX, t0
	MOV arr_1_1_c[BX], AX

L5:
	;if-else finished
	PUSH var_1_1_a
	CALL PRINTLN
	PUSH var_1_1_b
	CALL PRINTLN

	;exit program
	MOV AH, 4CH
	INT 21H
MAIN ENDP

INCLUDE PRINTLN.asm
	END MAIN
