/*
 * AsmFile12.asm
 *
 *  Created: 03.06.2021 17:36:33
 *   Author: dima
 *	������� ���������� ��� �������� �� TWI.
 */ 
 .include "F:/AVR/7.0/packs/atmel/ATmega_DFP/1.6.364/avrasm/inc/m328Pdef.inc"
 .include "E:/A/AssemblerApplication1/AssemblerApplication1/Macro.inc"
; Replace with your application code
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
.org 0x0020 reti ; Timer0 Overflow Handler
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
.DSEG
NumByte :	.byte 1 ;���������� ��������� ���� 
Adr		:	.byte 1 ;����� �������� ����������
NumTr	:	.byte 1 ;���������� ������� ����
TrBytes	:	.byte 2 ;����������� �����
.CSEG
;
 Reset:	LDI R16,Low(RAMEND)	; ������������� �����
		OUT SPL,R16		; �����������!!!
		LDI R16,High(RAMEND)
		OUT SPH,R16
;
	sei		;�������� ����������
	TWFscl 70,0 ;������ 102.6��� ������� ������ TWI Fscl
;
	ldi r21,0 ;������� ���������� ����
	sts NumByte,r21
	ldi r20,0b10100101 ;��������� ��������� ����� �� ���� TWI
	DOUT TWCR,r20
;
	ldi r20,3
	sts TrBytes,r20
	ldi r20,5
	sts TrBytes+1,r20 ;��������� ������ ��� �������� � ����������
	;
	ldi r20,2
	sts NumTr,r20 ;���������� �������
	;
	ldi r20,0b01010100
	sts Adr,r20 ;���� ������������
	;
	LDI	YL,low(TrBytes) ;����� ��������!! ����� � ��������� ������ ������� ��� ��������
	LDI	YH,High(TrBytes) ;Y=29:28
;
Start:	nop
		nop
		nop
		nop
		RJMP Start;


;==================================================================
Eve_TWI :	DIN r18,TWSR ;������� ��� �������
			DIN r21,SREG ;��������� ������ ������� � �����
			push r21
;
			cpi r18,0x08 ;��������
			BRNE P0x08 ;������� ���� �� �����
;			
			;C��� ������� ���� ������� ������������ ��������� �����
Tr_Adr :	lds r19,Adr
			;ldi r19,0b01010100 ;8 ��� R/W= 0 ������ �������� ������
			DOUT TWDR,r19 ;����� ������ � ����� ��������
			ldi r19,0b10000101 ;����� �������� ��������� ������
			DOUT TWCR,r19
			pop r21
			DOUT SREG,r21
			reti ;����� �� ����������
;
P0x08 :		cpi r18,0x18
			BRNE P0x18 ;������� ���� �� �����
;
			;���� ���� ��� ������� ����� � ������� �������������
F_Tr :		lds r21,NumByte ;���������� ���������� ����
			lds r20,NumTr ;���������� ������� ������
			cp r20,r21
			;cpi r21,2 ;���������� ���������� ����
			BRNE Tr  ;��������� �� ���������� ������������ ������
;			
			;���� ���� �������� ��� �����
			ldi r20,0b10010101
			DOUT TWCR,r20
			pop r21
			DOUT SREG,r21
			reti
;
			;�� ����� �������� ���
			Ne :	lds r21,NumByte ;���������� ���������� ����
					inc r21 ;����������� ������� ���������� ���� 
					sts NumByte,r21
					ldi r20,0b10000101
					DOUT TWCR,r20 ;�������� ������
					pop r21
					DOUT SREG,r21
					reti
;
P0x18 :		cpi r18,0x20	
			BRNE P0x20 ;������� ���� �� �����
;
			;��� ������� ����� � �� ������� �������������
			ldi r20,0b10100101 ;�������� ��������� ��������
			DOUT TWCR,r20
			pop r21
			DOUT SREG,r21
			reti
;
P0x20 :		cpi r18,0x28
			BRNE P0x28 ;������� ���� �� �����
;			
			;C��� ���� ��� ������� ����� ������ � ������� �������������
			rjmp F_Tr ;
;
P0x28 :		cpi r18,0x30
			BRNE P0x30
;
			;��� ������� ����� ������ ������������� �� �������
			ldi r20,0b00000001 ;������� �� �� ������ �����
			DOUT TWDR,r20		;����� ����� ����������
;
P0x30 :		cpi r18,0x10
			BRNE P0x10
			;���� ������������ ��������� ��������
			rjmp Tr_Adr
;			
P0x10 :		pop r21
			DOUT SREG,r21
			reti
;=======================================================================
;��������� ������������ ������� ������ ��� TWI
Tr :		ld r21,Y+
			DOUT TWDR,r21
			rjmp Ne
;=======================================================================
;Call-used registers (r18-r27, r30-r31). ��������, ������������ ��� ������� �������.
; ����� ���� ������ ������������ gcc ��� ��������� ������ (����������). 
;�� �������� ������ �� ������������ � ������������� �� ����������, ��� ������������� 
;���������� � �������������� (�� ����� �� ��������� � ���� �������� push � ��������� 
;�� ����� �������� pop).
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
;=====================================================================
;���������� 
;��������� 1 �����
;�������   2 �����