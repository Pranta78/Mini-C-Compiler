.MODEL SMALL
.STACK 100H
.DATA
	var_1_1_a	DW	?
	var_1_1_b	DW	?
	var_1_1_c	DW	?
	t0	DW	?
.CODE

MAIN PROC
	MOV AX, @DATA
	MOV DS, AX

	;a=a+0
	MOV AX, var_1_1_a
	ADD AX, 0
	MOV t0, AX
	MOV AX, t0
	MOV var_1_1_a, AX

	;b=b*1
	MOV AX, 1
	IMUL var_1_1_b
	MOV t0, AX
	MOV AX, t0
	MOV var_1_1_b, AX

	;c=c*4
	MOV AX, 4
	IMUL var_1_1_c
	MOV t0, AX
	MOV AX, t0
	MOV var_1_1_c, AX


	;exit program
	MOV AH, 4CH
	INT 21H
MAIN ENDP

INCLUDE PRINTLN.asm
	END MAIN
