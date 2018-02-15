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

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
SetupP1 	bis.b	#0FFh, & P1DIR		
Mainloop	mov.b	#001h, & P1OUT		
		jmp		Timer
ShiftLeft	rlc.w	& P1OUT
		cmp		#080h,& P1OUT
		jeq		ShiftRight
		jmp		Timer
ShiftRight	jmp 	Timer2
L1		rrc.w	&P1OUT
		cmp	#001h,& P1OUT
		jeq	Mainloop
		jmp 	Timer2
Timer 		mov.w	#050000, R15		
L2 		dec.w	R15					
		jnz	L2 					
		clrc
		jmp	ShiftLeft				
Timer2 		mov.w	#050000, R15		
L3 		dec.w	R15					
		jnz	L3 					
		clrc
		jmp	L1	

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
            




