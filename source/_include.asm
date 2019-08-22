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
fatal: .macro
	_error: bra _error
	.endm
cpu = "4510"
hardware = "mega65"
	.include "modules/basic/data/data.asm"
	.include "modules/hardware/mega65.asm"
	.include "modules/interface/common/interface_tools.asm"
	.include "modules/interface/drivers/interface_mega65.asm"
	.include "modules/utility/tim.asm"
