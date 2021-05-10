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
	t4	DW	?
.CODE

MAIN PROC
	MOV AX, @DATA
	MOV DS, AX

	;a=0
	MOV var_1_1_a, 0

	;b=0
	MOV var_1_1_b, 0

	;c=0
	MOV var_1_1_c, 0

	;d=0
	MOV var_1_1_d, 0

	;e=0
	MOV var_1_1_e, 0

	MOV AX, 2
	CMP AX, 3
	JNL L0
	MOV t0, 1
	JMP L1
L0:
	AND t0, 0
L1:
	MOV AX, t0
	CMP AX, 0
	JNE L2
	MOV t0, 1
	JMP L3
L2:
	AND t0, 0
L3:
	MOV AX, 3
	CMP AX, 2
	JE L4
	MOV t1, 1
	JMP L5
L4:
	AND t1, 0
L5:
	MOV AX, t1
	CMP AX, 0
	JNE L6
	MOV t1, 1
	JMP L7
L6:
	AND t1, 0
L7:
	CMP t0, 0
	JNE L8
	CMP t1, 0
	JNE L8
	AND t0, 0
	JMP L9
L8:
	MOV t0, 1
L9:
	MOV AX, t0
	CMP AX, 0
	JNE L10
	MOV t0, 1
	JMP L11
L10:
	AND t0, 0
L11:
	CMP t0, 0
	JE L12
	;a=1
	MOV var_1_1_a, 1

	JMP L13
L12:
	;a=2
	MOV var_1_1_a, 2

L13:
	MOV AX, var_1_1_a
	CMP AX, 1
	JNE L14
	MOV t0, 1
	JMP L15
L14:
	AND t0, 0
L15:
	MOV AX, t0
	CMP AX, 0
	JNE L16
	MOV t0, 1
	JMP L17
L16:
	AND t0, 0
L17:
	MOV AX, 3
	CMP AX, 2
	JE L18
	MOV t1, 1
	JMP L19
L18:
	AND t1, 0
L19:
	MOV AX, t1
	CMP AX, 0
	JNE L20
	MOV t1, 1
	JMP L21
L20:
	AND t1, 0
L21:
	CMP t0, 0
	JNE L22
	CMP t1, 0
	JNE L22
	AND t0, 0
	JMP L23
L22:
	MOV t0, 1
L23:
	MOV AX, t0
	CMP AX, 0
	JNE L24
	MOV t0, 1
	JMP L25
L24:
	AND t0, 0
L25:
	CMP t0, 0
	JE L30
	MOV AX, 2
	IMUL var_1_1_a
	MOV t1, AX
	MOV AX, 3
	IMUL t1
	MOV t1, AX
	MOV AX, 0
	IMUL t1
	MOV t1, AX
	MOV AX, t1
	CMP AX, 0
	JNE L26
	MOV t1, 1
	JMP L27
L26:
	AND t1, 0
L27:
	CMP t1, 0
	JE L28
	;b=2
	MOV var_1_1_b, 2

	JMP L29
L28:
	;b=1
	MOV var_1_1_b, 1

L29:
L30:
	MOV AX, var_1_1_a
	CMP AX, 1
	JNE L31
	MOV t0, 1
	JMP L32
L31:
	AND t0, 0
L32:
	MOV AX, var_1_1_b
	CMP AX, 2
	JNE L33
	MOV t1, 1
	JMP L34
L33:
	AND t1, 0
L34:
	CMP t0, 0
	JE L35
	CMP t1, 0
	JE L35
	MOV t0, 1
	JMP L36
L35:
	AND t0, 0
L36:
	CMP t0, 0
	JE L45
	MOV AX, var_1_1_b
	SUB AX, var_1_1_b
	MOV t1, AX
	CMP t1, 0
	JE L43
	;c=1
	MOV var_1_1_c, 1

	JMP L44
L43:
	MOV AX, var_1_1_c
	CMP AX, 0
	JE L37
	MOV t0, 1
	JMP L38
L37:
	AND t0, 0
L38:
	MOV AX, t0
	CMP AX, 0
	JNE L39
	MOV t0, 1
	JMP L40
L39:
	AND t0, 0
L40:
	CMP t0, 0
	JE L41
	;c=3
	MOV var_1_1_c, 3

	JMP L42
L41:
	;c=2
	MOV var_1_1_c, 2

L42:
L44:
L45:
	MOV AX, var_1_1_a
	CMP AX, var_1_1_b
	JNE L46
	MOV t0, 1
	JMP L47
L46:
	AND t0, 0
L47:
	MOV AX, t0
	CMP AX, 0
	JNE L48
	MOV t0, 1
	JMP L49
L48:
	AND t0, 0
L49:
	MOV AX, var_1_1_b
	CMP AX, var_1_1_c
	JE L50
	MOV t1, 1
	JMP L51
L50:
	AND t1, 0
L51:
	MOV AX, t1
	CMP AX, 0
	JNE L52
	MOV t1, 1
	JMP L53
L52:
	AND t1, 0
L53:
	CMP t0, 0
	JE L54
	CMP t1, 0
	JE L54
	MOV t0, 1
	JMP L55
L54:
	AND t0, 0
L55:
	MOV AX, t0
	CMP AX, 0
	JNE L56
	MOV t0, 1
	JMP L57
L56:
	AND t0, 0
L57:
	CMP t0, 0
	JE L68
	MOV AX, var_1_1_b
	CMP AX, 0
	JNE L58
	MOV t1, 1
	JMP L59
L58:
	AND t1, 0
L59:
	MOV AX, t1
	CMP AX, 0
	JNE L60
	MOV t1, 1
	JMP L61
L60:
	AND t1, 0
L61:
	CMP t1, 0
	JE L67
	MOV AX, var_1_1_c
	MOV t2, AX
	INC var_1_1_c
	CMP t2, 0
	JE L66
	MOV AX, var_1_1_c
	IMUL var_1_1_a
	MOV t3, AX
	MOV AX, 2
	IMUL t3
	MOV t3, AX
	MOV AX, 4
	MOV BX, 1
	IMUL BX
	MOV t4, AX
	MOV AX, var_1_1_b
	IMUL t4
	MOV t4, AX
	MOV AX, t3
	SUB AX, t4
	MOV t3, AX
	MOV AX, 3
	IMUL var_1_1_b
	MOV t4, AX
	MOV AX, var_1_1_a
	IMUL t4
	MOV t4, AX
	MOV AX, var_1_1_c
	IMUL t4
	MOV t4, AX
	MOV AX, t3
	ADD AX, t4
	MOV t3, AX
	MOV AX, t3
	CWD
	MOV BX, 10000
	IDIV BX
	MOV t3, AX
	CMP t3, 0
	JE L64
	;d=1
	MOV var_1_1_d, 1

	JMP L65
L64:
	MOV AX, var_1_1_c
	IMUL var_1_1_a
	MOV t0, AX
	MOV AX, 2
	IMUL t0
	MOV t0, AX
	MOV AX, 4
	MOV BX, 1
	IMUL BX
	MOV t1, AX
	MOV AX, var_1_1_b
	IMUL t1
	MOV t1, AX
	MOV AX, 3
	IMUL var_1_1_b
	MOV t2, AX
	MOV AX, t1
	ADD AX, t2
	MOV t1, AX
	MOV AX, var_1_1_a
	IMUL t1
	MOV t1, AX
	MOV AX, var_1_1_c
	IMUL t1
	MOV t1, AX
	MOV AX, t0
	SUB AX, t1
	MOV t0, AX
	CMP t0, 0
	JE L62
	;d=2
	MOV var_1_1_d, 2

	JMP L63
L62:
	;e=1
	MOV var_1_1_e, 1

L63:
L65:
L66:
L67:
L68:

	;exit program
	MOV AH, 4CH
	INT 21H
MAIN ENDP
	END MAIN
