                .h8300s

				.equ syscall,0x1FF00               ; simulated IO area
				.equ PUTS,0x0114                   ; kod PUTS
				.equ GETS,0x0113                   ; kod GETS

;-----------------------------------------------------
; data segment
;-----------------------------------------------------
				.data

txt1: 			.asciz 	"Zadejte vstup:\n" 			; output text
buffer: 		.space 	500 						; input buffer
counter1: 		.long 	0x0							; number of words in stack
counter2: 		.long 	0x0							; number of words in stack
out_buf:		.space	3200						; output buffer
num_buf:		.space	20							; number buffer for hex to ascii
num_size_err:	.asciz	"Spatnej vstup.\n"			; error message

				.align 	2 							; 4B
par1: 			.long 	txt1 						; pointer to output text
par2: 			.long 	buffer 						; pointer to input buffer
out:			.long	out_buf						; pointer to output buffer
num:			.long	num_buf						; pointer to number buffer
err1:			.long	num_size_err				; pointer to err msg

				.align	1
				.space 	800							; first array
stack1:

				.space 	800							; second array
stack2:

				.space	1600						; output array
final_stack:

				.space	100							; main stack
stck:

;-----------------------------------------------------
; code segment
;-----------------------------------------------------
				.text
				.global _start

_start:			mov.l	#stck,ER7
									
				mov.w 	#PUTS,R0
				mov.l 	#par1,ER1
				jsr 	@syscall
				
				mov.w 	#GETS,R0
				mov.l 	#par2,ER1
				jsr 	@syscall
				
				mov.l 	#buffer,ER6
				jsr 	@ascii_hex00
				
				mov.w 	#PUTS,R0
				mov.l 	#par1,ER1
				jsr 	@syscall
				
				mov.w 	#GETS,R0
				mov.l 	#par2,ER1
				jsr 	@syscall
				
				xor		ER5, ER5
				mov.l	ER5, @counter2
				
				mov.l 	#buffer,ER6
				jsr 	@ascii_hex10
				
				jsr		sort
				
end: 			jmp 	@end 						; end of program

;-----------------------------------------------------
; converts input (ascii) and saves as hex to stack1
;-----------------------------------------------------
ascii_hex00:	push.l 	ER1
				xor.w 	R0,R0
				xor.w 	R1,R1
				mov.w 	#10,E1

ascii_hex01: 	mov.b 	@ER6,R1L 					; read char from buffer
				cmp.b 	#0x3B,R1L 					; end of number 3B=;
				beq 	push_stack01 				; inserts hex number into stack
				cmp.b 	#0x0A,R1L 					; end of input
				beq 	return
				add.b 	#-'0',R1L					; sub '0' (0x30)
				mulxu.w E1,ER0 						; ER0=10*ER0
				add.w 	R1,R0 						; R0=R0+R1
				inc.l 	#1,ER6 						; next char
				jmp 	@ascii_hex01

return: 		pop.l	ER1							; return from subprogram
				rts
				
;-----------------------------------------------------
; inserts hex number into stack1
; ER5 = stack, ER2 = counter, ER6 = main input pointer, ER0 = input
;-----------------------------------------------------
push_stack01:	jsr		check_overflow
				mov		#stack1, ER5
				inc.l 	#1,ER6						; increment pointer of the main input
				mov.l	@counter1, ER2
inc_d01:		cmp.b 	#0x00, R2L					; for loop i < 0
				beq		save01
				inc.l	#2, ER5						; move pointer
				dec.l 	#1, ER2						; i--
				jmp		inc_d01						; loop
				
save01:			mov 	R0, @ER5					; inserts number into stack
				xor.w 	R0,R0						; clear for next number
				mov.l	@counter1, ER2				; counter++
				inc 	#1, ER2
				mov.l	ER2, @counter1
				jmp		ascii_hex01

;-----------------------------------------------------
; converts input (ascii) and saves as hex to stack2
;-----------------------------------------------------
ascii_hex10:	push.l 	ER1
				xor.w 	R0,R0
				xor.w 	R1,R1
				mov.w 	#10,E1

ascii_hex11: 	mov.b 	@ER6,R1L
				cmp.b 	#0x3B,R1L
				beq 	push_stack11
				cmp.b 	#0x0A,R1L
				beq 	return
				add.b 	#-'0',R1L
				mulxu.w E1,ER0
				add.w 	R1,R0
				inc.l 	#1,ER6
				jmp 	@ascii_hex11

;-----------------------------------------------------
; inserts hex number into stack2
; ER5 = stack, ER2 = counter, ER6 = main input pointer
;-----------------------------------------------------
push_stack11:	jsr		check_overflow
				mov		#stack2, ER5
				inc.l 	#1,ER6
				mov.l	@counter2, ER2
inc_d11:		cmp.b 	#0x00, R2L
				beq		save11
				inc.l	#2, ER5
				dec.l 	#1, ER2
				jmp		inc_d11
				
save11:			mov 	R0, @ER5
				xor.w 	R0,R0
				mov.l	@counter2, ER2
				inc 	#1, ER2
				mov.l	ER2, @counter2
				jmp		ascii_hex11
				
;-----------------------------------------------------
; check if number is uint16
; E0 = input
;-----------------------------------------------------
check_overflow:	cmp.w	#0x0, E0
				beq		ret
				mov.w 	#PUTS,R0
				mov.l 	#err1,ER1
				jsr 	@syscall
				jmp		end
				
ret:			rts	
;-----------------------------------------------------
; sort stack1 and stack2 and put it into final_stack
;-----------------------------------------------------
sort:			mov.l	#final_stack, ER0
				mov.l	#stack1, ER1
				mov.l	@counter1, ER2
				mov.l	#stack2, ER3
				mov.l	@counter2, ER4
				
				dec.l	#2, ER1						; move pointer
				dec.l	#2, ER3						; move pointer
				
compare:		mov.l	@ER1, ER5					; number from stack1 to ER5
				mov.l	@ER3, ER6					; number from stack2 to ER6
				
				cmp		#0x0, ER2					; stack1 empty
				BEQ		rest1
				cmp		#0x0, ER4					; stack2 empty
				BEQ		rest2
				
r_compare:		cmp.w	R5, R6
				bhi		save1						; if ER5 < ER6
				cmp.w	#0xFFFF, R6					; if ER6 is max value
				beq		max_num
				jmp		save2						; else
				
				rts
				
save1:			mov.w	R5, @ER0					; insert number into final_stack
				inc.l	#2, ER1						; inc stack1
				dec.l	#1, ER2						; dec counter
				inc.l	#2, ER0						; inc final_stack
				jmp 	compare

save2:			mov.w	R6, @ER0					; insert number into final_stack
				inc.l	#2, ER3						; inc stack2
				dec.l	#1, ER4						; dec counter
				inc.l	#2, ER0						; inc final_stack
				jmp 	compare
				
rest1:			mov.w	#0xFFFF, R5					; stack1 empty -> set value to max
				cmp		#0x0, ER4					; check if all stacks are empty
				beq		print
				jmp 	r_compare					; no more numbers in stack

rest2:			mov.w	#0xFFFF, R6
				cmp		#0x0, ER2
				beq		print
				jmp 	r_compare					; no more numbers in stack		
				
max_num:		cmp.w	#0x0, R4					; if stacks have max value (FFFF - 65535)
				beq		save1
				jmp 	save2
				
;-----------------------------------------------------
; print out
;-----------------------------------------------------
print:			mov.l	#final_stack, ER0
				mov.l	@counter1, ER1				; counter of final stack ER1
				mov.l	@counter2, ER2
				add.l	ER2, ER1
				mov.l	@out, ER2					; put ascii into buffer
				dec.l	#2,ER0						; move pointer
				
print4:			mov.l	@ER0, ER3
				mov.w	#0x0, E3					; clear E3 for dividing 0000FFFF
				jsr		hex_ascii
				
print1:			mov.b	@ER6, R5L					; R5L = ascii num
				mov.b	R5L, @ER2					; ascii into num buffer
				
				dec		#1, E1						; num counter
				inc		#1, ER2						; out pointer
				dec		#1, ER6						; num pointer
				cmp		#0x0, E1					; end of final_stack counter
				beq		print2
				jmp		print1
				
print2:			cmp		#0x0, R1					; all numbers done ?
				beq		print3						; yes = end
				mov.b	#0x20, R5L					; space between num
				mov.b	R5L, @ER2
				inc.l	#2, ER0						; next num from final
				inc		#1, ER2
				jmp		print4						; no = continue next num

print3:			mov.b	#0x0A, R5L					; adds end line to output
				mov.b	R5L, @ER2
				mov.w 	#PUTS,R0
				mov.l 	#out,ER1
				jsr 	@syscall
				
				rts
				
;-----------------------------------------------------
; hex to ascii
;-----------------------------------------------------
hex_ascii:		mov.l	@num, ER6					; number buffer ER6
				mov.l	#0xA, ER4					; divide by 10 = A
hex_ascii1:		divxu	R4, ER3
				
				mov.w	E3, R5						; rest from division into R5
				mov.w	#0x0, E3					; clear E3 for next division
				add.w	#0x30, R5					; add 30 to convert to ascii
				
				mov.b	R5L, @ER6					; ascii to num_buffer
				inc		#1, E1						; inc E1 num_buffer counter
				inc		#1, ER6						; move num buffer pointer
				
				cmp.w	#0x0, R3					; done converting number
				beq		end_hex_ascii				
				jmp		hex_ascii1					; loop
				
end_hex_ascii:	dec		#1, ER6						; move back num pointer
				dec		#1, R1						; dec num of words in final
				mov.l	#0x0, ER5					; clear for next nember
				rts
				