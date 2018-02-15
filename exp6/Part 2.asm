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
SetupP1  	bis.b #11111111b, &P1DIR
SetupP2  	bis.b #00001111b, &P2DIR 
 
Mainloop	mov.w #00001000b, &P2OUT    
	 	mov.w  #01001111b,R10    
		mov.b R10,&P1OUT    
		clr  &P1OUT 
 
		mov.w #00000100b, &P2OUT    
		mov.w  #01011011b,R10    
		mov.b R10,&P1OUT    
		clr  &P1OUT 
 
   		mov.w #00000010b, &P2OUT    
		mov.w  #00000110b,R10    
		mov.b R10,&P1OUT    
		clr  &P1OUT 
 
   		mov.w #00000001b, &P2OUT    
		mov.w  #00111111b,R10    
		mov.b  R10,&P1OUT    clr  &P1OUT 
 
   		jmp  Mainloop 

ISR		dint

		xor.b	#1h,R10
		clr	&P2IFG

		eint
		reti
		;Integer array
 
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