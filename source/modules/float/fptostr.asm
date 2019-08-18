; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		fptostr.asm
;		Purpose :	Convert TOXS to string at current buffer position
;		Date :		15th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

FPToString:
		pha
		phy
		bit 		XS_Type,x 				; check zero flag
		bvc 		_FPTSIsFloat 			; if zero, 
_FPTSZero:
		lda 		#"0"
		jsr 		ITSOutputCharacter
_FPTSExit:
		ply
		pla
		rts
		;
		bra 		_FPTSExit
		;
_FPTSIsFloat:
		lda 		XS_Type,x 				; is it signed ?
		bpl 		_FPTSNotSigned
		lda 		#0 						; clear sign flag
		sta 		XS_Type,x
		lda 		#"-"					; output a minus
		jsr 		ITSOutputCharacter
		;
_FPTSNotSigned:
		lda 		XS_Exponent,x
		cmp 		#128+24 				; if > 2^24 do as exponent
		bcs 		_FPTSExponent
		cmp 		#128-20 				; if < 2^-20 do as an exponent
		bcc 		_FPTSExponent 			; 
		;
		;			Standard format e.g. aaaaa.xxxxxx
		;
_FPTSStandard:
		jsr 		FPTOutputBody 			; output the body.
		bra 		_FPTSExit
		;
		;			Output in exponent format
		;
_FPTSExponent:
		lda 		#0 						; zero the exponent count.
		sta 		ExpCount
		;
_FPTSExponentLoop:
		lda 		XS_Exponent,x 			; exponent < 0, x by 10
		bpl 		_FPTSTimes		
		cmp 		#128+5 					; exit when in range 0..4
		bcc 		_FPTSScaledToExp
		lda 		#-1 					; divide by 10.
		jsr 		FPUScale10A
		inc 		ExpCount
		bra 		_FPTSExponentLoop
_FPTSTimes: 								; same but x10.
		lda 		#1
		jsr 		FPUScale10A
		dec 		ExpCount
		bra 		_FPTSExponentLoop
		;
_FPTSScaledToExp:
		jsr 		FPTOutputBody 			; output the body.
		lda 		#"e"					; output E
		jsr 		ITSOutputCharacter
		lda 		ExpCount 				; get the exponent
		sta 		XS_Mantissa,x 
		and 		#$80 					; sign extend it
		beq 		_FPTSSExt
		lda 		#$FF
_FPTSSExt:		
		sta 		XS_Mantissa+1,x
		sta 		XS_Mantissa+2,x
		sta 		XS_Mantissa+3,x
		jsr 		INTToString 			; output the exponent.
		bra			_FPTSExit 				; and exit.

; *******************************************************************************************
;
;								Output float as integer.decimals
;		
; *******************************************************************************************

FPTOutputBody:
		jsr 		FPUCopyToNext 			; copy to next slot.
		jsr 		FPUToInteger 			; convert to an integer
		jsr 		INTToString 			; output the main integer part.
		jsr 		FPUCopyFromNext 		; get the fractional part back.
		jsr 		FPFractionalPart 		; get the decimal part.
		bit 		XS_Type,x 				; any fractional part.
		bvs 		_FPTOExit 				; if not, exit now.
		lda 		#"." 					; print out a decimal place.
		jsr 		ITSOutputCharacter
_FPOutLoop:
		bit 		XS_Type,x 				; finally reached zero.
		bvs 		_FPStripZeros 			; strip trailing zeros
		jsr 		FPUTimes10 				; multiply by 10
		jsr 		FPUCopyToNext			; copy to next slot.
		jsr 		FPUToInteger 			; convert to integer
		lda 		XS_Mantissa+0,x 		; print digit.
		ora 		#"0"
		jsr 		ITSOutputCharacter
		jsr 		FPUCopyFromNext 		; get it back
		jsr 		FPFractionalPart 		; get fractional part
		lda 		NumBufX 				; done 11 characters yet ?
		cmp 	 	#11 			
		bcc 		_FPOutLoop 				; if so, keep going till zero.
_FPStripZeros:		
		ldy 		NumBufX 				; strip trailing zeros.
_FPStripLoop:
		dey 								; back one, if at start then no strip
		beq 		_FPToExit
		lda 		Num_Buffer,y 			; keep going if "0"
		cmp 		#"0"
		beq 		_FPStripLoop
		iny
		lda 		#0 						; add trailing zero one on
		sta 		Num_Buffer,y		
		sty 		NumBufX 				; update position.
_FPTOExit:		
		rts


