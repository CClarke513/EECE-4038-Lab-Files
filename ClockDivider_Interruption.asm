#include <p16F886.inc>
#define DS4 PORTB, 3

    __CONFIG _CONFIG1, _LVP_OFF & _FCMEN_OFF & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
    __CONFIG _CONFIG2, _WRT_OFF & _BOR21V

    cblock 0x70
	D1
	D2
    endc

ORG 0

goto start

ORG 0x4

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

    ; init OSCCON (oscillator)
    banksel OSCCON
    clrf OSCCON
    
    ; sets frequency to 250 kHz
    bcf OSCCON, 6
    bsf OSCCON, 5
    bcf OSCCON, 4

    ; sets up option register things and sets up timer in proper mode
    clrwdt
    banksel OPTION_REG
    movlw B'11010110' ; mask TMR0 select and prescaler bits
    movwf OPTION_REG

    bsf INTCON, 7
    bsf INTCON, 5
    bcf INTCON, 2

    banksel PORTB
    bsf PORTB, 3

    banksel TMR0
    movlw 0xC
    movwf TMR0
    

; this is supposed to be an infinite loop by design
mainFunction:
    goto mainFunction

interruptFunction:

    banksel PORTB
    movlw 0x8 ; move to new memory address
    xorwf PORTB, 1
    banksel TMR0
    movlw 0xC
    movwf TMR0
    bcf INTCON, T0IF
    retfie

end