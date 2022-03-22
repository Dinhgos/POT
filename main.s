		.h8300s
		
		.equ	ZERO,0x0
		.equ	ONES,0xFFFF
		
		.equ	syscall,0x1FF00
		.equ	PUTS,0x0114
		.equ	GETS,0x0113

		.data
var1:	.word	0x1234


		.align	1
		.space	100
stck:

		.text
		.global	_start

		
_start: mov.l 	#stck,ER7


		
end:	sleep
		.end
		 