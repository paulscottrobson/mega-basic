; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		end.asm
;		Purpose :	END Command
;		Date :		23rd August 2019
;		Review : 	1st September 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************


Command_END: 	;; end
		;
		;		This is a build option, so we can run test scripts without 
		;		actually having to manually stop the interpreter.
		;
		.if 	exitOnEnd != 0
		#Exit
		.endif
		jmp 	WarmStart

		