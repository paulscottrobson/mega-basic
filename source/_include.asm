;
;		 AUTOMATICALLY GENERATED.
;
boot: .macro
	jmp FPTTest
	.endm
irqhandler: .macro
		.word DefaultInterrupt
	.endm
nmihandler: .macro
		.word DefaultInterrupt
	.endm
fatal: .macro
	_error: bra _error
	.endm
cpu = "65816"
hardware = "em65816"
	.include "modules/float/fpmacros.inc"
	.include "modules/basic/common/common.inc"
	.include "modules/basic/data/data.asm"
	.include "modules/hardware/em65816.asm"
	.include "modules/interface/common/interface_tools.asm"
	.include "modules/interface/drivers/interface_em65816.asm"
	.include "modules/float/fpadd.asm"
	.include "modules/float/fpdivide.asm"
	.include "modules/float/fpmultiply.asm"
	.include "modules/float/fpparts.asm"
	.include "modules/float/fpcompare.asm"
	.include "modules/float/fputils.asm"
	.include "modules/utility/tim.asm"
	.include "modules/testing/fptest.asm"
