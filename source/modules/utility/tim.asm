; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		tim.asm
;		Purpose :	TIM Machine Language Monitor
;		Date :		18th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;									 Main Loop
;
; *******************************************************************************************

TIM_Error:
		jsr 	IFT_UpLine 					; go up one line.
		lda 	#"?"						; ? prompt
		bra 	TIM_ShowPrompt
TIM_NewCommand:
		lda 	#"."						; dot prompt
TIM_ShowPrompt:		
		jsr 	IFT_PrintCharacter			; display . or ? prompt.
		jsr 	IFT_ReadLine	 			; get character, go to next line
		jsr 	IFT_NewLine					; go to next line.
		;
		stx 	zTemp1 						; save line read address
		sty 	zTemp1+1
		ldy 	#1 							; get first character after the prompt.
		lda 	(zTemp1),y
		cmp 	#"R"						; show registers
		beq 	TIM_ShowRegisters
		cmp 	#"M" 						; show memory
		beq 	TIM_ShowMemory
		cmp 	#"G"						; execute
		beq 	TIM_Execute
		cmp 	#":"						; load memory 
		beq 	TIM_GoLoadMemory
		cmp 	#";" 						; load registers
		bne 	TIM_Error
		jmp 	TIM_UpdateRegisters
		;
TIM_GoLoadMemory:
		jmp 	TIM_LoadMemory

; *******************************************************************************************
;
;										 Memory Dump
;
; *******************************************************************************************

TIM_ShowMemory:
		jsr 	TIM_GetHex 					; get a hex value out => zTemp3
		bcs 	TIM_Error
		lda 	zTemp3 						; copy zTemp3 => zTemp2
		sta 	zTemp2
		lda 	zTemp3+1
		sta 	zTemp2+1
		jsr 	TIM_GetHex 					; get a hex value out => zTemp3
		;
		bcc 	_TIMSM_Start 				; okay, display zTemp2 ... zTemp3 as value ok
		lda 	zTemp2 						; single value set zTemp2 => zTemp3 so just one line.
		sta 	zTemp3
		lda 	zTemp2+1
		sta 	zTemp3+1
		;
_TIMSM_Start:		
		jsr 	TIM_WriteLine 				; write one line of hex out
		lda 	zTemp2 						; bump ZTemp2 by 16
		clc									
		adc 	#16
		sta 	zTemp2
		bcc 	_TIMSM_NoCarry
		inc 	zTemp2+1
_TIMSM_NoCarry:
		jsr 	IF_CheckBreak 				; check CTL+C
		bne 	_TIMSM_Ends 				; if pressed break out.
		sec 								; check past the end address in zTemp3
		lda 	zTemp3
		sbc 	zTemp2
		lda 	zTemp3+1
		sbc 	zTemp2+1
		bpl 	_TIMSM_Start
_TIMSM_Ends:		
		jmp 	TIM_NewCommand

; *******************************************************************************************
;
;										Execute
;	
; *******************************************************************************************

TIM_Execute:	
		jsr 	TIM_GetHex 					; get the execute address
		bcs 	TIM_Error 					; not legitimate
		;
		ldx 	TIM_SP 						; set up SP
		txs
		lda 	TIM_SR 						; Status for PLP
		pha
		lda 	TIM_A 						; restore AXYZ
		ldx 	TIM_X
		ldy 	TIM_Y
		.if 	CPU="4510" 					; can we load Z ?
		ldz 	TIM_Z
		.endif
		plp 								; and PS Byte.
		jmp 	(zTemp3)					; go execute

; *******************************************************************************************
;
;							Direct Entry to TIM / Show Registers
;
; *******************************************************************************************

TIM_Start: 									; entry point here (not using BRK)

TIM_ShowRegisters:
		lda 	$FFFE 						; copy IRQx which is in ROM.
		sta 	TIM_IRQ+1
		lda 	$FFFF
		sta 	TIM_IRQ
		ldx 	#0 							; display register prompt
_TIMSR_Text:
		lda 	_TIMSR_Label,x
		jsr 	IFT_PrintCharacter		
		inx
		cpx 	#_TIMSR_LabelEnd-_TIMSR_Label
		bne 	_TIMSR_Text
		ldx 	#-1							; output Register Line.
_TIMSR_Skip:
		inx		
_TIMSR_LoopSpace:
		cpx 	#4 							; this checks if we need a space to
		bcs 	_TIMSR_Space 				; batten the 16 bit registers together.
		txa
		lsr 	a
		bcs 	_TIMSR_NoSpace
_TIMSR_Space:		
		lda 	#" "
		jsr 	IFT_PrintCharacter
_TIMSR_NoSpace:		
		lda 	TIM_PC,x 					; output hex value.
		jsr 	TIM_WriteHex
		inx 	
		.if 	CPU != "4510"	
		cpx 	#TIM_Z-TIM_PC
		beq 	_TIMSR_Skip	
		.endif
		cpx 	#TIM_SP-TIM_PC+1
		bne 	_TimSR_LoopSpace
		jsr 	IFT_NewLine 				; new line
		jmp	 	TIM_NewCommand 				; new command.

_TIMSR_Label:
		.text 	"    PC   IRQ  SR AC XR YR"
		.if 	CPU="4510" 					
		.text 	" ZR"
		.endif
		.text 	" SP",13,".; "	
_TIMSR_LabelEnd:		

; *******************************************************************************************
;
;										Print Hex Byte
;
; *******************************************************************************************

TIM_WriteHex:
		pha 								; save A
		lsr 	a 							; shift MSB->LSB
		lsr 	a
		lsr 	a
		lsr 	a
		jsr 	_TIMWH_Nibble 				; print MSB
		pla 								; restore and print LSB
_TIMWH_Nibble:		
		pha
		and 	#15 						; mask out
		cmp 	#10 						; convert to ASCII
		bcc 	_TIMWHNoLetter
		adc 	#6
_TIMWHNoLetter:
		adc 	#48
		jsr 	IFT_PrintCharacter 			; print it out.
		pla
		rts		

; *******************************************************************************************
;
;								Output Memory Line at zTemp2
;
; *******************************************************************************************

TIM_WriteLine:
		lda 	#"." 						; prompt
		jsr 	IFT_PrintCharacter
		lda 	#":" 						; input line command so we can edit it
		jsr 	IFT_PrintCharacter
		lda 	zTemp2+1 					; write address
		jsr 	TIM_WriteHex
		lda 	zTemp2
		jsr 	TIM_WriteHex
		ldy 	#0							; write 16 bytes of data from (zTemp2)
_TIMWL_Loop:		
		lda 	#" "
		jsr 	IFT_PrintCharacter
		lda 	(zTemp2),y
		jsr 	TIM_WriteHex
		iny
		cpy 	#16
		bne 	_TIMWL_Loop
		jmp 	IFT_NewLine 				; new line and exit

; *******************************************************************************************
;
;						Get Hex Number into zTemp3, return CS if error.
;
; *******************************************************************************************

TIM_GetHex:
		iny
		lda 	(zTemp1),y 					; skip over spaces.
		cmp 	#32
		beq 	TIM_GetHex		
		cmp 	#"," 						; skip over commas
		beq 	TIM_GetHex
		;
		jsr 	TIM_GetHexCharacter 		; extract one hex character.
		bcs 	_TIMGH_Exit					; if first bad then exit now.
		lda 	#0 							; zero result
		sta 	zTemp3
		sta 	zTemp3+1
_TIM_GHLoop:		
		jsr 	TIM_GetHexCharacter 		; get next character
		bcs 	_TIMGH_Okay 				; if bad, exit as we have one good one.
		iny 								; skip over it.
		asl 	zTemp3 						; x zTemp3 by 16
		rol 	zTemp3+1
		asl 	zTemp3 						; now x 2
		rol 	zTemp3+1
		asl 	zTemp3						; now x 4
		rol 	zTemp3+1
		asl 	zTemp3 						; now x 8
		rol 	zTemp3+1
		ora 	zTemp3 						; OR result in
		sta 	zTemp3
		bra 	_TIM_GHLoop 				; loop round again.
		;
_TIMGH_Okay: 								; exit with CC, so okay.
		clc
_TIMGH_Exit:		
		rts

;
;		Get a single character from (zTemp1),y
;
TIM_GetHexCharacter:
		lda 	(zTemp1),y
		sec
		sbc 	#"0" 						; < 0 exit with CS
		bcc 	_TIM_GHCFail
		cmp 	#10 						; 0-9 exit with CC
		bcc 	_TIM_GHCExit
		cmp 	#65-48						; < A
		bcc		_TIM_GHCFail
		sbc 	#7 							; adjust for gap from 9-A
		cmp 	#16 						; result in range okay.
		bcc		_TIM_GHCExit

_TIM_GHCFail:	
		sec
_TIM_GHCExit:		
		rts

; *******************************************************************************************
;
;										Break Vector
;		
; *******************************************************************************************

TIM_BreakVector:
		phx									; save X/A on stack
		pha 								
		tsx 								; X points to S
		lda 	$0103,x 					; PSW saved on stack, this retrieves it
		and 	#$10 						; check stacked B Flag - only set on the stacked reg
		bne 	_TIMBreak					; if set, it's BRK
		pla 								; abandon routine.
		plx
		rti
		;
_TIMBreak:
		pla 								; save A X Y and maybe Z
		sta 	TIM_A
		plx
		stx 	TIM_X
		sty 	TIM_Y		
		.if 	CPU="4510" 					; can we save Z ?
		stz 	TIM_Z
		.endif
		pla 								; get Status Register
		sta 	TIM_SR
		pla
		sta 	TIM_PC+1 					; save calling address
		pla
		sta 	TIM_PC 						; high byte
		;
		lda 	TIM_PC+1 					; dec PC to point right.
		bne 	_TIMDecrement 				; brk bumps it.
		dec 	TIM_PC
_TIMDecrement:		
		dec 	TIM_PC+1
		tsx 								; and copy SP
		stx 	TIM_SP 						
		ldx 	#$FF 						; reset SP
		txs
		jmp 	TIM_Start 					; and start up TIM monitor.



; *******************************************************************************************
;
;									Update Registers
;
; *******************************************************************************************

TIM_UpdateRegisters:
		jsr 	TIM_GetHex 					; PC
		bcs 	_TIMURFail
		lda 	zTemp3 		
		sta 	Tim_PC+1
		lda 	zTemp3+1
		sta 	Tim_PC
		jsr 	TIM_GetHex 					; ignore IRQ
		bcs 	_TIMURFail
		ldx 	#0
_TIM_URLoop:
		jsr 	TIM_GetHex 					; registers
		bcs 	_TIMURFail
		lda 	zTemp3
		sta 	Tim_SR,x 
		inx
		cpx 	#Tim_SP-Tim_SR+1
		bne 	_TIM_URLoop			
		jmp 	TIM_NewCommand
_TIMURFail:	
		jmp 	TIM_Error		

; *******************************************************************************************
;
;										Load Memory
;
; *******************************************************************************************

TIM_LoadMemory:
		jsr 	TIM_GetHex 					; target address => zTemp2
		lda 	zTemp3
		sta 	zTemp2
		lda 	zTemp3+1
		sta 	zTemp2+1
_TIM_LMLoop:
		jsr 	TIM_GetHex 					; next byte ?
		bcs 	_TIMLMDone 					; no more
		ldx 	#0							; write out.
		lda 	zTemp3
		sta 	(zTemp2,x)
		inc 	zTemp2 						; bump address
		bne 	_TIM_LMLoop
		inc 	zTemp2+1
		bra 	_TIM_LMLoop
		;
_TIMLMDone:
		jmp 	TIM_NewCommand					

