; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		fpfromstr.asm
;		Purpose :	Convert String to floating point
;		Date :		15th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;		Called after IntFromString. Starting at (zGenPtr),y try to extract first a 
;		decimal part, which can be added to A, and then an exponent scalar, which 
;		can be used to scale A.
;
; *******************************************************************************************

FPFromString:
		pha 								; push A

		lda		(zGenPtr),y					; is it followed by a DP ?
		cmp 	#"."
		beq	 	_FPFIsDecimal
		jmp 	_FPFNotDecimal
		;
		;		Handle the decimal places bit.
		;
_FPFIsDecimal:
		iny 								; consume the decimal.
		;
		jsr 	FPUToFloat 					; convert the integer to float.
		phx 								; save X.
		phy 								; save decimal start position
		inx6 								; go to next section.
		jsr 	INTFromStringY 				; get the part after the DP.
		jsr 	FPUToFloat 					; convert that to a float.
		;
		pla 								; calculate - chars consumed.		
		sty 	ExpTemp
		sec		
		sbc 	ExpTemp 					; this is the shift amount
		jsr 	FPUScale10A 				; scale it by 10^AC
		plx 								; restore original X
		jsr 	FPAdd 						; Add X2 to X1 giving the fractional bit.
		;
		lda 	(zGenPtr),y 				; exponent ?
		cmp 	#"E"
		beq 	_FPFExponent
		cmp 	#"e"
		bne 	_FPFNotDecimal 				; no, then exit normally.
		;
		;		Handle exponent bit. First, find the - sign if it exists.
		;
_FPFExponent:		
		iny 								; skip over E symbol.
		lda 	(zGenPtr),y 				; look at next
		eor 	#"-"						; will be zero if -ve
		bne 	_FPFGotSign
		iny 								; if it was - skip over it. 	
_FPFGotSign:		
		pha 								; push direction : 0 -ve, #0 +ve onto stack.
		;
		;		Then get the exponent and check it's in the right range.
		;
		phx
		inx6 								; go to next slot.
		jsr 	INTFromStringY 				; get the exponent
		plx 								; restore X.

		lda 	XS2_Mantissa+1,x 			; check exponent low bytes are all zero.
		ora 	XS2_Mantissa+3,x
		ora 	XS2_Mantissa+2,x
		bne 	_FPFXOverflow 				; if not, must be a bad exponent

		lda 	XS2_Mantissa+0,x 			; get the exponent, the low byte
		cmp 	#30 						; check in range 0-30
		bcs 	_FPFXOverflow
		;
		;		Negate it if it was the - sign after the E/e
		;
		pla 								; get direction
		bne 	_FPFXScale  				; if non-zero, e.g. +ve skip the next bit
		lda 	XS2_Mantissa+0,x 			; negate the exponent
		eor 	#$FF
		inc 	a
		sta 	XS2_Mantissa+0,x
_FPFXScale:		
		;
		;		Finally scale by 10^Exponent.
		;
		lda 	XS2_Mantissa+0,x 			; get scale amount
		jsr 	FPUScale10A 				; scale by the exponent.
_FPFNotDecimal:		 	
		pla
		rts

_FPFXOverflow:
		jsr 	ERR_Handler
		.text 	"Exponent Range",0

