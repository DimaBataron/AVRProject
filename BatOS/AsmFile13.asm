/*
 * AsmFile13.asm
 *
 *  Created: 04.06.2021 1:16:42
 *   Author: dima
 * ��������� ��������-��������� TWI ������������ ����� � ���
 */ 
 .include "F:/AVR/7.0/packs/atmel/ATmega_DFP/1.6.364/avrasm/inc/m328Pdef.inc"
 .include "E:/A/AssemblerApplication1/AssemblerApplication1/Macro.inc"
; FLASH ===================================================
;������������� �����
.org 0x0000 jmp RESET ; Reset Handler
.org 0x0002 reti; jmp EXT_INT0 ; IRQ0 Handler
.org 0x0004 reti; jmp EXT_INT1 ; IRQ1 Handler
.org 0x0006 reti; jmp PCINT0 ; PCINT0 Handler
.org 0x0008 reti; jmp PCINT1 ; PCINT1 Handler
.org 0x000A reti; jmp PCINT2 ; PCINT2 Handler
.org 0x000C reti; jmp WDT ; Watchdog Timer Handler
.org 0x000E reti; jmp TIM2_COMPA ; Timer2 Compare A Handler
.org 0x0010 reti; jmp TIM2_COMPB ; Timer2 Compare B Handler
.org 0x0012 reti; jmp TIM2_OVF ; Timer2 Overflow Handler
.org 0x0014 reti; jmp TIM1_CAPT ; Timer1 Capture Handler
.org 0x0016 reti; jmp TIM1_COMPA ; Timer1 Compare A Handler
.org 0x0018 reti; jmp TIM1_COMPB ; Timer1 Compare B Handler
.org 0x001A reti; jmp TIM1_OVF ; Timer1 Overflow Handler
.org 0x001C reti; jmp TIM0_COMPA ; Timer0 Compare A Handler
.org 0x001E reti; jmp TIM0_COMPB ; Timer0 Compare B Handler
.org 0x0020 reti; Timer0 Overflow Handler
.org 0x0022 reti ; SPI Transfer Complete Handler
.org 0x0024 reti; jmp USART_RXC ; USART, RX Complete Handler
.org 0x0026 reti; jmp USART_UDRE ; USART, UDR Empty Handler
.org 0x0028 reti; jmp USART_TXC ; USART, TX Complete Handler
.org 0x002A reti; jmp ADC ; ADC Conversion Complete Handler
.org 0x002C reti; jmp EE_RDY ; EEPROM Ready Handler
.org 0x002E reti; jmp ANA_COMP ; Analog Comparator Handler
.org 0x0030 jmp Eve_TWI; jmp TWI ; 2-wire Serial Interface Handler
.org 0x0032 reti; jmp SPM_RDY ; Store Program Memory Ready Handler
.ORG   INT_VECTORS_SIZE      	; ����� ������� ���������
;
.DSEG Number : .byte 800
;
.CSEG
;================================================================================ 
 Reset:	LDI R16,Low(RAMEND)	; ������������� �����
		OUT SPL,R16		; �����������!!!
		LDI R16,High(RAMEND)
		OUT SPH,R16
		jmp START
;=========================================================================
;R18 R19 R16 R20   ������������ � TWI
Eve_TWI :	DIN r18,TWSR
			DIN r16,SREG ;��������� ������ � �����
			push r16
;
			cpi r18,0x60 ;��������
			BRNE P0x60 ;������� ���� �� �����
;			
;��� ������ ����� SLA+W � ������� �������������
			ldi r16,0b11000101 
			DOUT TWCR,r16 ;���� ����� � �������
			pop r16
			DOUT SREG,r16
			reti ;����� �� ����������
;
P0x60 :		cpi r18,0x80
			BRNE P0x80 ;������� ���� �� �����
;
;���������� ��� ���������� ��� ������ ���� ������ � ������� ��������������
			DIN r19,TWDR
			ST Y+,r19 ;���������� ������ � ����������
			inc r20	  ;C����� ���������� ����
			ldi r16,0b11000101 ; ����� ������ ���� ������ � ������� �������������
			DOUT TWCR,r16
			pop r16
			DOUT SREG,r16
			reti
;
P0x80 :		cpi r18,0xA0
			BRNE P0xA0 ;������� ���� �� �����
			;��������� ���� ���� P
			ldi r16,0b11000101
			DOUT TWCR,r16 ;���� �����? ����� ��������
;			
			pop r16
			DOUT SREG,r16
P0xA0 :		reti
;===========================================================================
START:  sei		;�������� ����������
		LDI YL,low(Number) ;Y=R29:R28 ��������� ���������� ��� �������� � 
		LDI YH,High(Number);����������
		ldi r20,0; ������� ���������� �������� ����<<<<<-------------
		ldi r16,0b01111000
		DOUT TWAR,r16	;���������� ����� ����������
		ldi r16,0b01000101 ;���� ������� ������
		DOUT TWCR,r16
;=======================================================================
Main:	nop
		nop
		nop
		nop
		nop
		nop
		RJMP Main
;==========================================================================
;	
;������������
;����� Vin
;����� Gnd
;����� Rst
;������� D11
;���������� D12
;������ D13

;PC4=SDA=A4   ������ TWI
;PC5=SCL=A5