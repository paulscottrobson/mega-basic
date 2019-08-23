; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		inttostr.asm
;		Purpose :	Convert integer to string at current buffer position
;		Date :		18th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;				  Convert integer in X1 to ASCII String at Num_Buffer[NumBufX]
;
; *******************************************************************************************

INTToString:
		pha
		phy
		lda 		XS_Mantissa+3,x 		; check -ve
		bpl 		_ITSNotMinus
		lda 		#"-"					; output a minus
		jsr 		ITSOutputCharacter
		jsr 		IntegerNegateAlways 	; negate the number.
_ITSNotMinus:		
		;
		lda 		#0 						
		sta 		NumSuppress 			; clear the suppression flag.
		txy 								; use Y for the mantissa index.
		ldx 		#0 						; X is index into dword subtraction table.
_ITSNextSubtractor:		
		lda 		#"0" 					; count of subtractions count in ASCII.
		sta 		NumConvCount
_ITSSubtract:
		sec
		lda 		XS_Mantissa,y 			; subtract number and push on stack
		sbc 		_ITSSubtractors+0,x
		pha
		lda 		XS_Mantissa+1,y
		sbc 		_ITSSubtractors+1,x
		pha
		lda 		XS_Mantissa+2,y
		sbc 		_ITSSubtractors+2,x
		pha
		lda 		XS_Mantissa+3,y
		sbc 		_ITSSubtractors+3,x
		bcc 		_ITSCantSubtract 		; if CC, then gone too far.
		;
		sta 		XS_Mantissa+3,y 		; save subtract off stack
		pla 		
		sta 		XS_Mantissa+2,y
		pla 		
		sta 		XS_Mantissa+1,y
		pla 		
		sta 		XS_Mantissa+0,y
		;
		inc 		NumConvCount 			; bump count.
		bra 		_ITSSubtract 			; go round again.
		;
_ITSCantSubtract:
		pla 								; throw away interim answers
		pla
		pla
		lda 		NumConvCount 			; if not zero then no suppression check
		cmp 		#"0"
		bne 		_ITSOutputDigit
		;
		lda 		NumSuppress 			; if suppression check zero, then don't print it.
		bpl 		_ITSGoNextSubtractor
_ITSOutputDigit:
		dec 		NumSuppress 			; suppression check will be non-zero.

		lda 		NumConvCount 			; count of subtractions
		jsr 		ITSOutputCharacter 		; output it.
		;
_ITSGoNextSubtractor:
		inx 								; next dword
		inx
		inx
		inx
		cpx 		#_ITSSubtractorsEnd-_ITSSubtractors
		bne 		_ITSNextSubtractor 		; do all the subtractors.
		tyx 								; X is back as the mantissa index
		;
		lda 		XS_Mantissa+0,x 		; and the last digit is left.
		ora 		#"0"
		jsr 		ITSOutputCharacter
		ply 								; and exit
		pla
		rts		
;
;		Powers of 10 table.
;
_ITSSubtractors:
		.dword 		1000000000
		.dword 		100000000
		.dword 		10000000
		.dword 		1000000
		.dword 		100000
		.dword 		10000
		.dword 		1000
		.dword 		100
		.dword 		10
_ITSSubtractorsEnd:

; *******************************************************************************************
;
;							Output A to Number output buffer
;
; *******************************************************************************************

ITSOutputCharacter:
		pha
		phx
		ldx 	NumBufX 					; save digit
		sta 	Num_Buffer,x
		lda		#0 							; follow by trailing NULL
		sta 	Num_Buffer+1,x
		inc 	NumBufX						; bump pointer.
		plx	
		pla
		rts
