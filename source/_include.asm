;
;		 AUTOMATICALLY GENERATED.
;
boot: .macro
	jmp BASIC_Start
	.endm
irqhandler: .macro
	.word TIM_BreakVector
	.endm
nmihandler: .macro
		.word DefaultInterrupt
	.endm
error: .macro
	_error: bra _error
	.endm
cpu = "65816"
hardware = "em65816"
hasFloat = 1
hasInteger = 1
	.include "modules/float/fpmacros.inc"
	.include "modules/basic/pointer/em65816/src_em65816.inc"
	.include "modules/basic/expressions/handlers.inc"
	.include "modules/common/data.asm"
	.include "modules/hardware/em65816.asm"
	.include "modules/interface/common/interface_tools.asm"
	.include "modules/interface/drivers/interface_em65816.asm"
	.include "modules/basic/core.asm"
	.include "modules/basic/expressions/evaluate.asm"
	.include "modules/basic/expressions/multiply.asm"
	.include "modules/basic/expressions/divide.asm"
	.include "modules/basic/expressions/arithmetic.asm"
	.include "modules/float/fpadd.asm"
	.include "modules/float/fpdivide.asm"
	.include "modules/float/fpmultiply.asm"
	.include "modules/float/fpparts.asm"
	.include "modules/float/fpcompare.asm"
	.include "modules/float/fputils.asm"
	.include "modules/float/convert/fptostr.asm"
	.include "modules/float/convert/fpfromstr.asm"
	.include "modules/integer/convert/inttostr.asm"
	.include "modules/integer/convert/intfromstr.asm"
	.include "modules/utility/tim.asm"
