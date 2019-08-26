; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		data.asm
;		Purpose :	Memory Allocation Program
;		Date :		18th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

		* = $0
		nop 								; just in cases.....

; *******************************************************************************************
;
;										Zero Page
;
; *******************************************************************************************

		* = $10 							; 0-1 is mapping, 2-F is reserved for i/f.

zTemp1:		.word ?							; temporary pointers
zTemp2:		.word ?
zTemp3:		.word ?

zCodePtr:	.dword ? 						; code pointer.
zLTemp1:	.dword ?						; long word (used in multiply)
zGenPtr:	.word ? 						; general pointer.

zTempStr:	.word ?							; temporary string allocator. When high zero, not initialised.

zVarDataPtr: .word ? 						; position of variable data.
zVarType: 	.byte ? 						; type of data (token)

zNullString:.byte ? 						; represents a NULL string.

		* = $200

; *******************************************************************************************
;
;							Memory used by the Interface Tools
;
; *******************************************************************************************

IFT_XCursor:.byte ?							; current logical position on screen
IFT_YCursor:.byte ?
IFT_Buffer:	.fill 100 						; scroll copy buffer.
IFT_LineBuffer: .fill 100 					; line input buffer.

; *******************************************************************************************
;
;									   Buffers etc.
;
; *******************************************************************************************

		* = $300 							; expression stack area.

UserVector .fill 4 							; USR(x) calls this.
LocalVector .fill 4 						; Indirect calls call this.

XS_Mantissa .dword ? 						; 4 byte mantissa, bit 31 set.
XS_Exponent .byte ?							; 1 byte exponent, 128 == 2^0 (float only)
XS_Type 	.byte ? 						; bit 7 sign (float only)
											; bit 6 zero (float only)
											; bit 2-3 type flags (zero)
											; bit 1 string flag
											; bit 0 integer flag.
											; float type when all type bits 0-3 are zero.

XS_Size = 6

XS2_Mantissa = XS_Mantissa+XS_Size
XS2_Exponent = XS_Exponent+XS_Size
XS2_Type = XS_Type+XS_Size
XS3_Mantissa = XS_Mantissa+XS_Size*2
XS3_Exponent = XS_Exponent+XS_Size*2
XS3_Type = XS_Type+XS_Size*2

		* = $400
;		
StringPtr:	.word ? 						; Top of free memory (for string allocation)
VarMemPtr: 	.word ?							; Bottom of free memory (for variables)
;
;
;		Must be this way round, so it automatically makes a count-prefixed string.
;
NumBufX 	.byte 	?						; buffer index position
Num_Buffer	.fill 	32 						; buffer for numeric conversions


HashTableCount = 6 							; there are 6 hash tables, in token order.
HashTableSize = 8 							; each hash table as 8 links.
											; (used implicitly in extract.asm)

HashTableBase: 								
			.fill	HashTableCount * HashTableSize * 2
HashTableEnd:	

Var_Buffer 	= Num_Buffer 					; buffer for variable name (same space)
Var_Type    .byte ? 						; type of variable (as a type token)
Var_Hash 	.byte ? 						; hash of identifier name.
Var_Length 	.byte ? 						; length of variable name
Var_HashAddress .byte ?						; low byte of hash table entry.
Var_DataSize .byte ?						; size of one element.

NumSuppress	.byte 	?						; leading zero suppression flag
NumConvCount .byte 	? 						; count for conversions.

ExpTemp:	.byte ?							; Working temp for exponents.
ExpCount:	.byte ? 						; Count of decimal exponents.
SignCount:	.byte ?							; Integer Divide Sign Counts.

TempStringWriteIndex: .byte ? 				; Write offset.
ValSign: 	.byte ? 						; sign flag for val()

SliceStart:	.byte ? 						; string slice parts
SliceCount:	.byte ?

RandomSeed:	.dword ? 						; Random seed.

ArrayMaxDim = 3 							; number of dimensions.

ArrayDef:	.fill (ArrayMaxDim+1)*2 		; dimensions for auto-creation
											; (altered by DIM)
											
Tim_PC:		.word ?							; program counter on BRK (Hi/Lo order)
Tim_IRQ:	.word ?							; IRQ Vector (Hi/Lo order)
Tim_SR:		.byte ? 						; Processor Status
Tim_A:		.byte ? 						; Processor Registers
Tim_X:		.byte ?
Tim_Y:		.byte ?
Tim_Z:		.byte ?
Tim_SP:		.word ?							; Stack Pointer (just in cases)
		