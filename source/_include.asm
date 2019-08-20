;
;		 AUTOMATICALLY GENERATED.
;
boot: .macro
	jmp TIM_Start
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
	.include "modules/common/data.asm"
	.include "modules/hardware/em65816.asm"
	.include "modules/interface/common/interface_tools.asm"
	.include "modules/interface/drivers/interface_em65816.asm"
	.include "modules/utility/tim.asm"
