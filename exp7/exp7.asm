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
 string	byte	"ITU - Comp. Eng.",0Dh,"MC Lab. 2017",00h

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

initLCD		mov.b	#00000000h,&P2OUT
			call #triggerEN
			call #delay1
			
			mov.b	#00110000h,&P1OUT
			call #triggerEN
			call #delay2
			
			mov.b	#00110000b,&P1OUT
			call #triggerEN
			call #delay3
			
			mov.b	#00110000b,&P1OUT
			call #triggerEN
			call #delay3
			
			mov.b	#00110000b,&P1OUT
			call #triggerEN
			call #delay3
			
			mov.b	#00100000b,&P1OUT
			call #triggerEN
			call #delay3
			
			;*******************8 bit to 4 bit *************************
			
			mov.b	#00100000b,&P1OUT
			call #triggerEN
			mov.b	#00001100b,&P1OUT	;10000000h 'Function Set' (I = 1, N and F as required)
			call #triggerEN
			call #delay3
			
			
			mov.b	#00000000b,&P2OUT	;'Display ON/OFF Control'	(D=0, C=0, B=0 ) 
			call #triggerEN
			mov.b	#10000000b,&P2OUT	;
			call #triggerEN
			call #delay3
			
			mov.b	#00000000b,&P2OUT	;'Clear Display' (no configurable bits )
			call #triggerEN
			mov.b	#00010000b,&P2OUT	
			call #triggerEN
			call #delay2
			
			ret
				
				
sendCMD




sendDATA




delay1   mov.w   #0Ah ,R14
L2       mov.w   #0C4E0h ,R15	;3150*10 = 31500 >= 100ms
L1       dec.w   R15
		 jnz     L1
		 dec.w   R14
		 jnz     L2
		 ret

delay2    mov.w   #0Ah ,R14
L4       mov.w   #0820h ,R15	;130*10 = 1300 >= 4.1ms
L3       dec.w   R15
		 jnz     L3
		 dec.w   R14
		 jnz     L4
		 ret
		 
delay3   mov.w   #08h ,R14
L6       mov.w   #04h ,R15	;4*8 = 32 >= 100us
L5       dec.w   R15
		 jnz     L5
		 dec.w   R14
		 jnz     L6
		 ret

triggerEN	bis.b #01000000.b,&P2OUT 
			bic.b #01000000.b,&P2OUT 
			ret




                                            
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
            
