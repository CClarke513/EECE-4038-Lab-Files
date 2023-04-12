#include <p16F886.inc>

#define SW1 PORTE, 3
#define SW2 PORTB, 5

#define DS1 PORTB, 0
#define DS2 PORTB, 1
#define DS3 PORTB, 2
#define DS4 PORTB, 3

    __CONFIG _CONFIG1, _LVP_OFF & _FCMEN_OFF & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
    __CONFIG _CONFIG2, _WRT_OFF & _BOR21V

    cblock 0x70
	inputNumberOne
	inputNumberTwo
	controlData
	counterOne
	counterTwo
	outputValue
    endc

RST code 0x0
    call start
    call MainFunction

interruptionFunction code 0x4
    call delay
    banksel PORTB

    btfsc controlData, 0x0
    goto pressFirstTime

    btfsc controlData, 0x1
    goto pressSecondTime

    goto pressThirdTime

; Initial setup code
start:
    ; Select digital mode
    banksel ANSELH
    clrf ANSELH
    
    ; Set pin I/O modes
    banksel TRISB
    movlw B'11110000'
    movwf TRISB

    banksel TRISE
    movlw B'11110000'
    movwf TRISE
    
    ; init PORTB
    banksel PORTB
    clrf PORTB

    ; init PORTE
    banksel PORTE
    clrf PORTE

    ; init OSCCON (oscillator)
    banksel OSCCON
    clrf OSCCON

    ; set frequency to 2 MHz
    bsf OSCCON, 6
    bcf OSCCON, 5
    bsf OSCCON, 4

    ; allow interrupts - this is going to be on SW2
    banksel IOCB
    clrf IOCB
    bsf IOCB, 5
    
    movlw B'10001000' ; bit 7: enable interrupts at all;
    ; bit 3: enable PORTB interrupts
    movwf INTCON

    bsf controlData, 0x0

    return

DS1_On:
    banksel PORTB
    bsf PORTB, 0
    return

DS1_Off:
    banksel PORTB
    bcf PORTB, 0
    return

DS2_On:
    banksel PORTB
    bsf PORTB, 1
    return

DS2_Off:
    banksel PORTB
    bcf PORTB, 1
    return

DS3_On:
    banksel PORTB
    bsf PORTB, 2
    return

DS3_Off:
    banksel PORTB
    bcf PORTB, 2
    return

pressFirstTime:
    banksel PORTB
    movf PORTB, 0
    movwf inputNumberOne
    
    ;clear leds
    clrf PORTB
    ;bsf PORTB, 0x1
    bcf controlData, 0x0
    bsf controlData, 0x1
    banksel INTCON
    movlw B'10001000' ; bit 7: enable interrupts at all;
    ; bit 3: enable PORTB interrupts
    movwf INTCON
    retfie

pressSecondTime:
    ;save leds 2
    banksel PORTB
    movf PORTB, 0
    movwf inputNumberTwo
    
    ;call addition routine
    call AdditionFunction
    ;output result to leds
    movf outputValue, 0x0
    movwf PORTB
    ;bsf PORTB, 0x2
    bcf controlData, 0x1
    bsf controlData, 0x2
    banksel INTCON
    movlw B'10001000' ; bit 7: enable interrupts at all;
    ; bit 3: enable PORTB interrupts
    movwf INTCON
    retfie
pressThirdTime:
    ;clear leds
    banksel PORTB
    clrf PORTB
    ;bsf PORTB, 0x0
    bcf controlData, 0x2
    bsf controlData, 0x0
    banksel INTCON
    movlw B'10001000' ; bit 7: enable interrupts at all;
    ; bit 3: enable PORTB interrupts
    movwf INTCON
    retfie
    
MainFunction:
    btfsc controlData, 0x2
    goto MainFunction

    banksel PORTE
    btfsc SW1
    goto MainFunction
    call Increment
    call delay

    goto MainFunction

Increment:
    banksel PORTB
    btfss PORTB, 0
    goto DS1_On
    call DS1_Off

    btfss PORTB, 1
    goto DS2_On
    call DS2_Off

    btfss PORTB, 2
    goto DS3_On
    call DS3_Off

    return
    

FirstNumberCounter:
    banksel PORTE
    btfsc SW1

    goto FirstNumberCounter
    call delay

    incf inputNumberOne, 0x1 ; increment counter by 1
    movlw inputNumberOne
    movfw PORTB

SecondNumberCounter:
    clrf PORTB
    banksel PORTB
    btfsc SW1

    goto SecondNumberCounter
    call delay

    incf inputNumberTwo, 0x1 ; increment counter by 1
    movlw inputNumberTwo
    movwf PORTB


AdditionFunction:
    movf inputNumberTwo, 0x0
    addwf inputNumberOne, 0x0 ; takes whatever is in register f and w adds and stores in w
    movwf outputValue
    
    return

delay:
    nop ; 1 cycle
    decfsz counterOne,F ; 1 cycle
    goto delay ; 2 cycles
    nop ;1 cycle
    decfsz counterTwo,F ; 1 cycle
    goto delay ; 2 cycles
    return

end