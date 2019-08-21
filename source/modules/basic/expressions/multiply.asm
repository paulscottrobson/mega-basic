; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		multiply.asm
;		Purpose :	Multiply 32 bit integers
;		Date :		21st August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

MulInteger32:
		lda 	XS_Mantissa+0,x					; copy +0 to +8
		sta 	XS3_Mantissa,x
		lda 	XS_Mantissa+1,x			
		sta 	XS3_Mantissa+1,x
		lda 	XS_Mantissa+2,x			
		sta 	XS3_Mantissa+2,x
		lda 	XS_Mantissa+3,x			
		sta 	XS3_Mantissa+3,x
		;
		lda 	#0
		sta 	XS_Mantissa+0,x 				; zero +0
		sta 	XS_Mantissa+1,x
		sta 	XS_Mantissa+2,x
		sta 	XS_Mantissa+3,x
		;
_BFMMultiply:
		lda 	XS3_Mantissa,x 					; get LSBit of 8-11
		and 	#1
		beq 	_BFMNoAdd
		jsr 	AddInteger32 	
_BFMNoAdd:
		;
		asl 	XS2_Mantissa+0,x 				; shift +4 left
		rol 	XS2_Mantissa+1,x
		rol 	XS2_Mantissa+2,x
		rol 	XS2_Mantissa+3,x
		;
		lsr 	XS3_Mantissa+3,x 				; shift +8 right
		ror 	XS3_Mantissa+2,x
		ror 	XS3_Mantissa+1,x
		ror 	XS3_Mantissa,x
		;
		lda 	XS3_Mantissa,x 					; continue if +8 is nonzero
		ora 	XS3_Mantissa+1,x
		ora 	XS3_Mantissa+2,x
		ora 	XS3_Mantissa+3,x
		bne 	_BFMMultiply
		;
		rts

