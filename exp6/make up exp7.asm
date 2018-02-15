;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.
	    .data
seconds	.byte 00h
centiseconds	.byte 00h
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
SetupP1  	bis.b #11111111b, &P1DIR
SetupP2  	bis.b #00001111b, &P2DIR

init_INT	bis.b #040h,&P2IE ; enable interrupt at P2.6
			and.b #0BFh ,&P2SEL ; set 0 P2SEL.6
			and.b #0BFh ,&P2SEL2 ; set 0 P2SEL2 .6

			bis.b #040h,& P2IES ; high -to -low interrupt mode
			clr &P2IFG ; clear the flag
			clr &TAIFG
			clr &CCIFG

			mov.w #0000001000010000b, &TA0CTL
			mov.w #0010011100010000b, &TA0CCTL0
			mov.w #0000000000010000b, &TA0CCR0  ;#0010011100010000b #0010h

			eint ; enable interrupts

			;mov.w seconds,R5
			;mov.w centiseconds,R6
			mov.b #00h,R5
			mov.b #00h,R6
			mov.w #array,R7
			
			mov.b #00001111b,R9
			mov.b #11110000b,R8
			mov.b #00001111b,R11
			mov.b #11110000b,R10
			
Mainloop	;seconds
			and.w R5,R8 ;and.b ????????????
			rra.w R8
			rra.w R8
			rra.w R8
			rra.w R8
			
			push.w R8  ;MSB
			call #BCD
			pop R8
						;LSB
			and.w R5,R9	;??????????????????????
			push.w R9
			call #BCD
			pop R9
			
;;;;;;;;;;;;;;;;;;;;centiseconds;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
			and.w R6,R10
			rra.w R10
			rra.w R10
			rra.w R10
			rra.w R10
			
			push.w R10  ;MSB
			call #BCD
			pop R10
			
			and.w R5,R11	;??????????????????????
			push.w R11
			call #BCD
			pop R11
			
;;;;;;;;;;;;;;;;;;;;;;;;Display on the 7-Segment ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			mov.w	#00001000b, &P2OUT
			mov.w	R11, &P1OUT
			clr		&P1OUT
			
			mov.w	#00000100b, &P2OUT
			mov.w	R10, &P1OUT
			clr		&P1OUT

			mov.w	#00000010b, &P2OUT
			mov.w	R9, &P1OUT
			clr		&P1OUT
			
			mov.w	#00000001b, &P2OUT
			mov.w	R8, &P1OUT
			clr		&P1OUT

			mov.b	#11110000b, R5				;msb second
			mov.b	#00001111b, R6				;lsb second
			mov.b	#11110000b, R7				;msb csecond
			mov.b	#00001111b, R8				;lsb csecond
			
   			jmp  Mainloop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BCD:
			mov 2(SP),R15 			; get var1 from stack
isZero		cmp.b #00000000b, R15
			jnz		isOne
			mov.b #00111111b, R15
			mov R15,2(SP)
			ret

isOne		cmp.b #00000001b, R15
			jnz		isTwo
			mov.b #00000110b, R15
			mov R15,2(SP)
			ret

isTwo		cmp.b #00000010b, R15
			jnz		isTree
			mov.b #01011011b, R15
			mov R15,2(SP)
			ret


isTree		cmp.b #00000011b, R15
			jnz		isFour
			mov.b #01001111b, R15
			mov R15,2(SP)
			ret
			
isFour		cmp.b #00000100b, R15
			jnz		isFive
			mov.b #01100110b, R15
			mov R15,2(SP)
			ret

isFive		cmp.b #00000101b, R15
			jnz		isSix
			mov.b #01101101b, R15
			mov R15,2(SP)
			ret

isSix		cmp.b #00000110b, R15
			jnz		isSeven
			mov.b #01111101b, R15
			mov R15,2(SP)
			ret

isSeven		cmp.b #00000111b, R15
			jnz		isEight
			mov.b #00000111b, R15
			mov R15,2(SP)
			ret

isEight		cmp.b #00001000b, R15
			jnz		isNine
			mov.b #01111111b, R15
			mov R15,2(SP)
			ret

isNine		cmp.b #00001001b, R15
			jnz		finish
			mov.b #01100111b, R15
			mov R15,2(SP)
finish		ret ; return from stack


ISR		dint
		xor.w	#0000000000010000h,&TA0CTL
		clr	&P2IFG ;;;;;;;;;;;;;;;????
		clr &TAIFG
		clr &CCIFG
		eint
		reti
		
TISR	dint
count	inc.b	R6
		cmp.b #64h,R6
		jnz coınt
		mov.b #00h,R6
		inc.b R5
		clr &TAIFG ;;;;;;;??????
		clr &CCIFG
		clr &TA0R
		eint
		reti

array  .byte 00111111b, 00000110b, 01011011b, 01001111b, 01100110b, 01101101b, 01111101b,00000111b, 01111111b, 01101111b
lastElement
                                            
;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            .sect ".int03"
	    	.short ISR
	    	.sect ".int09"
	    	.short TISR
