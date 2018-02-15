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

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

init_INT	bis.b #040h,&P2IE ; enable interrupt at P2.6
			and.b #0BFh ,&P2SEL ; set 0 P2SEL.6
			and.b #0BFh ,&P2SEL2 ; set 0 P2SEL2 .6

			bis.b #040h,& P2IES ; high -to -low interrupt mode
			clr &P2IFG ; clear the flag
			eint ; enable interrupts
			bis.b	#01d,&P2OUT

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
Setup	mov.b	#0,&P1OUT
		mov.b   #0FFFh,&P1DIR
		mov.w	#array,R6
		mov.b	#0h,R10
		mov.b	#0h,R7
		mov.b	#lastElement,R8


Start1	mov.w #array,R6
		;inc R6
Count1 	mov.b @R6,&P1OUT
		cmp.b	R10,R7
		jnz	Inte1
		inc R6
		inc R6
		call #Delay
		cmp #lastElement,R6
		jge Start1
		jmp  Count1

Start2	mov.w #array,R6
		inc R6
Count2 	mov.b @R6,&P1OUT
		cmp.b	R10,R7
		jnz	Inte2
		inc R6
		inc R6
		call #Delay
		cmp #lastElement,R6
		jge Start2
		jmp  Count2



Delay    mov.w   #0Ah ,R14
L2       mov.w   #07A00h ,R15
L1       dec.w   R15
		 jnz     L1
		 dec.w   R14
		 jnz     L2
		 ret

Inte1	dec R6
		mov.b	R10,R7
		jmp Count2

Inte2	dec R6
		mov.b	R10,R7
		jmp Count1

ISR		dint

		xor.b	#1h,R10
		clr	&P2IFG

		eint
		reti
		;Integer array

array	.byte  00111111b, 00000110b, 01011011b, 01001111b, 01100110b, 01101101b, 01111101b, 00000111b, 01111111b, 01101111b
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
            .sect	".int03"
	    	.short	ISR

