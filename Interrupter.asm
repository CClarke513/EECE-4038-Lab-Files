#include <p16F886.inc>

#define DS1 PORTB,0
#define DS2 PORTB,1
#define DS3 PORTB,2
#define DS4 PORTB,3

    __CONFIG _CONFIG1, _LVP_OFF & _FCMEN_OFF & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
    __CONFIG _CONFIG2, _WRT_OFF & _BOR21V

    ; Declare two global variables used by the delay function.
    CBLOCK 0x70
	D1
	D2
    ENDC

    ORG 0
    goto start
    
    ORG 4
    goto interruptFunction

; Initial setup code
start:
    ; Select digital mode
    banksel ANSELH
    clrf ANSELH
    
    ; Set pin I/O modes
    banksel TRISB
    movlw B'11110000'
    movwf TRISB
    
    ; init PORTB
    banksel PORTB
    clrf PORTB
    
    ; allow interrupts
    banksel IOCB
    clrf IOCB
    bsf IOCB,5
    
    movlw B'10001000' ; bit 7: enable interrupts at all;
    ; bit 3: enable PORTB interrupts
    movwf INTCON

mainLoop:
    BANKSEL PORTB
    BSF DS4
    GOTO mainLoop

; Handle interrupt
interruptFunction:
    ; Turn off DS4
    banksel PORTB
    bcf DS4
    call delay
    
    ; Blink DS1 once
    bsf DS1
    call delay
    bcf DS1
    call delay
    
    ; Blink DS2 once
    bsf DS2
    call delay
    bcf DS2
    call delay
    
    ; Blink DS3 once
    bsf DS3
    call delay
    bcf DS3
    call delay
    
    ; Blink DS4 once
    bsf DS4
    call delay
    bcf DS4
    call delay
    
    ; Go back to normal operation
    bcf INTCON,0
    retfie

; Delay for about a quarter-second.  
delay:
    nop ; 1 cycle
    decfsz D1,F ; 1 cycle
    goto delay ; 2 cycles
    nop ;1 cycle
    decfsz D2,F ; 1 cycle
    goto delay ; 2 cycles
    return

END