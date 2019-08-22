; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		len.asm
;		Purpose :	String length function.
;		Date :		22nd August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

Unary_Len: 	;;	len(
		jsr 	EvaluateStringX 			; string parameter
		jsr 	CheckNextRParen 			; right bracket.
		phy 								; get the string length
		ldy 	#0
		lda 	(zGenPtr),y
		ply
		;
		;		Set to integer, A
		;
UnarySetAInteger:		
		sta 	XS_Mantissa,x
		lda 	#0
		sta 	XS_Mantissa+1,x
		sta 	XS_Mantissa+2,x
		sta 	XS_Mantissa+3,x
		lda 	#1
		sta 	XS_Type,x
		rts

