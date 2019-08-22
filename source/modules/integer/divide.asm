; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		divide.asm
;		Purpose :	Divide 32 bit integers
;		Date :		21st August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

DivInteger32:
		lda 	XS2_Mantissa+0,x 			; check for /0
		ora 	XS2_Mantissa+1,x
		ora 	XS2_Mantissa+2,x
		ora 	XS2_Mantissa+3,x
		bne 	_BFDOkay
		#fatal	"Division by Zero"
		;
_BFDOkay:
		lda 	#0 							; zLTemp1 is 'A' (and holds the remainder)
		sta 	zLTemp1 					; Q/Dividend/Left in +0
		sta 	zLTemp1+1 					; M/Divisor/Right in +4
		sta 	zLTemp1+2
		sta 	zLTemp1+3
		sta 	SignCount 					; Count of signs.
		jsr 	CheckIntegerNegate 			; negate (and bump sign count)
		phx
		inx6
		jsr 	CheckIntegerNegate
		plx
		phy 								; Y is the counter
		ldy 	#32 						; 32 iterations of the loop.
_BFDLoop:
		asl 	XS_Mantissa+0,x 			; shift AQ left.
		rol 	XS_Mantissa+1,x
		rol 	XS_Mantissa+2,x
		rol 	XS_Mantissa+3,x
		rol 	zLTemp1
		rol 	zLTemp1+1
		rol 	zLTemp1+2
		rol 	zLTemp1+3
		;
		sec
		lda 	zLTemp1+0 					; Calculate A-M on stack.
		sbc 	XS2_Mantissa+0,x
		pha
		lda 	zLTemp1+1
		sbc 	XS2_Mantissa+1,x
		pha
		lda 	zLTemp1+2
		sbc 	XS2_Mantissa+2,x
		pha
		lda 	zLTemp1+3
		sbc 	XS2_Mantissa+3,x
		bcc 	_BFDNoAdd
		;
		sta 	zLTemp1+3 					; update A
		pla
		sta 	zLTemp1+2
		pla
		sta 	zLTemp1+1
		pla
		sta 	zLTemp1+0
		;
		lda 	XS_Mantissa+0,x 			; set Q bit 1.
		ora 	#1
		sta 	XS_Mantissa+0,x
		bra 	_BFDNext
_BFDNoAdd:
		pla 								; Throw away the intermediate calculations
		pla
		pla		
_BFDNext:									; do 32 times.
		dey
		bne 	_BFDLoop
		ply 								; restore Y and exit
		lsr 	SignCount 					; if sign count odd,
		bcs		IntegerNegateAlways 			; negate the result
		rts

; *******************************************************************************************
;
;						Check / Negate integer, counting negations
;
; *******************************************************************************************

CheckIntegerNegate:
		lda 	XS_Mantissa+3,x
		bmi 	IntegerNegateAlways
		rts
IntegerNegateAlways:
		inc 	SignCount
		sec
		lda 	#0
		sbc 	XS_Mantissa+0,x
		sta 	XS_Mantissa+0,x		
		lda 	#0
		sbc 	XS_Mantissa+1,x
		sta 	XS_Mantissa+1,x		
		lda 	#0
		sbc 	XS_Mantissa+2,x
		sta 	XS_Mantissa+2,x		
		lda 	#0
		sbc 	XS_Mantissa+3,x
		sta 	XS_Mantissa+3,x		
		rts
