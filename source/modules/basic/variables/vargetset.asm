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

; *******************************************************************************************
;
;			  Copy data in Mantissa => zVarDataPtr/zVarType, typecasting/checking
;
; *******************************************************************************************

VariableSet:
		lda 	XS_Type,x 					; is the result a string
		and 	#2 							; if so, it has to be
		bne 	_VSString 					
		;
		lda 	zVarType 					; if type is $ there's an error.
		cmp 	#token_Dollar
		beq 	_VSBadType
		;
		cmp 	#token_Percent 				; type convert to float/int
		beq 	_VSMakeInt
		jsr 	FPUToFloat
		bra 	_VSCopy
		;
_VSMakeInt:
		jsr 	FPUToInteger		
		;
_VSCopy:		
		phy
		ldy 	#0 							; copy mantissa to target.
		lda 	XS_Mantissa+0,x
		sta 	(zVarDataPtr),y
		iny
		lda 	XS_Mantissa+1,x
		sta 	(zVarDataPtr),y
		iny
		lda 	XS_Mantissa+2,x
		sta 	(zVarDataPtr),y
		iny
		lda 	XS_Mantissa+3,x
		sta 	(zVarDataPtr),y
		;
		lda 	zVarType 					; if target is integer, alrady done.
		cmp 	#token_Percent
		beq 	_VSExit
		;	
		lda 	XS_Type,x 					; get the sign bit into carry flag.
		asl 	a
		;
		lda 	XS_Mantissa+3,x 			; shift the sign into the mantissa high.
		php
		asl 	a
		plp
		ror 	a
		sta 	(zVarDataPtr),y
		;
		iny 
		lda 	XS_Exponent,x 				; copy the exponent in
		sta 	(zVarDataPtr),y 
		;
		bit 	XS_Type,x 					; if the result is non zero
		bvc 	_VSExit
		;
		lda 	#00 						; zero exponent indicating 0.
		sta 	(zVarDataPtr),y
		;
_VSExit:
		ply
		rts

_VSBadType:
		jmp 	TypeError
		;
		;		Assign a string.
		;
_VSString:
		lda 	zVarType 					; type must be $
		cmp 	#token_Dollar
		bne 	_VSBadType
		;
		;
		phx
		phy
		jsr 	StringConcrete 				; concrete the string in the mantissa -> AX		
		ldy 	#1 							; save high byte
		sta 	(zVarDataPtr),y
		dey 								; save low byte
		txa
		sta 	(zVarDataPtr),y
		ply 								; and exit.
		plx
		rts

		