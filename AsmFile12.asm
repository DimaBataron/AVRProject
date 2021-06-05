/*
 * AsmFile12.asm
 *
 *  Created: 03.06.2021 17:36:33
 *   Author: dima
 *	Ведущий передатчик для передачи по TWI.
 */ 
 .include "F:/AVR/7.0/packs/atmel/ATmega_DFP/1.6.364/avrasm/inc/m328Pdef.inc"
 .include "E:/A/AssemblerApplication1/AssemblerApplication1/Macro.inc"
; Replace with your application code
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
.ORG   INT_VECTORS_SIZE      	; Конец таблицы прерывани
.DSEG
NumByte :	.byte 1 ;количество переданых байт 
Adr		:	.byte 1 ;адрес ведомого устройства
NumTr	:	.byte 1 ;количество посылок байт
TrBytes	:	.byte 2 ;передаваемы байты
.CSEG
;
 Reset:	LDI R16,Low(RAMEND)	; Инициализация стека
		OUT SPL,R16		; Обязательно!!!
		LDI R16,High(RAMEND)
		OUT SPH,R16
;
	sei		;разрешаю прерывания
	TWFscl 70,0 ;ставлю 102.6кГЦ скороть работы TWI Fscl
;
	ldi r21,0 ;счетчик переданных байт
	sts NumByte,r21
	ldi r20,0b10100101 ;формируем состояние СТАРТ на шине TWI
	DOUT TWCR,r20
;
	ldi r20,3
	sts TrBytes,r20
	ldi r20,5
	sts TrBytes+1,r20 ;Записываю данные для передачи в оперативку
	;
	ldi r20,2
	sts NumTr,r20 ;количество посылок
	;
	ldi r20,0b01010100
	sts Adr,r20 ;Дрес принимающего
	;
	LDI	YL,low(TrBytes) ;здесь внимание!! Далее в программе нельзя трогать эти регистры
	LDI	YH,High(TrBytes) ;Y=29:28
;
Start:	nop
		nop
		nop
		nop
		RJMP Start;


;==================================================================
Eve_TWI :	DIN r18,TWSR ;получам код статуса
			DIN r21,SREG ;сохраняем регист статуса в стеке
			push r21
;
			cpi r18,0x08 ;сравнить
			BRNE P0x08 ;переход если не равны
;			
			;Cюда перешли если успешно сформировано состояние старт
Tr_Adr :	lds r19,Adr
			;ldi r19,0b01010100 ;8 бит R/W= 0 значит передача данных
			DOUT TWDR,r19 ;пишем данные в буфер передачи
			ldi r19,0b10000101 ;старт передачи адресного пакета
			DOUT TWCR,r19
			pop r21
			DOUT SREG,r21
			reti ;выход из прерывания
;
P0x08 :		cpi r18,0x18
			BRNE P0x18 ;переход если не равны
;
			;Сюда если был передан адрес и приянто подтверждение
F_Tr :		lds r21,NumByte ;количество переданных байт
			lds r20,NumTr ;количество посылок данных
			cp r20,r21
			;cpi r21,2 ;количество переданных байт
			BRNE Tr  ;Переходим на обработчик передаваемых данных
;			
			;сюда если передали все байты
			ldi r20,0b10010101
			DOUT TWCR,r20
			pop r21
			DOUT SREG,r21
			reti
;
			;Не равны передаем еще
			Ne :	lds r21,NumByte ;количество переданных байт
					inc r21 ;увеличиваем счетчик количества байт 
					sts NumByte,r21
					ldi r20,0b10000101
					DOUT TWCR,r20 ;передаем дальше
					pop r21
					DOUT SREG,r21
					reti
;
P0x18 :		cpi r18,0x20	
			BRNE P0x20 ;переход если не равны
;
			;Был передан адрес и не принято подтверждение
			ldi r20,0b10100101 ;Формирую состояние повстарт
			DOUT TWCR,r20
			pop r21
			DOUT SREG,r21
			reti
;
P0x20 :		cpi r18,0x28
			BRNE P0x28 ;переход если не равны
;			
			;Cюда если был передан пакет данных и приянто пожтверждение
			rjmp F_Tr ;
;
P0x28 :		cpi r18,0x30
			BRNE P0x30
;
			;Был передан пакет данных подтверждение не принято
			ldi r20,0b00000001 ;передаю те же данные снова
			DOUT TWDR,r20		;Здесь можно переписать
;
P0x30 :		cpi r18,0x10
			BRNE P0x10
			;Было сформировано состояние повстарт
			rjmp Tr_Adr
;			
P0x10 :		pop r21
			DOUT SREG,r21
			reti
;=======================================================================
;Процедура формирования пакетов данных для TWI
Tr :		ld r21,Y+
			DOUT TWDR,r21
			rjmp Ne
;=======================================================================
;Call-used registers (r18-r27, r30-r31). Регистры, используемые при вызовах функций.
; Могут быть заняты компилятором gcc для локальных данных (переменных). 
;Вы свободно можете их использовать в подпрограммах на ассемблере, без необходимости 
;сохранения и восстановления (не нужно их сохранять в стек командой push и извлекать 
;из стека командой pop).
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
;=====================================================================
;Анализатор 
;оранжевый 1 канал
;красный   2 канал