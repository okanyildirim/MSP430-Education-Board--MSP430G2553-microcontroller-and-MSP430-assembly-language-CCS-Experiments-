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
data	.byte	10010011b
key		.byte	00010111b
temp  	.byte	00000000b

			.text
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

SetupP1		bis.b #0FFh, &P1DIR
			mov.b data,&P1OUT
			mov.b data,R6
			mov.b data,R5
			clrc

			and.b #00001111b,R5
			and.b #11110000b,R6
			rla.b R5
			rla.b R5
			rla.b R5
			rla.b R5
			clrc
			rrc.b R6
			rrc.b R6
			rrc.b R6
			rrc.b R6
			bis.b R6,R5
			mov.b R5,&P1OUT



			mov.b R5,data
			mov.b data,temp

			and.b #0101010101b,data
			and.b #1010101010b,temp
			clrc
			rrc.b temp
			rla.b data
			bis.b temp,data

			xor.b key,data
			mov.b data,&P1OUT

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
            
