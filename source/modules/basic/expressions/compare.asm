; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		compare.asm
;		Purpose :	Expression Evaluation (Comparisons)
;		Date :		22nd August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;									Comparison code.
;
; *******************************************************************************************

Binary_Equal:	;; 	=
		jsr 	CompareValues
		ora 	#0
		beq 	CCTrue
		;
CCFalse:lda 	#0							; set false
		bra 	CCWrite		
CCTrue:	lda 	#$FF 						; set true

CCWrite:sta 	XS_Mantissa+0,x 			; write into integer slot
		sta 	XS_Mantissa+1,x		
		sta 	XS_Mantissa+2,x		
		sta 	XS_Mantissa+3,x		
		lda 	#1
		sta 	XS_Type,x 					; set type to integer whatever.
		rts

Binary_NotEqual:	;; 	<>
		jsr 	CompareValues
		ora 	#0
		bne 	CCFalse
		bra 	CCTrue

Binary_Less:	;; 	<
		jsr 	CompareValues
		ora 	#0
		bmi 	CCTrue
		bra 	CCFalse

Binary_LessEqual:	;; 	<=
		jsr 	CompareValues
		cmp 	#1
		bne 	CCTrue
		bra 	CCFalse

Binary_GreaterEqual:	;; 	>=
		jsr 	CompareValues
		ora 	#0
		bpl 	CCTrue
		bra 	CCFalse

Binary_Greater:	;; 	>
		jsr 	CompareValues
		cmp 	#1
		bne 	CCTrue
		bra 	CCFalse
		
; *******************************************************************************************
;
;			Compare 2 values. Strings are compared as ASCIIZ, integers by subtraction
;			/signed. Floats or Floats/Ints using FPCompare. Strings and Float/Int gives
;			type error. 	Returns -1,0,1 in A accordingly.
;
; *******************************************************************************************

CompareValues:
		lda 	XS_Type,x 					; and the types together
		and 	XS2_Type,x
		cmp 	#2
		beq 	_CVString
		BinaryChoose 	FPCompare,CompareInteger32
		rts
		;
		;		Compare 2 strings.
		;
_CVString:
		nop

CompareInteger32:
		nop
