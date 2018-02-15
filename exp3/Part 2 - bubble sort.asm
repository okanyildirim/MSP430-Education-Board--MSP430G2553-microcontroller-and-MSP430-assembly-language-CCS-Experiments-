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
unsorted	.byte 5,-9,12,4,-63,127,79,-128,21,65,-35,97
lastElement
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
Main		mov	#unsorted,R5
			mov #lastElement,R9
			dec R9
			mov	R5,R7
			inc	R7
Start		mov #lastElement,R6
			dec	R6
			mov	R6,R8
			dec	R8

innerloop	cmp.b @R6,0(R8)
			jl	swap
swapped		dec R6
			dec R8
			cmp R6,R5
			jeq	outerloop
			jmp	innerloop

outerloop	inc R5
			inc R7
			cmp R5,R9
			jeq Finish
			jmp Start

swap		mov.b @R6,R10
			mov.b @R8,0(R6)
			mov.b R10,0(R8)
			jmp swapped

Finish		mov	#unsorted,R5
a			mov	R5,&P1OUT
			jmp Timer
display		inc	R5
			cmp R5,R9
			jeq Finish
			jmp a

Timer 		mov.w	#050000 , R15		; Delay to R15
L1 			dec.w	R15					; Decrement R15
			jnz		L1 				; Delay over ?
			jmp		display				; Again


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
            
