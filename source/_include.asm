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
CPU = "65816"
HARDWARE = "em65816"
	.include "modules/float/fpmacros.inc"
	.include "modules/common/data.asm"
	.include "modules/hardware/em65816.asm"
	.include "modules/interface/common/interface_tools.asm"
	.include "modules/interface/drivers/interface_em65816.asm"
	.include "modules/basic/core.asm"
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
