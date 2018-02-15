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
counter	.byte 0

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
SetupP1		bis.b 	#11111111b,&P1DIR ; ALL P1 LEDS` ACTIVE
SetupP2 	bic.b	#00000100b,&P2DIR ; INPUT/BUTTON3
SetupP3 	bic.b	#00000010b,&P2DIR ; INPUT/BUTTON3
			mov.b	counter,&P1OUT


Mainloop	bit.b 	#00000010b,&P2IN ; TEST BUTTON3
			jnz		Reset
			bit.b 	#00000100b,&P2IN ; TEST BUTTON3
			jnz 	PRESS
			jmp		Timer


PRESS		inc.b	counter
			mov.b	counter,&P1OUT


Loop		bit.b 	#00000100b,&P2IN ; TEST BUTTON3
			jnz 	Loop
			jmp		Timer

Reset		mov.b	#0000000b,counter
			mov.b	counter,&P1OUT
			jmp		Mainloop




Timer 		mov.w	#050000 , R15		; Delay to R15
L1 			dec.w	R15					; Decrement R15
			jnz		L1 					; Delay over ?
			jmp		Mainloop				; Again


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
            
