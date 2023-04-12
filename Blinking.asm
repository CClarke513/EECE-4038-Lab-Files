#include <p16f886.inc>
#define SW2 PORTB,5
#define SW1 PORTE,3

    __CONFIG _CONFIG1, _LVP_OFF & _FCMEN_OFF & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
    __CONFIG _CONFIG2, _WRT_OFF & _BOR21V

    cblock 0x70

D1
D2

endc

ORG 0

start:
    banksel ANSELH    ;make the digital mod
    CLRF ANSELH;
    MOVLW B'00000000';
    MOVWF ANSELH

    banksel PORTB    ;initialize PORTB
    CLRF PORTB;

    banksel PORTE    ;initialize PORTE
    CLRF PORTE;
    bsf SW1

    banksel TRISB ;
    ;bcf TRISB, 0   ;make IO Pin B0\1\2\3 an output, 4567 input
    ;bcf TRISB,1
    ;bcf TRISB,2
    ;bcf TRISB,3
    ;bcf TRISB,5    ;B5 input
    MOVLW B'11110000' ;
    MOVWF TRISB

SW1_blink:
  btfss SW1
  goto SW1_wait_end
  btfss SW2 ; start both LEDs loop
  goto SW12_wait_start
  
  bsf DS1
  call Delay_1s
  bcf DS1
  call Delay_1s
  goto SW1_blink

SW2_blink:
  btfss SW1 ; start both LEDs loop
  goto SW12_wait_start
  btfss SW2
  goto SW2_wait_end

  bsf DS4
  call Delay_1s
  bcf DS4
  call Delay_1s
  goto SW2_blink

SW12_wait_start:
  btfss SW1
  goto SW12_wait_start
  btfss SW2
  goto SW12_wait_start
  goto SW12_blink ; only start SW12_blink if both switches are released

SW12_blink:
  btfss SW1
  goto SW12_wait_SW1_end
  btfss SW2
  goto SW12_wait_SW2_end

  bsf DS1
  bsf DS4
  call Delay_1s
  bcf DS1
  bcf DS4
  call Delay_1s
  goto SW12_blink

end

; todo: SW12_wait_SW1_end --> SW2_blink
;       SW12_wait_SW2_end --> SW1_blink