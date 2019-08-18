

	* = 0	
	* = $1000

start:	
	clc
	xce	
	nop
	sep 	#$30
	.as	
	.xs
	ldy 	#0
	ldx 	#$CD
	lda 	#$12
	inc 	a
loop:
	clc
	adc		#$10
	jsr 	doit
	bra 	loop


doit:
	rts
	
	* = $FFFA
	.word 	0
	.word 	start
	.word 	0

