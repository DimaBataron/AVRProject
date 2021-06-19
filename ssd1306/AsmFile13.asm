/*
 * AsmFile13.asm
 *
 *  Created: 04.06.2021 1:16:42
 *   Author: dima
 * Программа ведомого-приемника TWI записывающая быйты в ОЗУ
 */ 
 .include "F:/AVR/7.0/packs/atmel/ATmega_DFP/1.6.364/avrasm/inc/m328Pdef.inc"
 .include "E:/A/AssemblerApplication1/AssemblerApplication1/Macro.inc"
; FLASH ===================================================
;Инициализация стэка
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
.ORG   INT_VECTORS_SIZE      	; Конец таблицы прерывани
;
.DSEG Number : .byte 800
;
.CSEG
;================================================================================ 
 Reset:	LDI R16,Low(RAMEND)	; Инициализация стека
		OUT SPL,R16		; Обязательно!!!
		LDI R16,High(RAMEND)
		OUT SPH,R16
		jmp START
;=========================================================================
;R18 R19 R16 R20   используемые в TWI
Eve_TWI :	DIN r18,TWSR
			DIN r16,SREG ;сохраняем регист в стеке
			push r16
;
			cpi r18,0x60 ;сравнить
			BRNE P0x60 ;переход если не равны
;			
;Был принят адрес SLA+W и послано подтверждение
			ldi r16,0b11000101 
			DOUT TWCR,r16 ;ждем байта с данными
			pop r16
			DOUT SREG,r16
			reti ;выход из прерывания
;
P0x60 :		cpi r18,0x80
			BRNE P0x80 ;переход если не равны
;
;Устройство уже адресовано был принят байт данных и послано потдтверждение
			DIN r19,TWDR
			ST Y+,r19 ;Записываем данные в оперативку
			inc r20	  ;Cчитаю записанный байт
			ldi r16,0b11000101 ; будет принят байт данных и послано подтверждение
			DOUT TWCR,r16
			pop r16
			DOUT SREG,r16
			reti
;
P0x80 :		cpi r18,0xA0
			BRNE P0xA0 ;переход если не равны
			;Переходим сюда если P
			ldi r16,0b11000101
			DOUT TWCR,r16 ;Ждем адрес? забыл записать
;			
			pop r16
			DOUT SREG,r16
P0xA0 :		reti
;===========================================================================
START:  sei		;разрешаю прерывания
		LDI YL,low(Number) ;Y=R29:R28 указатель используем для загрузки в 
		LDI YH,High(Number);оперативку
		ldi r20,0; регистр количества принятых байт<<<<<-------------
		ldi r16,0b01111000
		DOUT TWAR,r16	;Записываем адрес устройства
		ldi r16,0b01000101 ;Ждем прихода адреса
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
;Программатор
;Белый Vin
;Серый Gnd
;Синий Rst
;Зеленый D11
;Фиолетовый D12
;Черный D13

;PC4=SDA=A4   Выходы TWI
;PC5=SCL=A5