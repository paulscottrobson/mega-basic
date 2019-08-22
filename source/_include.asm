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
fatal: .macro
	_error: bra _error
	.endm
cpu = "65816"
hardware = "em65816"
hasFloat = 1
hasInteger = 1
maxString = 253
	.include "modules/float/fpmacros.inc"
	.include "modules/basic/pointer/em65816/src_em65816.inc"
	.include "modules/basic/pointer/checks.inc"
	.include "modules/basic/expressions/handlers.inc"
	.include "modules/basic/common/common.inc"
	.include "modules/basic/data/data.asm"
	.include "modules/hardware/em65816.asm"
	.include "modules/interface/common/interface_tools.asm"
	.include "modules/interface/drivers/interface_em65816.asm"
	.include "modules/basic/core.asm"
	.include "modules/basic/commands/clr.asm"
	.include "modules/basic/expressions/evaluate.asm"
	.include "modules/basic/expressions/logical.asm"
	.include "modules/basic/expressions/compare.asm"
	.include "modules/basic/expressions/arithmetic.asm"
	.include "modules/basic/expressions/number/sgn.asm"
	.include "modules/basic/expressions/number/abs.asm"
	.include "modules/basic/expressions/string/asc.asm"
	.include "modules/basic/expressions/string/len.asm"
	.include "modules/basic/expressions/string/chr.asm"
	.include "modules/basic/expressions/string/spc.asm"
	.include "modules/basic/pointer/checks.asm"
	.include "modules/basic/stringmem/tempalloc.asm"
	.include "modules/integer/multiply.asm"
	.include "modules/integer/divide.asm"
	.include "modules/integer/convert/inttostr.asm"
	.include "modules/integer/convert/intfromstr.asm"
	.include "modules/float/fpadd.asm"
	.include "modules/float/fpdivide.asm"
	.include "modules/float/fpmultiply.asm"
	.include "modules/float/fpparts.asm"
	.include "modules/float/fpcompare.asm"
	.include "modules/float/fputils.asm"
	.include "modules/float/convert/fptostr.asm"
	.include "modules/float/convert/fpfromstr.asm"
	.include "modules/basic/expressions/floatonly/rnd.asm"
	.include "modules/basic/expressions/floatonly/int.asm"
	.include "modules/utility/tim.asm"
