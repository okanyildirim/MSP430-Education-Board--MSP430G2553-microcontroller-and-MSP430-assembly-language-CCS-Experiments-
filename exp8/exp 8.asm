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


;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

Setup   		clr.b &P2SEL				;clear the flags
				clr.b &P2SEL2
				mov.w #300h,SP				; initialize the stack
				mov.b #0ffh, &P1DIR			;set all P1DIR
				mov.b #11010000b, &P2DIR   ;set only uppest two P2DIR	mov.b #0ffh, &P2DIR
				
Main			call #initLCD				;initialize LCD
				call #Open					;Open LCD
				call #initTemp				;initialize and reset DS18B20 

				mov.b #0CCh,R13				;We only use single slave so that we send command to DS18B20 for skipping ROM
   				call  #Write				; Write this command

   				mov.b #044h,R13				; We send the command to start to measure and convert the temperature
  				call  #Write

   				call #initTemp				; initialize and reset DS18B20  again

  				mov.b #0CCh,R13				;We only use single slave so that we send command to DS18B20 for skipping ROM
   				call #Write

   				mov.b #0BEh,R13				; We send the command to read scratchpad
   				call #Write

   				call #Read					; Read the LSB of data from DS18B20

   				push.w R13					; r13=0000LSB push to stack
   				call #Read					; Read the MSB of data from DS18B20
   				swpb R13					;swap byte for adding MSB part R12=MSB0000
   				add.w @SP+,R13				; R13=MSB+LSB

				call #Print
				jmp Main			

;;;;;;;;;;;;;;;Print subrouitineis similar to the previous experiment7;;;;;;;;;;;;;;;
Print			call #sendDATA
				mov.b R13, R6			;assign R13 (temperature data) to R6 and display it on the LED 
				cmp.b #000h, R6 		;control
				jz end					;if finish jump to finish and end up print
				cmp.b #00Dh, R6 		;control
				jz nextLine				; if char=\n go to nextLine label
				mov.b R6, &P1OUT		; send the data to the LCD, yet only upper 4 bits
				call #triggerEn			; enable it
				rla.b R6				; for sending other 4 bits of data 
				rla.b R6
				rla.b R6
				rla.b R6
				mov.b R6, &P1OUT		;send remain 4 bits to the LCD
				call #triggerEn			;enable it
				call #Delay100			; delay needed
				inc.w R5
				jmp Print
nextLine		call #sendCMD			; write on second line
				mov.b #10100000b,&P1OUT;set the DDRAM address to 40 - upper 4bits
				call #triggerEn
				mov.b #10000000b,&P1OUT;lower 4bits
				call #triggerEn
				call #Delay100
				inc.w R5				; next character, remain characters are printed on second line
				jmp Print
end				mov.b #000h, &P1OUT
				ret
;;;;;;;;;;;;;;;;;;;;;initLCD is similar to the previous experiment7;;;;;;;;;
initLCD		mov.b	#00000000b,&P2OUT ;clear RS so that send commmand to LCD
			call #triggerEN
			call #delay100		;more than 100ms		

			mov.b	#00110000b,&P1OUT	;Special case of 'Function Set' (lower four bits are irrelevant)
			call #triggerEN
			call #delay100		; more than4.1 ms

			mov.b	#00110000b,&P1OUT ;Special case of 'Function Set' (lower four bits are irrelevant)
			call #triggerEN
			call #delay100	;more than 100us

			mov.b	#00110000b,&P1OUT;Special case of 'Function Set' (lower four bits are irrelevant)
			call #triggerEN
			call #delay100	;more than 100us

			mov.b	#00100000b,&P1OUT ;nitial 'Function Set' to change interface (lower four bits are irrelevant)
			call #triggerEN
			call #delay100	;more than 100us

			;*******************8 bit to 4 bit *************************

			mov.b	#00100000b,&P1OUT ;upper 4bits
			call #triggerEN
			mov.b	#10000000b,&P1OUT	;lower 4bits 'Function Set' (I = 1, N=1 it means I use secondline also )
			call #triggerEN
			call #delay100	;;more than 100us

			;upper 4bits
			mov.b	#00000000b,&P1OUT	;'Display ON/OFF Control'	(D=1, C=0, B=0 )
			call #triggerEN
			mov.b	#10000000b,&P1OUT	;lower 4bits
			call #triggerEN
			call #delay100

			;upper 4bits
			mov.b	#00000000b,&P1OUT	;'Clear Display' (no configurable bits )
			call #triggerEN
			mov.b	#00010000b,&P1OUT	;lower 4bits
			call #triggerEN
			call #delay100

			mov.b	#00000000b,&P1OUT ;upper 4bits -- Entry mod set I/D =1 cursor move direction
			call #triggerEN				;							S=0 not shift the display
			mov.b	#01100000b,&P1OUT	;lower 4bits
			call #triggerEN
			ret

Open		mov.b #00000000b,&P2OUT	;clear RS so that send commmand to LCD
			mov.b #00000000b,&P1OUT		;upper 4bits -- 'Display ON/OFF Control'(D=1, C=1, B=1 )
			call #triggerEN             ; we want to display cursor and blink of cursor also
			mov.b	#11110000b,&P1OUT;;lower 4bits 
			call #triggerEN
			ret
;;;;;;;;;;;; Send CMD, sendDATA and triggerEn subrouitines are similar to the previous experiment7;;;;;;;
sendCMD			mov.b #000h, &P2OUT
				ret

sendDATA		mov.b #10000000b, &P2OUT		; These are used in initLCD and Print when needed
				ret
				
triggerEn  		bis.b #01000000b, &P2OUT
    			bic.b #01000000b, &P2OUT
    			ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;DS18B20 PART;;;;;;;;;;;;;;;;;;;;;;;
initTemp		mov.b #00010000b, &P2DIR
				mov.b #00000000b, &P2OUT ;reset pulse
				call  #delay480			; delay 480 us
				mov.b #00000000b, &P2DIR ;release
				call  #delay60
isread  		cmp.b #00000000b, &P2IN ; check for response
				jnz  isread
				ret

Write			mov.w #8h,R7 ;for each bit of data
A0		 		bis.b #00010000b,&P2DIR ;
				call #delay60 ; ~ 60us delay 
				rrc.b R13 ;rotate 
				jc A1 ;check for carry bit
				jmp A2 ;
A1 				bis.b #00010000b,&P2DIR ;
				bic.b #00010000b,&P2DIR ;
				call #delay60 ; ~ 60us delay 
				jnz A0 ;
				ret ;
				;IN similar way to Write 
Read			mov.w #8h,R7 ;for each bit of data
B0 				bis.b #00010000b,&P2DIR ;
				bic.b #00010000b,&P2DIR ;
				bit.b #00010000b,&P2IN ; check for input==1
				rrc.b R13 ;rotate 
				call #delay60 ;  60us delay 
				dec.w R7 ;
				jnz B0 ;
				ret ;
;;;;;;;;;;;;;;;;;;;;;;;;DELAYS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Delay100   		mov.w #001h, R14   				;Delay 100ms
L1    			dec.w R15
    			jnz   L1
    			dec.w R14
    			jnz   L2
    			ret
Delay200   		mov.w #002h, R14   				;Delay 200ms 
L20    			mov.w #07A00h, R15
L21    			dec.w R15
    			jnz   L21
    			dec.w R14
    			jnz   L20
    			ret

Delay800   		mov.w #008h, R14   				;Delay 800ms 
L10    			mov.w #07A00h, R15
L9   			dec.w R15
    			jnz   L9
    			dec.w R14
    			jnz   L10
    			ret

delay60  		mov.w #0001h, r14
L8   			mov.w #0012h, r15 ;   60 micro saniye
L7   			dec.w r15
				jnz  L7
				dec.w r14
				jnz  L8
				ret

delay480  		mov.w #008h, r14
L4   			mov.w #0012h, r15   ;  about 480 micro saniye
L3   			dec.w r15
				jnz  L3
				dec.w r14
				jnz  L4
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

