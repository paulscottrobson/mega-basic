; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		vargetset.asm
;		Purpose :	Copy variable data to and from the mantissa,x
;		Date :		25th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;				Copy data in zVarDataPtr/zVarType => Mantissa in correct format.
;
; *******************************************************************************************

VariableGet:
		phy
		ldy 	#0 							; copy first two bytes
		lda 	(zVarDataPtr),y 			
		sta 	XS_Mantissa,x
		iny
		lda 	(zVarDataPtr),y
		sta 	XS_Mantissa+1,x
		iny
		;
		lda 	Var_Type 					; if it is a string, set up for that.
		cmp 	#token_Dollar
		beq 	_VGString
		;
		lda 	(zVarDataPtr),y 			; copy the next two bytes.
		sta 	XS_Mantissa+2,x
		iny
		lda 	(zVarDataPtr),y
		sta 	XS_Mantissa+3,x
		iny
		lda 	#1 							; set type to 1.
		sta 	XS_Type,x
		lda 	Var_Type
		cmp 	#token_Percent 				; if it is a %, then exit with default integer.
		beq 	_VGExit
		;
		;		Set up an exponent.
		;
		lda 	#$40 						; set type byte to zero
		sta 	XS_Type,x 					; which is the code for zero/float.
		lda 	(zVarDataPtr),y 			; the last value to copy is the exponent.
		sta 	XS_Exponent,x
		beq 	_VGExit 					; if exponent is zero ... it's zero.
		;
		lda 	XS_Mantissa+3,x 			; the sign bit is the top mantissa bit.
		pha
		and 	#$80
		sta 	XS_Type,x 					; this is the type byte.
		pla
		ora 	#$80 						; set the MSB as you would expect.
		sta 	XS_Mantissa+3,x 			; so it's a normalised float.
		;
		;		Handle string.
		;
_VGString:		
		lda 	#2 							; set type to 2, a string
		sta 	XS_Type,x
		lda 	XS_Mantissa,x 				; is the value there $0000
		ora 	XS_Mantissa+1,x
		bne 	_VGExit 					; if not, exit.
		;
		sta 	zNullString 				; make zNullString a 00 string. 
		lda 	#zNullString 		
		sta 	XS_Mantissa,x 				; make it point to it.
_VGExit:									; exit
		ply
		rts		
