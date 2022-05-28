                .h8300s

				.equ syscall,0x1FF00               ; simulated IO area
				.equ PUTS,0x0114                   ; kod PUTS
				.equ GETS,0x0113                   ; kod GETS

; ------ datovy segment ----------------------------
				.data

txt1: 			.asciz 	"Zadejte vstup:\n" 	; vypisovany text ukonceny \n (=0x0d 0x0a)
buffer: 		.space 	500 				; vstupni buffer, max.19znaku +enter
counter1: 		.long 	0x0					; number of words in stack
counter2: 		.long 	0x0					; number of words in stack
out_buf:		.space	3200
num_buf:		.space	20

				.align 	2 					; zarovnani adresy (parametricke bloky musi byt zarovnane na 4B
par1: 			.long 	txt1 				; parametricky blok 1 � ukazatel na vystupni buffer
par2: 			.long 	buffer 				; parametricky blok 2 � ukazatel na vstupni buffe
out:			.long	out_buf
num:			.long	num_buf

				.align	1
				.space 	800
stack1:

				.space 	800
stack2:

				.space	1600
final_stack:

				.space	100
stck:

; ------ kodovy segment ----------------------------

				.text
				.global _start

_start:			mov.l	#stck,ER7

				xor		ER0,ER0
				xor		ER1,ER1
				xor		ER2,ER2
				xor		ER3,ER3
				xor		ER4,ER4
				xor		ER5,ER5
				xor		ER6,ER6
									
				mov.w 	#PUTS,R0 	; kod slu�by PUTS do ROH,R0L
				mov.l 	#par1,ER1 	; adr. param. bloku do ER1
				jsr 	@syscall 	; volani syst.fce = vypsani textu txt1
				
				mov.w 	#GETS,R0 	; kod sluzby GETS do R0H,R0L
				mov.l 	#par2,ER1 	; adr. param. bloku do ER1
				jsr 	@syscall 	; volani syst.fce = uzivatel zada text, ktery bude ulozen do buffer
				
				mov.l 	#buffer,ER6 ; adresa retezce do ER6 (vstupni param.fce)
				jsr 	@ascii_hex00 	; volani funkce prevod
				inc		#1,ER3
				
				mov.w 	#PUTS,R0 	; kod slu�by PUTS do ROH,R0L
				mov.l 	#par1,ER1 	; adr. param. bloku do ER1
				jsr 	@syscall 	; volani syst.fce = vypsani textu txt1
				
				mov.w 	#GETS,R0 	; kod sluzby GETS do R0H,R0L
				mov.l 	#par2,ER1 	; adr. param. bloku do ER1
				jsr 	@syscall 	; volani syst.fce = uzivatel zada text, ktery bude ulozen do buffer
				
				xor		ER5, ER5
				mov.l	ER5, @counter2
				
				mov.l 	#buffer,ER6 ; adresa retezce do ER6 (vstupni param.fce)
				jsr 	@ascii_hex10 	; volani funkce prevod
				
				jsr		sort
				
				;jsr		print
				
end: 			jmp 	@end 		; konec

;-----------------------------------------------------
; use stack1
;-----------------------------------------------------
ascii_hex00:	; --- funkce prevod ASCII retezec->cislo
 				; vstup: ER6 = adresa retezce; vystup: R0 = cislo (0-65535)
				push.l 	ER1 		; ulozeni registru
				xor.w 	R0,R0
				xor.w 	R1,R1
				mov.w 	#10,E1

ascii_hex01: 	mov.b 	@ER6,R1L 	;precti znak z pameti
				cmp.b 	#0x20,R1L 	; test na konec (CR)
				beq 	push_stack01 ;je konec, tj. Znak = CR
				cmp.b 	#0x0A,R1L 	; test na konec (CR)
				beq 	return		; TODO save and exit
				add.b 	#-'0',R1L 	;odecteni '0' (0x30)
				mulxu.w E1,ER0 		;ER0=10*ER0
				add.w 	R1,R0 		;R0=R0+R1
				inc.l 	#1,ER6 		;dalsi adresa (znak)
				jmp 	@ascii_hex01

return: 		pop.l	ER1
				rts 				; navrat z podprogramu

				; --- saves hex numbers into stack1
				; ER5 = stack, ER2 = counter, ER6 = main input pointer
push_stack01:	mov		#stack1, ER5
				inc.l 	#1,ER6						; pointer of the main input
				mov.l	@counter1, ER2
inc_d01:		cmp.b 	#0x00, R2L
				beq		save01
				inc.l	#2, ER5
				dec.l 	#1, ER2						; not working writes sam place
				jmp		inc_d01
				
save01:			mov 	R0, @ER5
				xor.w 	R0,R0
				mov.l	@counter1, ER2
				inc 	#1, ER2
				mov.l	ER2, @counter1
				jmp		ascii_hex01				; use pop push 123

;-----------------------------------------------------
; use stack1
;-----------------------------------------------------
ascii_hex10:	; --- funkce prevod ASCII retezec->cislo
 				; vstup: ER6 = adresa retezce; vystup: R0 = cislo (0-65535)
				push.l 	ER1 		; ulozeni registru
				xor.w 	R0,R0
				xor.w 	R1,R1
				mov.w 	#10,E1

ascii_hex11: 	mov.b 	@ER6,R1L 	;precti znak z pameti
				cmp.b 	#0x20,R1L 	; test na konec (CR)
				beq 	push_stack11 ;je konec, tj. Znak = CR
				cmp.b 	#0x0A,R1L 	; test na konec (CR)
				beq 	return		; TODO save and exit
				add.b 	#-'0',R1L 	;odecteni '0' (0x30)
				mulxu.w E1,ER0 		;ER0=10*ER0
				add.w 	R1,R0 		;R0=R0+R1
				inc.l 	#1,ER6 		;dalsi adresa (znak)
				jmp 	@ascii_hex11

				; --- saves hex numbers into stack1
				; ER5 = stack, ER2 = counter, ER6 = main input pointer
push_stack11:	mov		#stack2, ER5
				inc.l 	#1,ER6						; pointer of the main input
				mov.l	@counter2, ER2
inc_d11:		cmp.b 	#0x00, R2L
				beq		save11
				inc.l	#2, ER5
				dec.l 	#1, ER2						; not working writes sam place
				jmp		inc_d11
				
save11:			mov 	R0, @ER5
				xor.w 	R0,R0
				mov.l	@counter2, ER2
				inc 	#1, ER2
				mov.l	ER2, @counter2
				jmp		ascii_hex11				; use pop push 123

;-----------------------------------------------------
; sort stacks
;-----------------------------------------------------
sort:			mov.l	#final_stack, ER0
				mov.l	#stack1, ER1
				mov.l	@counter1, ER2
				mov.l	#stack2, ER3
				mov.l	@counter2, ER4
				
				dec.l	#2, ER1
				dec.l	#2, ER3
				
compare:		mov.l	@ER1, ER5
				mov.l	@ER3, ER6
				
				cmp		#0x0, ER2
				BEQ		rest1
				cmp		#0x0, ER4
				BEQ		rest2
				
r_compare:		cmp.w	R5, R6
				bhi		save1			; if ER5 < ER6
				jmp		save2			; else
				
				rts
				
save1:			mov.w	R5, @ER0
				inc.l	#2, ER1			; inc stack1
				dec.l	#1, ER2			; dec counter
				inc.l	#2, ER0			; inc final_stack
				jmp 	compare

save2:			mov.w	R6, @ER0
				inc.l	#2, ER3			; inc stack2
				dec.l	#1, ER4			; dec counter
				inc.l	#2, ER0			; inc final_stack
				jmp 	compare
				
rest1:			mov.w	#0xFFFF, R5
				cmp		#0x0, ER4						; second stack empty
				beq		print
				jmp 	r_compare						; no more numbers in stack

rest2:			mov.w	#0xFFFF, R6
				cmp		#0x0, ER2
				beq		print
				jmp 	r_compare						; no more numbers in stack
				
;-----------------------------------------------------
; print out
;-----------------------------------------------------
print:			mov.l	#final_stack, ER0
				mov.l	@counter1, ER1
				mov.l	@counter2, ER2
				add.l	ER2, ER1
				mov.l	@out, ER2		; put ascii into buffer
				
				dec.l	#2,ER0
print4:			mov.l	@ER0, ER3
				mov.w	#0x0, E3		; only FFFF not FFFF FFFF
				jsr		hex_ascii
				
				
				;mov.b	R5L, @ER4
print1:			mov.b	@ER6, R5L	; R5L = ascii num
				mov.b	R5L, @ER2
				
				dec		#1, E1		; num counter
				inc		#1, ER2		; out pointer
				dec		#1, ER6		; num pointer
				cmp		#0x0, E1
				beq		print2
				jmp		print1
				
print2:			cmp		#0x0, R1	; all numbers done ?
				beq		print3		; yes = end
				mov.b	#0x20, R5L	; space between num
				mov.b	R5L, @ER2
				inc.l	#2, ER0		; next num from final
				inc		#1, ER2
				jmp		print4		; no = continue next num

print3:			mov.b	#0x0A, R5L	; space between num
				mov.b	R5L, @ER2
				mov.w 	#PUTS,R0
				mov.l 	#out,ER1
				jsr 	@syscall
				
				rts
							
;-----------------------------------------------------
; hex to ascii
;-----------------------------------------------------
hex_ascii:		mov.l	@num, ER6
				mov.l	#0xA, ER4
hex_ascii1:		divxu	R4, ER3
				
				mov.w	E3, R5
				mov.w	#0x0, E3
				add.w	#0x30, R5
				
				mov.b	R5L, @ER6	; ascii to num_buffer
				inc		#1, E1		; inc E1 num_buffer counter
				inc		#1, ER6
				
				cmp.w	#0x0, R3
				beq		end_hex_ascii
				jmp		hex_ascii1
				
end_hex_ascii:	;mov.w	#0x0, E1
				;mov.l	#0x20, ER5
				;mov.b	R5L, @ER6
				dec		#1, ER6
				dec		#1, R1		; dec num of words in final
				mov.l	#0x0, ER5
				rts
				