#include <p16F886.inc>
#define DS4 PORTB, 3
#define SW2 PORTB, 5

    __CONFIG _CONFIG1, _LVP_OFF & _FCMEN_OFF & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
    __CONFIG _CONFIG2, _WRT_OFF & _BOR21V

    cblock 0x70
	D1
	D2
	D3
    endc

ORG 0

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

    ; init OSCCON (oscillator)
    banksel OSCCON
    clrf OSCCON
    
    ; sets frequency to 8 MHz
    bsf OSCCON, 6
    bsf OSCCON, 5
    bsf OSCCON, 4

    movlw B'00000100'
    movwf D3

blink_DS4: ; main function
    banksel PORTB
    bcf PORTB, 3
    call delay
    bsf PORTB, 3
    call delay

    goto blink_DS4

; this is at 0.25 second intervals
delay:
    nop ; 1 cycle
    decfsz D1,F ; 1 cycle
    goto delay ; 2 cycles
    nop ; 1 cycle

    decfsz D2,F ; 1 cycle
    goto delay ; 2 cycles
    
    decfsz D3,F
    goto delay

    movlw B'00000100'
    movwf D3
    return

end