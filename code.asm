.MODEL SMALL
.STACK 100H
.DATA
	var_1_1_a	DW	?
	var_1_1_b	DW	?
	arr_1_1_c	DW	20	DUP	(?)
	t0	DW	?
	t1	DW	?
.CODE
PROC MAIN
	MOV AX, @DATA
	MOV DS, AX

	;a=2+-3+-5+6*7+28/9+1*1*1*8
	PUSH AX
	MOV AX, 2
	ADD AX, -3
	MOV t0, AX
	POP AX
	PUSH AX
	MOV AX, t0
	ADD AX, -5
	MOV t0, AX
	POP AX
	MOV AX, 6
	MOV BX, 7
	IMUL BX
	MOV t1, AX
	PUSH AX
	MOV AX, t0
	ADD AX, t1
	MOV t0, AX
	POP AX
	MOV AX, 28
	CWD
	MOV BX, 9
	IDIV BX
	MOV t1, AX
	PUSH AX
	MOV AX, t0
	ADD AX, t1
	MOV t0, AX
	POP AX
	MOV AX, 1
	MOV BX, 1
	IMUL BX
	MOV t1, AX
	MOV AX, 1
	IMUL t1
	MOV t1, AX
	MOV AX, 8
	IMUL t1
	MOV t1, AX
	PUSH AX
	MOV AX, t0
	ADD AX, t1
	MOV t0, AX
	POP AX
	PUSH AX
	MOV AX, t0
	MOV var_1_1_a, AX
	POP AX

	;a=a+a+a
	PUSH AX
	MOV AX, var_1_1_a
	ADD AX, var_1_1_a
	MOV t0, AX
	POP AX
	PUSH AX
	MOV AX, t0
	ADD AX, var_1_1_a
	MOV t0, AX
	POP AX
	PUSH AX
	MOV AX, t0
	MOV var_1_1_a, AX
	POP AX

	;b=a++
	MOV AX, var_1_1_a
	MOV t0, AX
	INC var_1_1_a
	PUSH AX
	MOV AX, t0
	MOV var_1_1_b, AX
	POP AX

	;c[0]=b*a*1*1*1*1/300
	MOV AX, var_1_1_a
	IMUL var_1_1_b
	MOV t0, AX
	MOV AX, 1
	IMUL t0
	MOV t0, AX
	MOV AX, 1
	IMUL t0
	MOV t0, AX
	MOV AX, 1
	IMUL t0
	MOV t0, AX
	MOV AX, 1
	IMUL t0
	MOV t0, AX
	MOV AX, t0
	CWD
	MOV BX, 300
	IDIV BX
	MOV t0, AX
	PUSH AX
	PUSH BX
	MOV BX, 0
	SAL BX, 1
	MOV AX, t0
	MOV arr_1_1_c[BX], AX
	POP BX
	POP AX

	;c[1]=c[0]++
	MOV BX, 0
	SAL BX, 1
	MOV AX, arr_1_1_c[BX]
	MOV t0, AX
	INC arr_1_1_c[BX]
	PUSH AX
	PUSH BX
	MOV BX, 1
	SAL BX, 1
	MOV AX, t0
	MOV arr_1_1_c[BX], AX
	POP BX
	POP AX

	;a=a/50
	MOV AX, var_1_1_a
	CWD
	MOV BX, 50
	IDIV BX
	MOV t0, AX
	PUSH AX
	MOV AX, t0
	MOV var_1_1_a, AX
	POP AX

	;b=b%50
	MOV AX, var_1_1_b
	CWD
	MOV BX, 50
	IDIV BX
	MOV t0, DX
	PUSH AX
	MOV AX, t0
	MOV var_1_1_b, AX
	POP AX

	;c[2]=c[1]--*(c[0]--)*a+b*a*2*1+5
	MOV BX, 1
	SAL BX, 1
	MOV AX, arr_1_1_c[BX]
	MOV t0, AX
	DEC arr_1_1_c[BX]
	MOV BX, 0
	SAL BX, 1
	MOV AX, arr_1_1_c[BX]
	MOV t1, AX
	DEC arr_1_1_c[BX]
	MOV AX, t1
	IMUL t0
	MOV t0, AX
	MOV AX, var_1_1_a
	IMUL t0
	MOV t0, AX
	MOV AX, var_1_1_a
	IMUL var_1_1_b
	MOV t1, AX
	MOV AX, 2
	IMUL t1
	MOV t1, AX
	MOV AX, 1
	IMUL t1
	MOV t1, AX
	PUSH AX
	MOV AX, t0
	ADD AX, t1
	MOV t0, AX
	POP AX
	PUSH AX
	MOV AX, t0
	ADD AX, 5
	MOV t0, AX
	POP AX
	PUSH AX
	PUSH BX
	MOV BX, 2
	SAL BX, 1
	MOV AX, t0
	MOV arr_1_1_c[BX], AX
	POP BX
	POP AX

	MOV AH, 4CH
	INT 21H
MAIN ENDP
	END MAIN