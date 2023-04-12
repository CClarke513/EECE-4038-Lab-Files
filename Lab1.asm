#include <p16F886.inc>
#define SW2 PORTB, 5
    
    __CONFIG _CONFIG1, _LVP_OFF & _FCMEN_OFF & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
    __CONFIG _CONFIG2, _WRT_OFF & _BOR21V
    
    cblock 0x70

D1
D2

endc
    
ORG 0

; call init_D3

start:
    banksel ANSELH;
    CLRF ANSELH;
    MOVLW B'00000000';
    MOVWF ANSELH;
    
    banksel PORTB ; init PORT B
    CLRF PORTB;
    
    banksel TRISB;
    MOVLW B'11110000';
    MOVWF TRISB;
    
OFFLoop:
    banksel PORTB;
    bcf PORTB, 3 ; this turns off LED B1
    
    banksel PORTB
    btfsc SW2
    goto OFFLoop
    call Delay_Is
    
    goto ONLoop

ONLoop:
    banksel PORTB
    bsf PORTB, 3 ; this turns on LED B1

    banksel PORTB
    btfsc SW2 ; this checks if button is activated
    goto ONLoop
    call Delay_Is

    goto OFFLoop

Delay_Is:
    
    nop
    decfsz D1,f
    goto Delay_Is
    nop
    decfsz D2,f
    goto Delay_Is
    return

end