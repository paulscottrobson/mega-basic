; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		rnd.asm
;		Purpose :	rnd( unary function
;		Date :		22nd August 2019
;		Review : 	1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Unary_Rnd: 	;; rnd(
		jsr 	EvaluateNumberX 			; get value
		jsr 	CheckNextRParen 			; check right bracket.
		jsr 	GetSignCurrent 				; get sign -1,0,1.
		;
		;		Dependent on parameter sign, do stuff
		;
		ora 	#0 							; if -ve set seed.
		bmi 	_URSetSeed
		beq 	_URMakeRandom 				; if zero return same number, don't advance sequence
		phx
		ldx 	#0 							; run 16 bit RNG procession on upper/lower
		jsr 	Random16
		ldx 	#2
		jsr 	Random16
		plx
		bra 	_URMakeRandom
		;
		;		Reseed the RNG using Float representation.
		;
_URSetSeed:
		jsr 	FPUToFloat 					; make it a float to twiddle it.
		lda		XS_Mantissa+0,x 			; copy mantissa to seed.
		sta 	RandomSeed+0
		lda		XS_Mantissa+1,x 					
		sta 	RandomSeed+1
		lda		XS_Mantissa+2,x 					
		sta 	RandomSeed+2
		lda		XS_Mantissa+3,x 			; this is to make the seed bear not much
		asl 	a 							; resemblance to the seed value.
		eor 	#$DB
		sta 	RandomSeed+3
		;
		;		Create a random number
		;
_URMakeRandom:								; use seed to make random number.
		lda 	RandomSeed+0 				; check if seed is zero.
		ora 	RandomSeed+1
		ora 	RandomSeed+2
		ora 	RandomSeed+3
		bne 	_URNotZero
		lda 	#$47						; if it is, make it non zero.
		sta 	RandomSeed+1				; in both parts.
		lda 	#$3D
		sta 	RandomSeed+3		
_URNotZero:		
		lda 	RandomSeed+0 				; copy seed into mantissa.
		sta 	XS_Mantissa+0,x
		lda 	RandomSeed+1
		sta 	XS_Mantissa+1,x
		lda 	RandomSeed+2
		sta 	XS_Mantissa+2,x
		lda 	RandomSeed+3
		sta 	XS_Mantissa+3,x
		lda 	#$00 						; set type to float.
		sta 	XS_Type,x
		lda 	#$80
		sta	 	XS_Exponent,x				; exponent to 128 (e.g. 0.x 2^0)
		jmp 	FPUNormalise 				; and normalise.

;
;		16-bit LFSR
;
Random16:
		lsr 	RandomSeed+1,x				; shift seed right
		ror 	RandomSeed,x
		bcc 	_R16_NoXor
		lda 	RandomSeed+1,x				; xor MSB with $B4 if bit set.
		eor 	#$B4 						; like the Wikipedia one.
		sta 	RandomSeed+1,x
_R16_NoXor:				
		rts

