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
result	.bss 	resultArray,5	; above .text section
;Mainloop 
Setup		mov	#array, r5 ;use r5 as the pointer 
			mov #resultArray,r6 
			push r5
			push r6
Mainloop		mov.b @r5,r6 
			push r6
			call #funcl 
			pop.b r5
			pop r6
			mov.b r5,0(r6) 
			pop r5
			inc r5
			inc r6
			push r5
			push r6
			cmp #lastElement,r5
			jlo Mainloop 
			jmp finish 
			
func1			pop r5		; get return address
			pop.b r6	; get r6 
			xor.b #OFFh, r6  ; exchange bits, first step of 2’s complement
			push r5		; strore the return adress
			push.b r6	;store the edited r6 on the stack for passing parameters
			call #func2 
			pop.b r6	; get the parameters from func2
			pop r5		; ; get the parameters from func2
			push.b r6	;store the edited r6 on the stack for passing parameters
			push r5		; top of the stack must be return  address
			ret 
			
func2			pop r5		; get return address
			pop.b r6 	; get r6
			inc.b r6 	; increment r6, second step of 2’s complement
			push.b r6	;store the edited r6 on the stack for passing parameters
			push r5		; top of the stack must be return  address
			ret 			
;Integer array 
array .byte 127,-128,0,55 
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
            
