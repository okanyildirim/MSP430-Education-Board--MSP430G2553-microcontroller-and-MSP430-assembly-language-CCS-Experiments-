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
SetupP1	bis.b 	#00000010b,&P1DIR 	; OUTPUT/LED 2
SetupP2 	bic.b	#00000100b,&P2DIR 	; INPUT/BUTTON3
		bic.b	#00000010b,&P1OUT 	 ; CLEAR LED2
			
Mainloop	bit.b 	#00000100b,&P2IN 	; TEST BUTTON3
		jnz 	ON
		bic.b	#00000010b,&P1OUT  	; CLEAR LED2
		jmp		Mainloop
			
ON		bis.b 	#00000010b,&P1OUT
		jmp		Mainloop


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
            
