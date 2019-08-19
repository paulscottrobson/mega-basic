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
CPU = "4510"
HARDWARE = "mega65"
	.include "modules/float/fpmacros.inc"
	.include "modules/common/data.asm"
	.include "modules/hardware/mega65.asm"
	.include "modules/interface/common/interface_tools.asm"
	.include "modules/interface/drivers/interface_mega65.asm"
	.include "modules/float/fpadd.asm"
	.include "modules/float/fpdivide.asm"
	.include "modules/float/fpmultiply.asm"
	.include "modules/float/fpparts.asm"
	.include "modules/float/fpcompare.asm"
	.include "modules/float/fputils.asm"
	.include "modules/utility/tim.asm"
	.include "modules/testing/fptest.asm"
