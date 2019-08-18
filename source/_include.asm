;
;		 AUTOMATICALLY GENERATED.
;
Boot: .macro
	jmp FPTTest
	.endm
CPU = "65816"
HARDWARE = "em65816"
	.include "modules/float/fpmacros.inc"
	.include "modules/common/data.asm"
	.include "modules/hardware/em65816.asm"
	.include "modules/interface/common/interface_tools.asm"
	.include "modules/interface/drivers/interface_em65816.asm"
	.include "modules/float/fpadd.asm"
	.include "modules/float/fpdivide.asm"
	.include "modules/float/fpmultiply.asm"
	.include "modules/float/fpparts.asm"
	.include "modules/float/fpcompare.asm"
	.include "modules/float/fputils.asm"
	.include "modules/testing/fptest.asm"
