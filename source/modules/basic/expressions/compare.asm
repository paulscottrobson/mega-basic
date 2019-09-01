; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		compare.asm
;		Purpose :	Expression Evaluation (Comparisons)
;		Date :		22nd August 2019
;		Review : 	1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;									Comparison code.
;
; *******************************************************************************************

;
;		These are all very similar. There is a routine which produces a comparison
; 		returning -1 (<) 0 (=) 1 (>), which is converted to an appropriate true/false.
;
Binary_Equal:	;; 	=
		jsr 	CompareValues 				; compare the values
		ora 	#0 							; true if 0
		beq 	CCTrue
		bra 	CCFalse

Binary_NotEqual:	;; 	<>
		jsr 	CompareValues
		ora 	#0 							; true if -1 or 1
		beq 	CCFalse
		bra 	CCTrue

Binary_Less:	;; 	<
		jsr 	CompareValues
		ora 	#0 							; true if -1
		bmi 	CCTrue
		bra 	CCFalse

Binary_LessEqual:	;; 	<=
		jsr 	CompareValues
		cmp 	#1 							; true if 0 or -1
		bne 	CCTrue
		bra 	CCFalse

Binary_GreaterEqual:	;; 	>=
		jsr 	CompareValues
		ora 	#0 							; true if 0 or 1
		bpl 	CCTrue
		bra 	CCFalse

Binary_Greater:	;; 	>
		jsr 	CompareValues 				; true if 1
		cmp 	#1
		beq 	CCTrue
		bra 	CCFalse
		;
		;		Return an appropriate constant.		
		;
CCFalse:lda 	#0							; set false
		bra 	CCWrite		
CCTrue:	lda 	#$FF 						; set true
		;
CCWrite:sta 	XS_Mantissa+0,x 			; write into integer slot
		sta 	XS_Mantissa+1,x		
		sta 	XS_Mantissa+2,x		
		sta 	XS_Mantissa+3,x		
		lda 	#1
		sta 	XS_Type,x 					; set type to integer whatever.
		rts
		
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
		cmp 	#2 							; is it a string, then do the string
		beq 	_CVString					; comparison routine.
		;
		;		Choose float/int compare in the same way we do arithmetic.
		;
		BinaryChoose 	FPCompare,CompareInteger32
		rts
		;
		;		Compare 2 strings. Both strings have their length first.
		;
_CVString:
		phx 								; save XY
		phy
		lda 	XS_Mantissa+0,x 			; copy string addresses to ZLTemp and ZLTemp+2
		sta		zLTemp1+0
		lda 	XS_Mantissa+1,x
		sta 	zLTemp1+1
		lda 	XS2_Mantissa+0,x
		sta 	zLTemp1+2
		lda 	XS2_Mantissa+1,x
		sta 	zLTemp1+3
		;
		;		Figure out which is the shorter. Check if the strings match
		;		up to the length of the shorter
		;
		ldy 	#0 							; find the shorter string length, we compare this.
		lda 	(zLTemp1),y
		cmp 	(zLTemp1+2),y
		bcc 	_CVCommon
		lda 	(zLTemp1+2),y
_CVCommon:		
		tax 								; put shorter string length in zero.
		beq 	_CVMatch 					; if the shorter is zero, then the 'common parts' match
		;
		;		Now compare the strings, up to the length of the shortest of the two.
		;
_CVCompare:
		iny 								; next character
		lda 	(zLTemp1),y 				; compare characters
		cmp 	(zLTemp1+2),y 				; handle different values, < or >
		bcc 	_CVReturnLess 				; < 
		bne 	_CVReturnGreater 			; >
		dex 								; until common length matched.
		bne 	_CVCompare
		;
		;		So they match as far as possible, so the longer string comes
		;		after the shorter : abc < abcd
		;
_CVMatch:									
		ldy 	#0
		lda 	(zLTemp1),y 				
		cmp 	(zLTemp1+2),y
		bcc 	_CVReturnLess 				; < 
		bne 	_CVReturnGreater 			; >
		;
		;		So they're the same !
		;
		lda 	#0 
		bra 	_CVExit 					
		;
_CVReturnLess:
		lda 	#$FF
		bra 	_CVExit
_CVReturnGreater:
		lda 	#$01
_CVExit:
		ply
		plx
		rts				

; *******************************************************************************************
;
;							32 bit signed comparison integer
;
; *******************************************************************************************

CompareInteger32:
		lda 	XS_Mantissa+3,x 			; invert both sign flags, makes compare signed
		eor 	#$80
		sta 	XS_Mantissa+3,x
		lda 	XS2_Mantissa+3,x
		eor 	#$80
		sta 	XS2_Mantissa+3,x
		;
		jsr 	SubInteger32 				; subtraction
		bcc 	_CI32Less 					; cc return -1
		;
		lda 	XS_Mantissa+0,x 			; check if zero
		ora 	XS_Mantissa+1,x
		ora 	XS_Mantissa+2,x
		ora 	XS_Mantissa+3,x
		beq 	_CI32Exit
		lda 	#1							; otherwise it's positive
_CI32Exit:
		rts		
_CI32Less:
		lda 	#$FF
		rts
