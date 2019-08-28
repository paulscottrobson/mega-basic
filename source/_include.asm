;
;		 AUTOMATICALLY GENERATED.
;
boot: .macro
	jmp BASIC_Start
	.endm
irqhandler: .macro
	.word TIM_BreakHandler
	.endm
nmihandler: .macro
		.word DefaultInterrupt
	.endm
fatal: .macro
		jsr ERR_Handler
	.text \1,0

	.endm
cpu = "65816"
hardware = "em65816"
exitonend = 1
autorun = 1
loadtest = 2
hasfloat = 1
hasinteger = 1
maxstring = 253
	.include "modules/float/fpmacros.inc"
	.include "modules/basic/pointer/em65816/src_em65816.inc"
	.include "modules/basic/pointer/checks.inc"
	.include "modules/basic/expressions/handlers.inc"
	.include "modules/basic/common/common.inc"
	.include "modules/basic/data/data.asm"
	.include "modules/hardware/em65816.asm"
	.include "modules/interface/common/interface_tools.asm"
	.include "modules/interface/drivers/interface_em65816.asm"
	.include "modules/utility/tim.asm"
	.include "modules/basic/common/errors.asm"
	.include "modules/basic/core.asm"
	.include "modules/basic/commands/dim.asm"
	.include "modules/basic/commands/run.asm"
	.include "modules/basic/commands/let.asm"
	.include "modules/basic/commands/end.asm"
	.include "modules/basic/commands/print.asm"
	.include "modules/basic/commands/assert.asm"
	.include "modules/basic/commands/clr.asm"
	.include "modules/basic/commands/stop.asm"
	.include "modules/basic/expressions/evaluate.asm"
	.include "modules/basic/expressions/logical.asm"
	.include "modules/basic/expressions/compare.asm"
	.include "modules/basic/expressions/arithmetic.asm"
	.include "modules/basic/expressions/number/sgn.asm"
	.include "modules/basic/expressions/number/abs.asm"
	.include "modules/basic/expressions/number/peek.asm"
	.include "modules/basic/expressions/number/mod.asm"
	.include "modules/basic/expressions/number/usr.asm"
	.include "modules/basic/expressions/string/val.asm"
	.include "modules/basic/expressions/string/str.asm"
	.include "modules/basic/expressions/string/asc.asm"
	.include "modules/basic/expressions/string/len.asm"
	.include "modules/basic/expressions/string/slice.asm"
	.include "modules/basic/expressions/string/hex.asm"
	.include "modules/basic/expressions/string/dec.asm"
	.include "modules/basic/expressions/string/chr.asm"
	.include "modules/basic/expressions/string/spc.asm"
	.include "modules/basic/memory/65816.asm"
	.include "modules/basic/pointer/checks.asm"
	.include "modules/basic/stringmem/concrete.asm"
	.include "modules/basic/stringmem/tempalloc.asm"
	.include "modules/basic/variables/variables.asm"
	.include "modules/basic/variables/extract.asm"
	.include "modules/basic/variables/varcreate.asm"
	.include "modules/basic/variables/arrayidx.asm"
	.include "modules/basic/variables/arraydef.asm"
	.include "modules/basic/variables/varfind.asm"
	.include "modules/basic/variables/vargetset.asm"
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
