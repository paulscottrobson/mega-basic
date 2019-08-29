; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		programend.asm
;		Purpose :	Update end of program pointer
;		Date :		28th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;		Calculate the end of the program and put the lower word of the address in
;		endOfProgram - it is used when variables are cleared if variableMemory
;		is zero. Note, this cannot be used when code is not kept unpaged in the
;		64k address space. In this case, you must allocate specific memory areas.
;
; *******************************************************************************************

UpdateProgramEnd:
		#s_toStart 							; start of program
_UPDLoop:		
		#s_startLine 						; start of line.
		#s_get 								; get the offset
		cmp 	#0 							; end if offset is zero.
		beq 	_UPDFoundEnd 
		#s_nextLine 						; otherwise go to the next line.
		bra 	_UPDLoop
		;
_UPDFoundEnd:
		clc 								; end of program 2 on.
		lda 	zCodePtr
		adc 	#2
		sta 	endOfProgram
		lda 	zCodePtr+1
		adc 	#0
		sta 	endOfProgram+1	
		lda 	zCodePtr+2
		adc		#0
		sta 	endOfProgram+2	
		lda 	zCodePtr+3
		adc 	#0
		sta 	endOfProgram+3
		rts