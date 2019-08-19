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
CPU = "4510"
HARDWARE = "mega65"
	.include "modules/common/header/header.inc"
	.include "modules/common/data.asm"
	.include "modules/hardware/mega65.asm"
	.include "modules/interface/common/interface_tools.asm"
	.include "modules/interface/drivers/interface_mega65.asm"
	.include "modules/utility/tim.asm"
