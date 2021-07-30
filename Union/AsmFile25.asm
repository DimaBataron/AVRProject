/*
 * AsmFile25.asm
 * Операция Союз. 
 * Соединяем модули из предыдущих видео.
 * Модуль передачи байт на микросхему SSD1306
 * Модуль передачи байт на микросхему AD9833
 *  Created: 10.07.2021 14:45:18
 *   Author: dima
 */ 
.include "F:/AVR/7.0/packs/atmel/ATmega_DFP/1.6.364/avrasm/inc/m328Pdef.inc"
.include "E:/A/AssemblerApplication1/AssemblerApplication1/Macro.inc"
 .org 0x0000 jmp RESET ; Reset Handler
.org 0x0002 jmp Encoder; jmp EXT_INT0 ; IRQ0 Handler
.org 0x0004 jmp PresEn; jmp EXT_INT1 ; IRQ1 Handler
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
.org 0x0020 jmp Time_ms ; Timer0 Overflow Handler
.org 0x0022 jmp InterSPI ; SPI Transfer Complete Handler
.org 0x0024 reti; jmp USART_RXC ; USART, RX Complete Handler
.org 0x0026 reti; jmp USART_UDRE ; USART, UDR Empty Handler
.org 0x0028 reti; jmp USART_TXC ; USART, TX Complete Handler
.org 0x002A reti; jmp ADC ; ADC Conversion Complete Handler
.org 0x002C reti; jmp EE_RDY ; EEPROM Ready Handler
.org 0x002E reti; jmp ANA_COMP ; Analog Comparator Handler
.org 0x0030 jmp Eve_TWI ; jmp TWI ; 2-wire Serial Interface Handler
.org 0x0032 reti; jmp SPM_RDY ; Store Program Memory Ready Handler
.ORG   INT_VECTORS_SIZE      	; Конец таблицы прерывани
;Символьные имена и переменные с данными
.include "E:/A/AssemblerApplication1/AssemblerApplication1/DefFile4.inc"

.cseg
; Непосредственно таблица содержащая адреса процедур
TaskProcs: .dw WordTr            ; [00] 
           .dw TwoWordTr         ; [01] 
		   .dw StartInit		 ; [02] стартовая инициализация
		   .dw TrData			 ; [03] Передача символов на экран
		   .dw Clean			 ; [04] Очистка
		   .dw PosYkP			 ; [05] Позиционирование строки
		   .dw PosYkCol			 ; [06] Позиционирование столбца
		   .dw TrPointSym		 ; [07] Вывод одного символа(указателя например)
		   .dw StopSig			 ; [08] Отправка сигнала стоп
		   .dw StartSig          ; [09] Отправка сигнала старт
;При старте программы сохраняю адрес начала массива байт в СurrentByte
;МассивИнициализации
InitSSD : .db 0xA8,0x00,0xD3,00,0x40,0xA1,0xC0,0xDA,0x12,0x81,0xFF,0xA4,0xA6,0xD5 ;14
		  .db 0x80,0x8D,0x14,0x20,0x00,0xAF ;6
		;.db 0x00,0xAE,0x00,0x20,0x00,0x10,0x00,0xB0,0x00,0xC8,0x00,0x00,0x00,0x10,0x00
		;.db 0x40,0x00,0x81,0x00,0xFF,0x00,0xA0,0x00,0xA6,0x00,0xA4,0x00,0xD3,0x00,0x00
		;.db 0x00,0xD5,0x00,0xF0,0x00,0xD9,0x00,0x22,0x00,0xDA,0x00,0x12,0x00,0xDB,0x00
		;.db 0x20,0x00,0x8D,0x00,0x14,0x00,0xAF ;массив командных байт из инета
AdrSSD0:
;A0->A1; 22-12; 
;A8,3f->A8,00  ->Кэф.Мулитиплексирования (стоило ли менять?)
;D3,00->D3,37   сдвиг строки от 0 до 63
;0x40      начальная строка
;0x81,0xFF значение контрасности
;0xA4 Вощобновить отображение с учетом содержания RAM
;0xD5,0x80 настройка делителя и частоты осциллятора
;0x8D,0x14 подключение повышающего преобразователя
;0x20,0x00 Режим горизонтальной адресации
;0xAF  включение дисплея
;Текст
MainM:		.db "выборчастоты",0
MainM1:		.db "выборсигнала",0
;
;============================================================
 Reset:	cli
		LDI R16,Low(RAMEND)	; Инициализация стека
		OUT SPL,R16		; Обязательно!!!
		LDI R16,High(RAMEND)
		OUT SPH,R16
;============================================================
ldi ZL, low(TaskQueue) ;здесь проинициализируем озу значениями 0xFF
ldi ZH, high(TaskQueue)
ldi r16,0
ldi r17,0xFF
TaskQ0xFF:	inc r16
			st Z+,r17
			cpi r16,-56
			brne TaskQ0xFF
;===============================================================
;Очистка ОЗУ
AM_Flush:	LDI	ZL,Low(MasByte)	; Адрес начала ОЗУ в индекс
			LDI	ZH,High(MasByte)
			CLR	R16			; Очищаем R16
Flush:		ST 	Z+,R16			; Сохраняем 0 в ячейку памяти
			CPI	ZH,High(RAMEND+1)	; Достигли конца оперативки?
			BRNE	Flush			; Нет? Крутимся дальше!
			CPI	ZL,Low(RAMEND+1)	; А младший байт достиг конца?
			BRNE	Flush
 
			CLR	ZL			; Очищаем индекс
			CLR	ZH
;==============================================================
;Очистка регистров
		LDI	ZL, 30		; Адрес самого старшего регистра	
		CLR	ZH		; А тут у нас будет ноль
		DEC	ZL		; Уменьшая адрес
		ST	Z, ZH		; Записываем в регистр 0
		BRNE	PC-2		; Пока не перебрали все не успокоились
;==============================================================
ldi ZL, low(MasByte) ; Грузим в Z адрес массива байт Z(r31:r30)
DOUT CurrentByteL, ZL
DOUT ReadDatL,ZL 
;
ldi ZH, high(MasByte) 
DOUT CurrentByteH,ZH
DOUT ReadDatH,ZH
;
ldi Tmp2,0
;=============================================================
;Конфигурация INT0 по спадающему фронту Вывод D2=PD2=INT0 конфигурирую енкодер
;И INT1 = PD3
		ldi r18,0b00001010	;По спадающему фронту на выходе INT0 и INT1
		DOUT EICRA,r18		
		ldi r18,0b00000011  ;разрешаем внешние прерывания INT0 и INT1
		DOUT EIMSK,r18
		;Прерывания при выходе из обработчика надо восстанавливать
;=========================================================
;Задаю режим выводов в соответствии с его назначением
;Для управления лампочками
; Использую PС 0-5 = A0-A5
ldi FisByte,0b00110001  ;<<<<----Вывод на лампочку
out DDRC,FisByte ;Навравление передачи данных в 1(Выход)
ldi FisByte,0b00110000  ; Изменил с учетом подключенного модуля I2C
out PORTC,FisByte
;out PORTB,FisByte ; перевожу ноги в 0.
;===========================================================
;Int0=PD2=S1=D2 
;Int1=PD3=S2=D3
;PD4     =Key=D4
ldi FisByte,0b00000000
out DDRD,FisByte ;Навравление передачи данных в 1(Выход)
ldi FisByte,0b00000000
out PORTD,FisByte
;===========================================================
;Задаю режим выводов в соответствии с его назначением
ldi FisByte,(1<<PB1)|(1<<PB3)|(1<<PB5)|(1<<PB2)
out DDRB,FisByte ;Навравление передачи данных в 1(Выход)
out PORTB,FisByte ; переводим ноги в 1.
;
ldi FisByte,0
out SPSR,FisByte
ldi FisByte,(1<<SPIE)|(1<<SPE)|(1<<MSTR)|(1<<CPOL)|(1<<SPR0)
out SPCR,FisByte ; конфигурируем модуль SPI на передачу
;DSPI 16,0,0b11111001   
;С SPI работают Атмега168 
;SCK	PB5 --> D13
;MISO	PB4 --> D12
;MOSI	PB3 --> D11
;SS		PB2 --> D10 (8bit)
;SS     PB1 --> D9	(16bit) Управляем вручную
;Конфигурируем SS, MОSI и SCK как выходные.
;
;SPIE	1 Разрешить прерывания от модуля 
;SPE	1 Разрешить работу модуля
;MSTR	1 Работать в режиме Master
;DORD	1 Первым передается младший бит
;CPOL   1 тактовые испульсы отрицетельные
;CPHA	0 по переднему фронту
;SPR1:SPR0   01  clk/16 делим системную частоту на 16
;SPI2X:SPR1:SPR0
;0		0		0	fclc/4
;0		0		1	fclc/16
;0		1		0	fclc/64
;0		1		1	fclc/128
;1		0		0	fclc/2
;1		0		1	fclc/8
;1		1		0	fclc/32
;1		1		1	fclc/64
;==================================================================================
;Постановка процедур в очередь
;Записываю в регистры начальные значения
	ldi CE,0
	ldi CountEncoder,0
	sei		;Прерывания от TWI не трогают мои регистры

	call StartInitQue ;Процедура постановки задачи стартовой инициализации TWI в очередь

	ldi FisByte,0
	ldi SecByte,7
	call QuePosYkP ;установка строки

	ldi FisByte,0
	ldi SecByte,15
	call QuePosYkCol ;установка символа

	ldi FisByte,128 ;<<<<---------- ;загружаю количество очищаемых символов изменить
	call QueClean
	call StartTrData   ;Процедура подготовки данных перед передачей данных на экран по TWI 

;Вывожу указатель меню и первую строку
	
	ldi FisByte,3 ;позиционирование строки. Начало
	ldi SecByte,5 ;конец
	call QuePosYkP ;Устанавливаю строку

	ldi FisByte,1
	ldi SecByte,15
	call QuePosYkCol ;Устанавливаю столбец

	ldi FisByte, low(MainM*2)
	ldi SecByte, high(MainM*2)
	call QueTrData  ;Вывожу массив

	ldi FisByte,5 ;позиционирование строки. Начало
	ldi SecByte,6 ;конец
	call QuePosYkP ;Устанавливаю строку

	ldi FisByte,1
	ldi SecByte,15
	call QuePosYkCol ;Устанавливаю столбец

	ldi FisByte, low(MainM1*2)
	ldi SecByte, high(MainM1*2)
	call QueTrData  ;Вывожу массив 2

	call QueStopSig ; Ставлю в очередь отправуку команды стоп модулю

	call InitPoInfPro ;Инициализирую начальные значения перед выводом указателя
sei

	call InterSPI
;Тут старт программы
ldi CE,0
;call Encoder
;sei		разрешаю прерывания
Main:	nop
		nop
		nop
		rjmp Main
;===========================================================
;;Процедуры
;------------------>>QueStartSig<<------------------------
;Постановка в очередь отправки сигнала старт.
QueStartSig:	cli
				ldi OSRG, TS_StartSig ;добавляю задачу в очередь
				call QueProcedur
				call PrSt
				ret
;------------------>>StartSig<<----------------------------
StartSig:	ldi r18,0b10100101 ;формируем состояние СТАРТ на шине TWI
			DOUT TWCR,r18
			reti
;------------------>>QueStopSig<<--------------------------
;Процедура постановки в очередь процедуры отправки сигнала стоп модулю TWI
QueStopSig: cli
			ldi OSRG, TS_StopSig ;добавляю задачу в очередь
			call QueProcedur
			call PrSt
			ret
;-------------------->>StopSig<<-------------------------- 
;Процедура отправки сигнала стоп модулю TWI
;Формирую состояние стоп
StopSig:	ldi r18,0b10010101
			DOUT TWCR,r18
			;После отправки стоп сдвигаю очередь
			call ShiftQue
			ret
;------------------>>MenSMode<<------------------------------
;Процедура постановки задачи вывода на экран меню выбора
;режима работы.
;Процедура сама проводит предварительную очистку экрана.

MainMod1:	.db "синус",0
MainMod2:	.db "треугольный",0
MainMod3:	.db "битцап",0
MainMod4:	.db "битцап2",0
;;Очистка
MenSMode:   ldi FisByte, 0
			ldi SecByte,7
			call QuePosYkP
			
			ldi FisByte,0
			ldi SecByte,15
			call QuePosYkCol
			
			ldi FisByte,128
			call QueClean 
;Синус
			ldi FisByte, 2
			ldi SecByte,3
			call QuePosYkP

			ldi FisByte,1
			ldi SecByte,15
			call QuePosYkCol

			ldi FisByte, low(MainMod1*2)
			ldi SecByte, high(MainMod1*2)
			call QueTrData
;Треугольный 
		    ldi FisByte, 3
			ldi SecByte,4
			call QuePosYkP

			ldi FisByte,1
			ldi SecByte,15
			call QuePosYkCol

			ldi FisByte, low(MainMod2*2)
			ldi SecByte, high(MainMod2*2)
			call QueTrData
;БитЦАП
			ldi FisByte, 4
			ldi SecByte,5
			call QuePosYkP

			ldi FisByte,1
			ldi SecByte,15
			call QuePosYkCol

			ldi FisByte, low(MainMod3*2)
			ldi SecByte, high(MainMod3*2)
			call QueTrData
;БитЦАП2
			ldi FisByte, 5
			ldi SecByte,6
			call QuePosYkP

			ldi FisByte,1
			ldi SecByte,15
			call QuePosYkCol

			ldi FisByte, low(MainMod4*2)
			ldi SecByte, high(MainMod4*2)
			call QueTrData
			ret

;------------------>>StartInitQue<<--------------------------
;Процедура постановки задачи стартовой инициализации в очередь
StartInitQue:	LDI r18,((AdrSSD0-InitSSD)*2) 
				DOUT LenMasInit,r18 ;Записываем длинну массива инициализации
				ldi r18,0
				DOUT InitCount,r18 ;счетчик состояния инициалиализации
				DOUT NumWhileInit,r18 ;количество повторений цикла передачи конфиг битов
				LDI ZL,low(InitSSD*2) ; заносим младший байт адреса, в регистровую пару Z
				LDI  ZH,high(InitSSD*2)	; заносим старший байт адреса, в регистровую пару Z
				DOUT ZInitLow,ZL ; запоминаю начальный адрес массива инициализации.
				DOUT ZInitHi,ZH
;
	;Код формирования данных для начала передачи
				LDI r18,0b01111000
				DOUT AdrSSD,r18		;записываем адрес ведомого
				TWFscl 70,0 ;ставлю 102.6кГЦ скороть работы TWI Fscl ;SSD1306 максимум 400кГц
;
				ldi OSRG,TS_StartSig
				call QueProcedur
				ldi OSRG, TS_StartInit ; Добавляю задачу в очередь
				call QueProcedur
				call PrSt
				ret
;------------------>>StartInit <<----------------------------
;Для запуска этой подпрограммы используються такие переменные\
;Стартовая инициализация экранчика(отправка настроек на монитор)
;NumWhileInit				;LenMasInit					;InitCount
;ZInitLow					;ZInitHi				    ;
;NumWhileInit	+			количество повторений цикла передачи конфиг битов
;LenMasInit		+			длинна массива инициализации
;InitCount		+			счетчик состояния инициализации
;ZInitLow		+			в этой области r30. Сохраняем сюда младший адрес массива инициализации при старте мк.
;ZInitHi		+			в этой области r31. Cохраняю сюда старший адрес 
;Регистры r18,r22 
StartInit: DIN r18,NumWhileInit
		   DIN r22,LenMasInit
		   cp r18,r22
		   brge InitEnd   ;если передали все байты инициализации
		   DIN r18,InitCount
		   cpi r18,0
		   BRNE InCoun1   ;переход если передать байт команды
;Cюда переходим для передачи управляющего байта
		   inc r18
		   DOUT InitCount,r18
		   ldi r18,0
		   DOUT TWDR,r18
		   ldi r18,0b10000101 ; Продолжаем передачу
		   DOUT TWCR,r18
		   reti
;Cюда для передачи байта команды
InCoun1:   cpi r18,1
		   brne PstInit ;переход если сформировать повстарт
;Cюда для передачи байта с адреса
		   inc r18
		   DOUT InitCount,r18
		   DIN r18,NumWhileInit
		   inc r18
		   DOUT NumWhileInit,r18
		   DIN ZL,ZInitLow              ;берем данные отсюда
		   DIN ZH,ZInitHi
		   LPM R18, Z+	;Берем байт по адресу регистровой пары
		   DOUT ZInitLow,ZL
		   DOUT ZInitHi,ZH
		   DOUT TWDR,r18
		   ldi r18,0b10000101 ; Продолжаем передачу
		   DOUT TWCR,r18
		   reti
;Cюда если надо сформировать состояние повстарт
PstInit:   ldi r18,0
		   DOUT InitCount,r18
		   ldi r18,0b10100101 ;Формирую состояние повстарт
		   DOUT TWCR,r18
		   reti
;Cюда если передали все байты инициализцации.
InitEnd:   call ShiftQue
		   ldi r18,0
		   DOUT NumWhileInit,r18
		   DOUT InitCount,r18
		   ;DIN r18,FlagCon
		   ;ANDI r18,0b11111101 ;b[1] - отключаю флаг стартовой инициализации
		   ;DOUT FlagCon,r18 ; Отключаю флаг инициализации т.к. все байты передали
		   ;Здесь добавить процедуру взятия следующей задачи.

		   ldi r18,0b10100101;Формирую состояние повстарт. А это к чему приведет?
		   DOUT TWCR,r18 
		   reti
;---------------->>>>>TrData<<<<---------------------------
;TrDataCountB		флаг того что нужно передать управляющий байт (При инициализации передачи массива символов)
;TrDataCount		количество байт одного символа которые уже передали
;TrDatF				; При первом входе беру адреса массива для вывода из данных процедуры.
;3 ячейки обнуляю при стартовой инициализации программы

;TrDatLow:			r30. Сохраняем сюда младший адрес массива символов которые выводятся
;TrDatHi:			в этой области r31. Cтарший байт адреса массива символов
;TrSymByteL:		указатель на массив передаваемого байта одного символа из массива TrDat (Текущего)
;TrSymByteH:		указатель на


;Процедура принимающая на вход массив байт для вывода. 0 признак онончания массива.
TrData: DIN FisByte,TrDatF
		CPI FisByte,0
		BRNE TD5 ;переход если не 0
;Cюда если впервые запустили эту процедуру
		DIN ZL, ReadDatL ;берем из массива данные которые будем писать
		DIN ZH, ReadDatH
		ld OSRG,Z+
		DOUT TrDatLow,OSRG;сначала пишем младший адрес массива выводимых символов TrDatLow=OSRG 
		ld OSRG,Z+
		DOUT TrDatHi,OSRG
		DOUT ReadDatH,ZH
		DOUT ReadDatL,ZL
		inc FisByte
		DOUT TrDatF,FisByte ;TrDatF=1
; Cюда для продолжения передачи
TD5:	DIN r18, TrDataCountB
		cpi r18,0 
		BRNE TrComp ;   если не равно переход(уже передавали управляющий байт)
;cюда переходим для передачи управляющего байта
		ldi r18,1
		DOUT TrDataCountB,r18
		ldi r18,0x40 ;устанавливаем управляющий байт, символизирующий о сплошном массиве байт
		DOUT TWDR,r18
		ldi r18,0b10000101 ; Продолжаем передачу
		DOUT TWCR,r18
		reti
;Управляющий байт передали
TrComp: DIN r18,TrDataCount
		cpi r18,0 
		BRNE TrMasComp ; Проверка не конец ли передачи массива байт
;сюда для получения кода симола
		DIN ZL,TrDatLow
		DIN ZH, TrDatHi ;беру байт из массива 
		LPM r18,Z+
		cpi r18,0
		BRNE TrDataCalc ; переходим для вычисления массива байт символа
;Отключаю флаги формирую состояние повстарт
		ldi r18,0
		DOUT TrDataCountB,r18
		DOUT TrDataCount,r18
		DOUT TrDatF,r18
		call ShiftQue ; Сдвигаю очередь т.к. нашли окончание массива символов
		ldi r18,0b10100101
		DOUT TWCR,r18
		reti
;
TrDataCalc: DOUT TrDatLow,ZL
			DOUT TrDatHi,ZH
			;Вычисляю адрес нового символа
			SUBI r18,0xE0 ; вычитанием из кода символа получаем относительное смещение относительно начала массива байт
			lsl r18
			lsl r18
			lsl r18 ;сдвиг влево на 3 разряда равносильно умножению на 8
			LDI ZL,low(S0*2)  ;адрес нулевого массива байт символа соответствует букве а
			LDI ZH,high(S0*2)
			add ZL,r18       ;складываю и устанавливаю бит береноса
			ldi r18,0
			adc ZH,r18  ;складываю с битом переноса если есть
			;Теперь Z содержит адрес байта для вывода.
			DOUT TrSymByteL, ZL
			DOUT TrSymByteH,ZH
			RJMP TrMasBat
;Сравниваю ни конец ли массива символов
TrMasComp:	cpi r18,8
			BRGE EndTrData		;если конец массива байт обозначабщих символ
;cюда переходим для передачи массива байт символов
TrMasBat:	DIN r18,TrDataCount
			inc r18
			DOUT TrDataCount,r18
			DIN ZL,TrSymByteL
			DIN ZH, TrSymByteH
			LPM R18, Z+ ;беру байт по вычисленному адресу 
			DOUT TrSymByteL,ZL
			DOUT TrSymByteH,ZH
			DOUT TWDR,r18
			ldi r18,0b10000101 ; продолжаем передачу
			DOUT TWCR,r18
			reti
EndTrData:  ldi r18,0
			DOUT TrDataCount,r18
			call InterSPI
			ret
;
;------------------>>>QueTrData<<<--------------------------------------
;Процедура постановки передачи массива байт на экран в очередь выполнения
;Перед запуском Кладем в FisByte младшая часть адреса SecByte старшая часть
;адреса массива символов которые выводятся.
QueTrData:  ldi OSRG, TS_TrData ; Добавляю задачу в очередь
			call QueProcedur
			ldi Quant,1  ;Указываем что пишем одно слово
			call QueData
			call PrSt ;статус задач в очереди, если очередь пуста запуск выполнения задачи
			ret
;----------------->>>PrSt<<<-----------------------------------------------
;Проверка статуса выполнения задачи из очереди. Если выполнение закончено, стартую снова
PrSt:	;Проверяю завершили ли передачу
		push Tmp2
		in Tmp2,SREG ; Сохраняем значение флагов
		push Tmp2;
		;Что изменится если заменю на +0??
		ldi ZL,low(TaskQueue) 
		ldi ZH,high(TaskQueue) ;вычисляем были ли еще задачи кроме той что положили?
		ldi r18,1
		add ZL,r18
		clr r18
		adc ZH,r18
		ld Tmp2,Z ;берем номер текущей задачи
		cpi Tmp2,0xFF
		brne FrTr1 ; переход если не равно
;cюда перешли если все задачи уже выполнились. Запускаю обработку очереди поновой
		pop Tmp2 ; Возвращаем флаги. Если там прерывание было 
		out SREG,Tmp2 ; разрешено, то оно вернется в это значение.  Не попртим т.к дальше хожряняем и потом восстанавливаем
		pop Tmp2;
		call InterSPI
		ret
;Cюда если в очереди еще есть задачи
FrTr1: pop Tmp2 ; Возвращаем флаги. Если там прерывание было 
	   out SREG,Tmp2 ; разрешено, то оно вернется в это значение.
	   pop Tmp2;
	   ret

;---------------------->>>>StartTrData<<<<------------- Процедура подготовки данных
StartTrData : ldi r18,0
			  DOUT TrDataCountB,r18	;флаг того что нужно передать управляющий байт (При инициализации передачи массива символов)
			  DOUT TrDataCount,r18	;количество байт одного символа которые уже передали
			  DOUT TrDatF,r18	;При первом входе беру адреса массива для вывода из данных процедуры.
			  ret
;----------------->>>>QuePosYkP<<<<----------------------------------
;Постановка в очередь процедуры позиционирования указателя.
QuePosYkP:	ldi OSRG, TS_PosYkP
			call QueProcedur
			ldi Quant,1
			call QueData
			call PrSt
			ret
;;----------------->>>PosYkP<<<-----------------------------------------
;Процедура позиционирования указателя страница(строка)
;Используемые байты в оперативе 
;NumWhilePos		EndTrCom			CountPosYk
;SelectPosYk		

;NumWhilePos		количество переданных байт позиционирования
;CountPosYk	        счетчик состояния позиционирования.
;SelectPosYk		вложенный для определения байта.
;SetPagSt:			стартовый адрес страницы 0-7(строки)
;SetPagEnd:			конечный адрес страницы 0-7(строки)

;1.Использование: Загрузить в массив данных 2байта SetPagSt SetPagEnd
;1й байт начальная строка записи
;2й байт конечная строка записи
;В данной версии загрузка происходит в Массив данных процедур, сначала лежит SetPagSt
; потом  SetPagEnd, стартовый и конечный адрес страницы(только для горизонтальной и вертикальной адресации)
;Cюда заходит по прерыванию (например после передачи модуля TWI)
;Ничего не передается пока не выполнится
PosYkP:	   DIN r18,NumWhilePos
		   cpi r18,3
		   brge  EndTrCom  ;переход если передали 3байта позиционирования строки
		   DIN Quant,CountPosYk
		   cpi Quant,0
		   BRNE CountContr ; Переход если повстарт уже было сформировано
;Сюда переходим для формирования состояния повстарт
		   inc Quant
		   DOUT CountPosYk,Quant
		   ldi Quant, 0b10100101 ;формирую состояние повстарт
		   DOUT TWCR,Quant
		   reti
CountContr:	cpi Quant,1
		    BRNE CounComand ;<Переходим для передачи непосредственно команды
;Cюда перешли для передачи управляющего байта
		    inc Quant
		    DOUT CountPosYk,Quant
		    ldi Quant,0x00
			DOUT TWDR,Quant ; передаем управляющий байт
			ldi Quant,0b10000101
			DOUT TWCR,Quant ;Продолжаем передачу
			reti
;Cюда переходим для передачи команды
CounComand: ldi Quant,0
			DOUT CountPosYk,Quant
			DIN Quant,SelectPosYk
			inc r18
			DOUT NumWhilePos,r18
			cpi Quant,0
			BRNE CouComCon ;Переход для отправки конфигурационных байт команды
;Здесь отправляем первый байт команды
			ldi r18,0x22
			inc Quant
			DOUT SelectPosYk,Quant
			DOUT TWDR,r18
			ldi r18,0b10000101 ; Продолжаем передачу
			DOUT TWCR,r18
			reti
;Cюда переходим для отправки оставшихся байт команды
CouComCon: DIN ZL, ReadDatL ;берем из массива данные которые будем писать
		   DIN ZH, ReadDatH
		   ld OSRG,Z+
		   DOUT TWDR, OSRG
		   DOUT ReadDatH,ZH
		   DOUT ReadDatL,ZL
		   ldi r18,0b10000101 ; Продолжаем передачу
		   DOUT TWCR,r18 ;Формирую состояние повстарт
		   reti
;Передали все данные тепрь главное выйти отсюда
EndTrCom:	ldi r18,0
			DOUT NumWhilePos,r18
			DOUT CountPosYk,r18
			DOUT SelectPosYk,r18
			call ShiftQue
			LDI r18,0b10100101
			DOUT TWCR,r18 ;Формирую состояние повстарт
			reti

;----------------->>>QuePosYkCol<<--------------------------------------
;Процедура постановки в очередь процедуры позиционрирования столбца экрана
QuePosYkCol:		ldi OSRG, TS_PosYkCol ; добавляю задачу в очередь
					call QueProcedur
					ldi Quant,1  ;указываем что пишем одно слово
					call QueData
					call PrSt
					ret
;------------------>>>PosYkCol<<<-----------------------------------------
;Процедура позиционирования указателя столбца
;Используемые байты в оперативе 
;Использование: положить в регистры FisByte и SecByte номер начального и конечного символа 
;Запустить процедуру PosYkCol для постановки задачи в очередь.
;Дождаться выполнения.

;NumWhilePos		CountPosYk			SelectPosYk
;NumWhilePos		количество переданных байт позиционирования
;CountPosYk	        счетчик состояния позиционирования.
;SelectPosYk		вложенный для определения байта.

PosYkCol:  DIN r18,NumWhilePos
		   cpi r18,3
		   brge  EndTrCom12  ;переход если передали 3байта позиционирования строки
		   DIN TmpAsH,CountPosYk ;счетчик состояния позиционирования.
		   cpi TmpAsH,0
		   BRNE CountContr1 ; Переход если повстарт уже было сформировано
;Сюда переходим для формирования состояния повстарт
				inc TmpAsH
				DOUT CountPosYk,TmpAsH
				ldi TmpAsH, 0b10100101 ;формирую состояние повстарт
				DOUT TWCR,TmpAsH
				reti
CountContr1:	cpi TmpAsH,1
				BRNE CounComand1 ;<Переходим для передачи непосредственно команды
;Cюда перешли для передачи управляющего байта
				inc TmpAsH
				DOUT CountPosYk,TmpAsH
				ldi TmpAsH,0x00   
				DOUT TWDR,TmpAsH ; передаем управляющий байт
				ldi TmpAsH,0b10000101
				DOUT TWCR,TmpAsH ;Продолжаем передачу
				reti
				Jmp CounComand1
EndTrCom12:		RJMP EndTrCom1
;Cюда переходим для передачи команды
CounComand1:	ldi TmpAsH,0
				DOUT CountPosYk,TmpAsH
				DIN TmpAsH,SelectPosYk ;вложенный для определения байта.
				inc r18
				DOUT NumWhilePos,r18
				cpi TmpAsH,0
				BRNE CouComCon1 ;Переход для отправки конфигурационных байт команды
;Здесь отправляем первый байт команды
			ldi r18,0x21 ;Set Column Address
			inc TmpAsH
			DOUT SelectPosYk,TmpAsH
			DOUT TWDR,r18
			ldi r18,0b10000101 ; Продолжаем передачу
			DOUT TWCR,r18
			reti
;Cюда переходим для отправки оставшихся байт команды
CouComCon1:		DIN ZL, ReadDatL ;берем из массива данные которые будем писать
				DIN ZH, ReadDatH
				ld OSRG,Z+
				lsl OSRG
				lsl OSRG
				lsl OSRG ;сдвиг влево на 3 разряда равносильно умножению на 8
				DOUT ReadDatH,ZH
				DOUT ReadDatL,ZL

				cpi OSRG,120 ; Последний символ. Сдвигаем до конца.
				Brne TrComDat1 ;не конец перейти далее
				ldi OSRG,127
TrComDat1:		DOUT TWDR,OSRG
				ldi r18,0b10000101
				DOUT TWCR,r18 ; Продолжаем передачу
				reti
;Передали все данные тепрь главное выйти отсюда
EndTrCom1:		ldi r18,0
				DOUT NumWhilePos,r18
				DOUT CountPosYk,r18
				DOUT SelectPosYk,r18
				call ShiftQue
				LDI r18,0b10100101
				DOUT TWCR,r18 ;Формирую состояние повстарт
				reti
;------------------>>>QueClean<<<------------------------
;Процедура постановки в очередь очистки дисплея.
;Перед вызовом в FisByte записываю количество очищаемых символов.
QueClean:	cli
			ldi OSRG,0
			DOUT CleanByte,OSRG
			ldi OSRG,TS_Clean
			call QueProcedur
			ldi Quant,1 ;указываю что пишу одно слово
			call QueData
			call PrSt
			ret
;------------------>> Clean <<-----------------------------
;r18 r20
;CleanNow:              очищаемый в данный момент символ
;CleanSym:              количество символов которые надо очистить
;CleanWhile:  			очищаемый байт в текущий момент
;CleanByte:				байт которым заполняем все пространство.
;CleanFlag:				флаг указывающий о том что уже входили в процедуру и что передавать байт x40 не надо. Не забыть сбросить при выходе!!!
;Загружаем в CleanSym количество  (бит 8x8) символов 
;В CleanByte ложим то чем заполняем
Clean:  cli              ;что будет дальше если тут отключу?
		DIN FisByte,TrDatF
		CPI FisByte,0
		BRNE TD10 ;переход если не 0
;Cюда если впервые запустили эту процедуру
		DIN ZL, ReadDatL ;берем из массива данные которые будем писать
		DIN ZH, ReadDatH
		ld OSRG,Z+
		DOUT CleanSym,OSRG;сначала пишем младший адрес массива выводимых символов TrDatLow=OSRG 
		ld OSRG,Z+ ;тут просто сдвигаю
		DOUT ReadDatH,ZH
		DOUT ReadDatL,ZL
		inc FisByte
		DOUT TrDatF,FisByte ;TrDatF=1
; Cюда для продолжения передачи
TD10:		
	   DIN r18,	CleanNow
	   DIN Quant, CleanSym
	   cp r18,Quant
	   BRSH EndClean ; <<Переходим если уже очистили. Беззнаковое сравнение
;	   Переходим если чистим дальше 
	   DIN r20,CleanFlag
	   cpi r20,0
	   brne StartClean;<<--переходим если управляющую команду передавать не нужно
; Переход для передачи управляющей команды
		inc r20
		DOUT CleanFlag,r20
		ldi r20,0x40
		DOUT TWDR,r20 ;команда указывающая что дальше сплошным массивом идут данные
		ldi r20,0b10000101
		DOUT TWCR,r20 ; Продолжаем передачу
		reti
;Cюда переходим для начала очистки
StartClean: DIN r20, CleanWhile
			cpi r20,8
			BRGE CountINC ; <<--- переходим для увеличения счетичика очищаемого в данный момент символа
;Здесь если очищаем ячейку символа
			inc r20
			DOUT CleanWhile, r20
			DIN r20,CleanByte
			DOUT TWDR,r20
			ldi r20, 0b10000101
			DOUT TWCR,r20 ; Продолжаем передачу
			reti
;Символ очищен увеличиваем счетчик
CountINC:	ldi r20,0
			DOUT CleanWhile,r20
			inc r18  ;увеличиваю счетчик очищенных символов
			DOUT CleanNow,r18
			;Сколько очищаем символов столько раз сюда и переходим
			;128*8=256 байт, адресов возвратов при очистке всего дисплея
			call InterSPI
			ret
;Сюда Переходим для оконания передачи.
EndClean:   ldi r18,0
			DOUT CleanNow,r18
			DOUT CleanFlag,r18
			DOUT TrDatF,r18
			ldi r18,0b10100101
			DOUT TWCR,r18 ;Формирую состояние повстарт
			call ShiftQue
			reti

;--------------------->>>QueTrPointSym<<-----------------------------
;Процедура постановки в очредь процедуры передачи символа на экран.
QueTrPointSym:	ldi OSRG, TS_TrPointSym ; Добавляю задачу в очередь
				call QueProcedur
				ldi Quant,1 ;Указываем что пишем одно слово
				call QueData
				call PrSt
				ret
;-------------------->>>TrPointSym<<<---------------------------------
;Процедура принимающая на вход массив байт для вывода. 0 признак онончания массива.
;Вывод одного символа
TrPointSym: DIN FisByte,TrDatF
			CPI FisByte,0
			BRNE TD15 ;переход если не 0
;Cюда если впервые запустили эту процедуру
			DIN ZL, ReadDatL ;берем из массива данные которые будем писать
			DIN ZH, ReadDatH
			ld OSRG,Z+
			DOUT TrDatLow,OSRG;сначала пишем младший адрес массива выводимых символов TrDatLow=OSRG 
			ld OSRG,Z+
			DOUT TrDatHi,OSRG
			DOUT ReadDatH,ZH
			DOUT ReadDatL,ZL
			inc FisByte
			DOUT TrDatF,FisByte ;TrDatF=1
; Cюда для продолжения передачи
TD15:	DIN r18, TrDataCountB
		cpi r18,0 
		BRNE TrComp1 ;   если не равно переход(уже передавали управляющий байт)
;Сюда для передачи управляющего байта
		ldi r18,1
		DOUT TrDataCountB,r18
		ldi r18,0x40 ;устанавливаем управляющий байт, символизирующий о сплошном массиве байт
		DOUT TWDR,r18
		ldi r18,0b10000101 ; Продолжаем передачу
		DOUT TWCR,r18
		reti
TrComp1:	DIN Quant,TrDataCount
			cpi Quant,8
			BRGE EndTrData1		;если конец массива байт обозначабщих символ
;Если нет получаем байт выводимого символа 
		DIN ZL, TrDatLow
		DIN ZH,TrDatHi
		LPM OSRG, Z+ ;беру байт по вычисленному адресу 
		DOUT TWDR,OSRG
		inc Quant ;TrDataCount++
		DOUT TrDataCount,Quant
		DOUT TrDatLow,ZL
		DOUT TrDatHi,ZH
		ldi r18,0b10000101 ; продолжаем передачу
		DOUT TWCR,r18
		;call InterSPI ;вызывается сама после окончания передачи
		reti
EndTrData1: 	ldi r18,0
				DOUT TrDataCountB,r18
				DOUT TrDataCount,r18
				DOUT TrDatF,r18
				call ShiftQue
				ldi r18,0b10100101
				DOUT TWCR,r18 ; формирую состояние повстарт
				reti

;-------------------->>InitPoInfPro<<----------------------
;Процедура записи начальных значений в массив данных используемых при выводе указателя
InitPoInfPro: ldi r18,0xFF
			  DOUT PosMemStr,r18
			  DOUT PosMemStrEnd,r18
			  DOUT PosMemCol,r18
			  DOUT PosMemColEnd,r18
			  ret
;----------------->>>PoInfPro<<<-----------------------------------------
;Процедура вывода указателя для позиционирования указателя записывают значения в
;FsMM стартовая строка
;FsML конечная
;FsLM стартовый столбец
;FsLL конечный столбец
;Процедура запоминает где был указатель в последний раз. Стирает символ где был указатель до этого.
;Эта процедура добавляет в очередь необходимые манипуляции
;Переменные ;PosMemStr
            ;PosMemStrEnd
            ;PosMemCol
            ;PosMemColEnd Хранят текущее положение
; После нажатия на кнопку запись 0xFF в память где хранились предыдущая позиция указателя меню.
PoInfPro: DIN OSRG,PosMemStr
		  cpi OSRG,0xFF
		  brne PolInfY
;cюда перешли если выводим впервые
PolInfN: mov FisByte, FsMM
		 mov SecByte, FsML
		 call QuePosYkP   ;Проверил не затирает ли ++++++
		 ;Сохраняю текущее положение  (для следующего метода)
		 DOUT PosMemStr, FisByte
		 DOUT PosMemStrEnd,SecByte
;Формирую значения перед выводом позиционирования столбца
		 mov FisByte, FsLM
		 mov SecByte, FsLL
		 DOUT PosMemCol, FisByte
		 DOUT PosMemColEnd,SecByte
		 call QuePosYkCol ;Проверил не затирает ++++
		 ldi FisByte, low(point*2)  ;вывод одного символа
		 ldi SecByte, high(point*2)
		 call QueTrPointSym	;Проверил ++++
		 ret
;сюда перешли если ранее выводили поэтому очищаем место
PolInfY:	DIN FisByte,PosMemStr
			DIN SecByte,PosMemStrEnd
			call QuePosYkP
			DIN FisByte,PosMemCol
			DIN SecByte,PosMemColEnd
			call QuePosYkCol
			ldi FisByte,1
			call QueClean 
			rjmp PolInfN
;==========================================================================
;----------------------->>WordTr<<-----------------------------------------
;Процедура передачи слова по SPI
WordTr: DIN r20, SREG
		push r20
		cpi Tmp2,2 ;передали ли уже 2 байта = 1слово
		brge EndWordTr
;Переходим сюда для передачи следующего байта
		inc Tmp2 ;увеличиваем значение переданных байт
		cli
		DIN ZL, ReadDatL ;берем из массива данные которые будем писать
		DIN ZH, ReadDatH
		ld OSRG,Z+		 ;загружаю байт на который указывает указатель
		DOUT ReadDatH,ZH
		DOUT ReadDatL,ZL
		DPort_And B,0b11111111,0b11111101  ;переключаем в 0 CS  PB1 --> D9 
;(16bit) Управляем вручную
		OUT SPDR,r20 ;начинаю передачу
		pop OSRG
		DOUT SREG,OSRG ; восстанавливаю статусный регистр. Если прерывания были 
		sei
		ret				;разрешены оны включатся

;Переходим сюда если передали уже слово
EndWordTr:	ldi Tmp2,0
			call ShiftQue ;вызываю процедуру сдвига очереди, т.к. эта закончила свое выполение
			DPORT B, 0b00000000,0b00000010 ;переключаем в 1 CS  PB1 --> D9
			call InterSPI
			pop OSRG
			DOUT SREG,OSRG ;восстанавливаю статусный регистр
			reti
;--------------------->>>QueProcedur<<--------------------
;Постановка процедуры в очередь
QueProcedur :	push ZL ; Сохраняем все что используется
				push ZH ; в стеке
				push Tmp2
				in Tmp2,SREG ; Сохраняем значение флагов
				push Tmp2
				cli    ; запрещаем прерывания. 
				;
				ldi ZL, low(TaskQueue) ; Грузим в Z адрес очереди задач.
				ldi ZH, high(TaskQueue) 
SEQL01:		ld Tmp2, Z+			; Грузим в темп байт из очереди
			cpi Tmp2, 0xFF      ; и ищем ближайшее пустое место = FF
			BRNE SEQL01          ; если не равно FF берем следующий
; Cюда если нашли конец очереди
			st -Z, OSRG ;Сохраняем в очереди номер задачи. 
			pop Tmp2 ; Возвращаем флаги. Если там прерывание было 
			out SREG,Tmp2 ; разрешено, то оно вернется в это значение. 
			pop Tmp2
			pop ZH
			pop ZL
			reti
;------------------------->>>ShiftQue<<<--------------------------------
;Процедура сдвига очереди (Очередь в оперативе)
ShiftQue:	cli 
			push Tmp2
			in Tmp2,SREG ; Сохраняем значение флагов
			push Tmp2
			ldi ZL, low(TaskQueue) ;кладем в массив начало
			ldi ZH, high(TaskQueue) 
SQL02:		ldd Tmp2, Z+1  ;гружу в OSRG следующий
			st Z+, Tmp2 ; кладу его по адресу после Z++
			cpi Tmp2,0xFF
			BRNE SQL02 ;повторяем пока не конец очереди
;cюда если конец очереди
			pop Tmp2 ; Возвращаем флаги. Если там прерывание было 
			out SREG,Tmp2 ; разрешено, то оно вернется в это значение. 
			pop Tmp2;
			ret
;------------------------->>>QueData<<---------------------------
;Пишет данные в массив байт откуда их берут другие процедуры
QueData:	cli    ; запрещаем прерывания.
			push ZL ; Сохраняем все что используется
			push ZH ; в стеке
			push Tmp2
			in Tmp2,SREG ; Сохраняем значение флагов
			push Tmp2;
			DIN ZL, CurrentByteL
			DIN ZH, CurrentByteH
			ST Z+,FisByte ;Запись старшего байта
			ST Z+,SecByte ; Запись младшего
			cpi Quant,2 ;смотрим сколько байт записываем
			BRLT EndQueData ; если меньше 2 переходим
;Cюда для записи второго слова
			ST Z+,ThirByte ;Старший
			ST Z+,FourtByte ;младший
;Удалил блок для записи 3го байта
;			cpi Quant,3		 
;			BRLT EndQueData ;переходим если 2
;Cюда для записи третьего слова
;			ST Z+,FifByte ;Старший
;			ST Z+,SixByte ;младший
EndQueData:		DOUT CurrentByteL,ZL
				DOUT CurrentByteH,ZH ;сохраняем для последующей записи
				pop Tmp2 ; Возвращаем флаги. Если там прерывание было 
				out SREG,Tmp2 ; разрешено, то оно вернется в это значение. 
				pop Tmp2;
				pop ZH
				pop ZL
				ret

;------------------------>>>>TwoWordTr<<<<-----------------------------------
;Передача двух слов по SPI
TwoWordTr:  DIN r20, SREG
			push r20
			cpi Tmp2,4 ;передали ли уже 4 байта = 1слово
			brge EndTWordTr
;Переходим сюда для передачи следующего байта
		inc Tmp2 ;увеличиваем значение переданных байт
		cli
		DIN ZL, ReadDatL ;берем из массива данные которые будем писать
		DIN ZH, ReadDatH
		ld OSRG,Z+		 ;загружаю байт на который указывает указатель
		DOUT ReadDatH,ZH
		DOUT ReadDatL,ZL
		DPort_And B,0b11111111,0b11111101  ;переключаем в 0 CS  PB1 --> D9 
;(16bit) Управляем вручную
		OUT SPDR,r20 ;начинаю передачу
		pop OSRG
		DOUT SREG,OSRG ; восстанавливаю статусный регистр. Если прерывания были 
		sei
		ret				;разрешены оны включатся

;Переходим сюда если передали уже слово
EndTWordTr:	ldi Tmp2,0
			call ShiftQue ;вызываю процедуру сдвига очереди, т.к. эта закончила свое выполение
			DPORT B, 0b00000000,0b00000010 ;переключаем в 1 CS  PB1 --> D9
			pop OSRG
			DOUT SREG,OSRG ;восстанавливаю статусный регистр
			call InterSPI
			ret
;
;
;----------------------->>>>>PointCheck<<<<------------------------------------------
;Процедура вывода указателя
PointCheck:		sbrs CountEncoder,1 ;пропуск следующей команды если бит установлен
				rjmp PCh1
;Cюда перешли если выбран синусоидальный сигнал
			ldi FsMM,2   ;стартовая строка
			ldi FsML,3   ;конечная
			ldi FsLM,0   ;стартовый столбец
			ldi FsLL, 15 ;конечный столбец
			call PoInfPro ;процедура вывода указателя
			ret
PCh1:		sbrs CountEncoder,2 ;пропуск следующей команды если бит установлен
			rjmp PCh2
;Cюда если выбран трехугольный сигнал
			ldi FsMM,3  ;стартовая строка
			ldi FsML,4  ;конечная
			ldi FsLM,0   ;стартовый столбец
			ldi FsLL, 15 ;конечный столбец
			call PoInfPro
			ret
PCh2:		sbrs CountEncoder,3
			rjmp PCh3
;Сюда если вывод старшего пита DAC
			ldi FsMM,4  ;стартовая строка
			ldi FsML,5  ;конечная
			ldi FsLM,0  ; стартовый столбец
			ldi FsLL, 15; конечный столбец
		    call PoInfPro
			ret
;Cюда если старший бит DAC/2
PCh3:		ldi FsMM,5  ;стартовая строка
			ldi FsML,6 ;конечная
			ldi FsLM,0 ;стартовый столбец
			ldi FsLL, 15 ;конечный столбец
			call PoInfPro
			ret
;----------------------->>>>>OpMode<<<<------------------------------------------
;Процедура установки режима работы модуля AD9833
OpMode:		sbrs CountEncoder,1 ;пропуск следующей команды если бит установлен
			rjmp OpM1
;Cюда перешли если выбран синусоидальный сигнал
			ldi SecByte, 0b00000000
			sts DcomH,SecByte ;<<-------
			ret
OpM1:		sbrs CountEncoder,2 ;пропуск следующей команды если бит установлен
			rjmp OpM2
;Cюда если выбран трехугольный сигнал
			ldi SecByte, 0b00000010
			sts DcomH,SecByte ;<<<------ старший байт
			ret
OpM2:		sbrs CountEncoder,3
			rjmp OpM3
;Сюда если вывод старшего пита DAC
			ldi SecByte,0b00100000
			sts DcomH,SecByte ;<<<------ старший байт
			ret
;Cюда если старший бит DAC/2
OpM3:		ldi SecByte,0b00101000
			sts DcomH,SecByte ;<<<------ старший байт
			ret
; ------------------------>>>mul32<<----------------------
;Программа умножения двух положительных 32х разрядных слов.
 ;Mn1 Mn2 VremenPrH VremenPrL Множимое(Заменить на мои регистры)  от старшего к младшему
 ;та частота которая будет отправлена
 ;Mng1 Mng2 Mng3 Mng4 Множитель
 ;FsMM FsML FsLM FsLL ;Результат (FsMM старший)
;============================================
mul32:	ldi Quant,32 ;количество умножаемых бит
		clr FsMM;очищаем результат
		clr FsML
		clr FsLM
		clr FsLL 
 Shft:	lsr Mng1 ;сдвиг множителя вправо
		ror Mng2
		ror Mng3
		ror Mng4
		brcs Sum ;переход если был перенос
;Переноса не было пропускаем суммирование
	;влево влево множимого
ShftL:	lsl VremenPrL
		rol VremenPrH ;логический сдвиг влево через перенос
		rol Mn2
		rol Mn1
		dec Quant
		BRNE Shft
; Сюда если прошли все повторения
		;mov r1,r9  ;запись результата в регистры множимого
		;mov r2,r10
		;mov r3,r11
		;mov r4,r12 ;не переписываем в регистры множимогоч
		ret  ;выход из процедуры
Sum:    add FsLL,VremenPrL
		adc FsLM,VremenPrH
		adc FsML,Mn2
		adc FsMM,Mn1
		BRCC ShftL ;переход если нет переноса
ExErr:	SET ;установка флага ошибки
		RET
;------------------------->>>FrTr<<<<-------------------------------------
;Передача значения частоты на микросхему
FrTr:	 ldi OSRG, TS_WordTr ; Добавляю задачу в очередь (Задача вывода команды)
		 call QueProcedur
		 ldi FisByte, 0b00100001 ; держу reset сброшеным. восстанавливаю 
;после передачи. Это данные слова управления
		
		 ldi SecByte,0b00000000  ;
		 ldi Quant, 1    ; Указываем что пишем одно слово
		 call QueData 
;
		 ldi Quant,0b01000000 ;добавляю адрес регистра частоты к данным
		 or FsLM,Quant
         or FsMM,Quant
		 ldi OSRG, TS_TwoWordTr ; Добавляю задачу в очередь
		 call QueProcedur
; Сначала шлю младшее слово частоты потом старшее
		mov FisByte, FsLM  ;младшее слово старший байт
		mov SecByte,FsLL   ;младшее слово младший баайт
		mov ThirByte,FsMM; Старший байт старшее слово
		mov FourtByte,FsML ;Младший байт старшее слово
		ldi Quant,2 ;шлем 2 слова
		call QueData
;В этой части сбрасываю reset(ad9833) после записи в регистры
;МОЖНО ЛИ СБРОСИТЬ ВО ВРЕМЯ ЗАПИСИ?
;Здесь выводим кроме отключения сброса данные о режиме работы.
		ldi OSRG, TS_WordTr ; Добавляю задачу в очередь
		call QueProcedur
		ldi FisByte, 0b00000000 ;cбрасываю ресет 
		lds SecByte,DcomH ;<<<------ здесь передаю режим (старший байт)
		ldi Quant, 1    ; Указываем что пишем одно слово
		call QueData
;Проверяю завершили ли передачу
	    call PrSt
	   ret
;Сначало шлю 
;------------------------->>>Conf_Time0<<<<--------------------------------
;Конфигурация таймера 0 на подсчет.
;TIMSK0 регистр разрешения прерывания для разрешения устанавливается 1 в соответсвующий бит. и 1 в I SEREG
;          TOIEn[0] флаг разрешения прерывания по переполнению таймера счетчика
;          OCIEn флаг разрешения прерывания по событию совпадение таймера\счетчика
;          OCIEnA|B|C[2][3] флаг разрешения прерывания по событию "Совпадение А" таймера\счетчика
;          TICIEIn флаг разрешения прерывания по собитию "Захватэ" таймера счетчика
;          ICIEn флаг разрешения по событию "Захват"
;TIFR0    флаг разрешения прерываний
;GTCCR Управление предделителями таймеров счетчиков.
;              TSM[7] = остановка предделителей запись 1 сюда
;              PSRSYNC/PSRASY[0][1] для сброса предделителей (запись 1 в эти биты)
;OCRnA|B регистры сравнения 
;TCCRnA|B предназначены для управления модулем таймера счетчика
;TCCR(0|2)A             COM0A1   COM0A0  COM0B1  COM0B0    -----   ----    WGM01   WGM00
;TCCR(0|2)B             FOC0A    FOC0B   -----   ------    WGM02   CS02    CS01    CS00
;С делителем на 1024 переполнение происходит ((16*10^6)/1024)/256= 61.03 раз в секунду
;Примерно 0.1 сек
Conf_Time0:	ldi FisByte,1
			sts TIMSK0,FisByte
			ldi FisByte, (1<<CS02)|(1<<CS00)
			out TCCR0B,FisByte
			ret

;------------------------------->>>>Wait<<<--------------------------
;Процедура ожидания после нажатия на Энкодер.
;Используется для выхода в предыдущее меню по длительному нажатию.
Wait:	ldi FisByte,0
		mov Mng1,FisByte
MPD:	cp SecByte,Mng1
		BRLT MPD3 ;переход если меньше
		nop
		rjmp MPD
MPD3:   SBIC PIND,PD3          ;пропуск следующей команды если бит сброшен
		ret
		ldi FisByte,0
		mov Mng1,FisByte
		ldi SecByte,95   ;95 или 2 <<<------Заменил для отладки
MPD1:	cp SecByte,Mng1
		BRLT MPD4 ;переход если меньше
		nop
		rjmp MPD1
MPD4:	ldi FisByte,0 ;отключаю таймер
		sts TIMSK0,FisByte
		cli
		SBIC PIND,PD3          ;пропуск следующей команды если бит сброшен
		ret
;Cюда если кнопка нажата на протяжении 2сек.
		dec CE
		dec CE
		ret		
;==================================================================================================
;Прерывания
;------------------------>>>InterSPI<<<----------------------------------------
;Прерывание вызывает из очереди процедуру на выполнение
InterSPI:	cli    ; запрещаем прерывания.
			push Tmp2
			in Tmp2,SREG ; Сохраняем значение флагов
			push Tmp2;
			ldi ZL,low(TaskQueue)
			ldi ZH,high(TaskQueue) 
			ld Tmp2,Z		;берем номер текущей задачи
			cpi Tmp2,0xFF	;если в очереди нет задач выходим !!ВНИМАНИЕ!!!
			BREQ EndInterSPI
; Переходим сюда для вызова задачи из очереди
			clr ZH ;сбрасываю старший байт
			lsl  Tmp2 ; взятый номер задачи умножаем на 2. Т.к. адреса двухбайтные
			mov ZL, Tmp2
			subi ZL, low(-TaskProcs*2) ;смещение по таблице
			;складываем с начальным адресом массива адресов
			sbci ZH, high(-TaskProcs*2) ; тоже только с переносом
			;Теперь Z указывает на адрес где лежит адрес необходимой процедуры
			lpm Tmp2,Z+ ;берем младший байт нашей процедуры по адресу
			mov r0,Tmp2
			lpm Tmp2,Z+ ; берем старший байт адреса процедуры по адресу в r0
			mov ZH,Tmp2 ;теперь в Z адрес перехода
			mov ZL,r0
			pop Tmp2 ; Возвращаем флаги. Если там прерывание было 
			out SREG,Tmp2 ; разрешено, то оно вернется в это значение.  Не попртим т.к дальше хожряняем и потом восстанавливаем
			pop Tmp2;
			ijmp   ; переходим в задачу
			ret
EndInterSPI: ldi ZL, low(MasByte) ; дальше нет процедур 
			 sts CurrentByteL, ZL ;При следующем вызове процедуры передачи данных пишем и читаем сначала
			 sts ReadDatL,ZL 

			 ldi ZH, high(MasByte) 
			 sts CurrentByteH,ZH
			 sts ReadDatH,ZH
			 pop Tmp2 ; Возвращаем флаги. Если там прерывание было 
			 out SREG,Tmp2 ; разрешено, то оно вернется в это значение. 
			 pop Tmp2;
			 ret
;
;
; ----------------------->>> Encoder <<<--------------------------------------------------
Encoder:		cli
				in FisByte, PIND
				andi FisByte,0b00010000 ;запоминаем состояние второго вывода
				;для определения в какую сторону повернули
				mov CE,CountEncoder
				andi CE,0b01100000
				cpi CE,0
				BRNE EnC1 ;переход если не равно
;Cюда зашли если не было нажатий но повернули ручку
				ldi Quant,1
				EOR CountEncoder,Quant
;Тут прорисовываем лампочки, перерисовываю меню
				sbi PORTC,0 ;установка бита
				sbrs CountEncoder,0 ;пропуск следующей если бит установлен
				cbi PORTC,0 ;сброс бита
				
				;out PORTC,CountEncoder ;<<<<---------------Внимание
;Дальше записываю в очередность процедур продедуры вывода на экран данных 
				mov Quant,CountEncoder
				andi Quant,1 
				cpi Quant,0 
				brne SFren
;сюда если выбор сигнала
				ldi  FsMM,3 ;стартовая строка
				ldi  FsML,4 ; конечная
				ldi FsLM,0 ;стартовый столбец
				ldi FsLL,15 ;конечный столбец
				rjmp PPoint
;cюда если выбор частоты
SFren:			ldi  FsMM,5 ;стартовая строка
				ldi  FsML,6 ; конечная
				ldi FsLM,0 ;стартовый столбец
				ldi FsLL,15 ;конечный столбец	
;Cюда выводим указатель выбора пункта меню
PPoint:			call QueStartSig  ;Отправка сигнала старт
				call PoInfPro ;Вывод указателя пункта меню
				call QueStopSig ; Отправка сигнала стоп после передачи
				reti ;Разрешены ли здесь прерывания?? Стоит ли запрещать?

;Cюда перешли если было нажатие на энкодер
EnC1:			cpi CE,0x20
				BRNE EnC2
;Cюда перешли по первому нажатию
				mov CE,CountEncoder
				andi CE,0b00011110
				lsr CE  
				mov Quant, CountEncoder 
				andi Quant,0b00000001 ;Проверяем бит 0-частота 1-режим
				cpi Quant,1
				BRNE EnC3 ;переходим для настройки частоты
;Cюда перешли для выбора режима генерации
				cpi FisByte,0
				BRNE EnC4 ;переходим если крутим вправо
;Cюда перешли Если крутим влево, уменьшаем значение указателя выбора режима
				ldi Quant,1
				cp Quant,CE
				BRSH EnC5 ;Меньше или равно переход
				lsr CE ; не вышли за пределы
				jmp EnC7
;Cюда перешли если при кручении вышли за пределы
EnC5:			ldi CE,0x08
				jmp EnC7


;Cюда перешли если крутили вправо
EnC4:			cpi CE,0x08
				BRGE EnC8
				lsl CE ; не вышли за пределы
				rjmp EnC7
;Если вышли за пределы
EnC8:			ldi CE,1
;Cюда для записи значения в CountEncoder и перерисовки меню, вывода значения
EnC7:			LSL CE
				andi CountEncoder,0b11100001
				or CountEncoder,CE
;---->>> Здесь перерисовываем меню, выводим значения<<<<------
;ПОСЛЕ НАЖАТИЯ НЕ ВЫХОДИТЬ В НАЧАЛО. А передать настройки, и ждать
;Выход в предыдущее меню по длительному нажатию
				call QueStartSig
				call PointCheck
				call QueStopSig
				;out PORTC,CountEncoder
				reti ; Или Ret что с флагом по переходу сюда?





;Сюда перехожу если выбран режим изменения частоты (Выбираю шаг изменения)
EnC3: 			cpi FisByte,0
				BRNE EnC9 ;переходим если крутим вправо
				;Cюда перешли если крутим влево
				ldi Quant,1
				cp Quant,CE
				BRSH EnC10 ;Меньше или равно переход
				lsr CE ; не вышли за пределы
				jmp EnC11
;Cюда при уменьшении выйдем за пределы. Потому изменяем
EnC10:			ldi CE,0x08 ;<<----
				jmp EnC11
EnC9:			cpi CE,0x08
				brge EnC12  ;Перехол если вышли за пределы
				lsl CE
				RJMP EnC11
;Вышли за пределы
EnC12:          ldi CE,1
;Сюда переходим для отправки байт данных, перерисовки меню частоты
EnC11:	LSL CE
		andi CountEncoder,0b11100001
		OR CountEncoder,CE ;устанавливаем новое значение
; Добавить необходимые функции вывода <<<----------------------------
		out PORTC,CountEncoder
		reti ; ret или 	reti??	
;Сюда перестаем входить только после следующего нажатия

;Cюда для проверки второго нажатия
EnC2:	;cpi CE,0x40
		SBRS CE,6 ;пропуск следующей команды если бит установлен
		jmp EnC13 ; Перешли по третьему нажатию
		;cpi FisByte,0
		SBRC CE,5 ;пропуск следующей команды если быт сброшен
		jmp EnC13
		SBRS FisByte,4 ;пропуск следующей команды если бит установлен
		jmp EnC14 ;переходим если крутим вправо
;Крутим влево ((( Все ли правлиьно здесь)
		mov CE,CountEncoder
		andi CE,0b00000010
		cpi CE,2
		BRNE EnC20
;Переходим сюда если увеличиваем на 1 кГц
	ldi FisByte,0x01
	clr SecByte
	add NumFrL,FisByte
	adc NumFrH,SecByte
	jmp EnC15

EnC20: 		SBRC CountEncoder,2    ;пропуск следующей команды если бит сброшен
			RJMP EnC16 ;переходим для увеличения на 10Кгц
			SBRC CountEncoder,3    ;пропуск следующей команды если бит сброшен
			RJMP EnC50 ;Увеличиваем на 100кгц
;Увеличиваем на 500кГц
			ldi FisByte,0xF4
			ldi SecByte, 1
			add NumFrL,FisByte
			adc NumFrH,SecByte
			rjmp EnC15
;для увеличения на 10Кгц
EnC16:	ldi FisByte,0x0A
		clr SecByte
		add NumFrL,FisByte
		adc NumFrH,SecByte
		rjmp Enc15
;Для увеличения на 100кГц
EnC50:	ldi FisByte,0x64
		clr SecByte
		add NumFrL,FisByte
		adc NumFrH,SecByte

;Проверяем не вышло ли полученное число за пределы
EnC15:	mov FisByte,NumFrH
		cpi FisByte,0x30
		brlt EnC51 ; Переход если меньше
		clr NumFrH
		clr NumFrL
		rjmp EnC55
EnC51: 	mov FisByte,NumFrH
		cpi FisByte,0
	   brlt EnC52 ;переход если меньше
EnC55: ldi FisByte,0
;Запись множимого
		mov Mn1,FisByte
		mov Mn2,FisByte
		mov VremenPrH,NumFrH
		mov VremenPrL,NumFrL
;Запись множителя 10737
		mov Mng1,FisByte
		mov Mng2,FisByte
		ldi FisByte,0x29
	    ldi SecByte, 0xF1
		mov Mng3,FisByte
		mov Mng4,SecByte
		rjmp EnC53
EnC52:	ldi FisByte,0x30
		ldi SecByte, 0xD4
		mov NumFrH,FisByte
		mov NumFrL,SecByte
		rjmp EnC55

;старая проверка влана то влазит ли число в поученный диапазон(Можно удалить)
EnC53:  call mul32 ;умножение	

		mov CE,FsMM
		andi CE,0b00001000
		cpi CE,8
		BRNE EnC17   ;переход 
; Выводить нельзя обнуляем число вышло за пределы
		clr FsMM
		clr FsML
		clr FsLM
		clr FsLL
; Формирую регистры перед передачей в микросхему
EnC17: ;перед этим всем сохранить старые значения в стеке а потом вернуть после вывода
		push FsMM
		push FsML
		push FsLM
		lsl FsMM
		lsl FsML
		brcc Ts1 ;переход если нет переноса
		ori FsMM,0b00000001 ;
Ts1:	lsl FsLM
		brcc Ts2 ;переход если нет переноса
		ori FsML,0b00000001
Ts2:	lsl FsMM
		lsl FsML
		brcc Ts3 ;переход если нет переноса
		ori FsMM,0b00000001
Ts3:	lsl FsLM
		brcc Ts4 ;переход если нет переноса
		ori FsML,0b00000001
Ts4:	lsr FsLM
		lsr FsLM
;--->>>формирую регистры для постановки задачи в списке <<<-----
;ЗДЕСЬ ДОПИСАТЬ ПРОЦЕДУРЫ ПОСТАНОВКИ ВЫВОДА ДАННЫХ В ОЧЕРЕДЬ --<<<<
		call FrTr ;вызываю процедуру передачи данных и команд в AD9833
;---->>>восстанавливаю старые значения из стека <<<-----
		pop FsLM
		pop FsML
		pop FsMM
        reti ;reti или ret?

EnC14:	 ;Крутим влево
		;andi CE,0b00000010
		SBRS CountEncoder,1 ;пропуск следующей команды если бит установлен
		RJMP EnC21
;Переходим сюда если уменьшаем на 1 кГц
	ldi FisByte,0x01
	clr SecByte
	sub NumFrL,FisByte
	sbc NumFrH,SecByte
	jmp EnC15
;Проверка на 50кгц
EnC21: 		
			;andi CE,0b00000100
			SBRC CountEncoder,2
			RJMP EnC22 ;переходим для уменьшения на 10Кгц
			SBRC CountEncoder,3
			RJMP EnC60
;Уменьшаем на 500кГц
			ldi FisByte,0xF4
			ldi SecByte, 1
			sub NumFrL,FisByte
			sbc NumFrH,SecByte
			jmp EnC15
;Уменьшаем на 10кГц
EnC22:	ldi FisByte,0x0A
		clr SecByte
		sub NumFrL,FisByte
		sbc NumFrH,SecByte
		jmp EnC15
;уменьшаем на 100кГц
EnC60:	ldi FisByte,0x64
		clr SecByte
		sub NumFrL,FisByte
		sbc NumFrH,SecByte
;Cюда зашли если было третье нажатие
EnC13:  ldi CE,0
		ldi CountEncoder,0
;------->>Здесь вывести все что надо <<----------------
		out PORTC,CountEncoder
		reti ;Прерывания надо восстановить
; -------------------------->>PresEn<<<---------------------------------
;Обработчик нажатия кнопки <<<<<---------------------
PresEn:   call Conf_Time0
		  mov CE,CountEncoder
		  andi CE,0b01100000
		  swap CE ; меняю старшие и младшие байты местами
		  lsr CE  ; сдвигаю вправо получаю число раное нажатиям
		  inc CE  ; увеличиваю по нажатию
		  
		  ldi SecByte,14;14 или 1 изменил на время отладки Т.К. долго думает ;Переменная для сравнения длительности задержки
		  sei   ;<<<<<-------Внимание дальше может везде возникнуть перывание
		  call Wait
		  cli
		  cpi CE,0
		  BRLT PE41 ; переход если CЕ<0
		  rjmp PE42

PE41:	  ldi CE,0
PE42:	  cpi CE,2
		  brlt PE1 ;переход если меньше
		  cpi CE,3
		  breq PE2
;Cюда переходим если второе нажатие
		  SBRC CountEncoder,0; пропуск следующей команды если бит сброшен
		  rjmp PE3
;Cюда перешли если нажатие сделали в меню установки частоты
		  SWAP CE
		  LSL CE
		  andi CountEncoder,0b10011111
		  OR CountEncoder,CE
		  call Encoder
		  reti
;Cюда переходим если было третье нажатие 
PE2:	swap CE
		lsl CE
		andi CountEncoder,0b10011111 ;По третьему нажатию переходим в основное меню
		OR CountEncoder,CE
		call Encoder
		reti
;Cюда переходим по первому нажатию
PE1:	swap CE
		lsl CE
		ori CE,0b00000010
		andi CountEncoder,0b10011111
		OR CountEncoder,CE
		ldi FisByte,0xFF
		DOUT PosMemStr,FisByte ; Указываю о сбросе положения указателя
		call QueStartSig ;Отправляю сигнал старт
		call MenSMode ;Прорисовую меню
		call QueStopSig ;Постановка в очередь отправка сигнала стоп
		;call Encoder  ;<<<<-------------------- ИЗМЕНИЛ И ЗАРАБОТАЛО
		reti
;Нажатие сделали в меню выбора режима
PE3: call OpMode ; Передаем команду соответствующую выбранному режиму
	 ldi CountEncoder,0
	 ldi CE,0
	 ;Отсылаю байты конфигурации
	 call Encoder
	 reti
;==================================================================================
;--------------------------->>Time_ms<<-------------------------------
;Cюда переходим по прерыванию от таймера. Частота заходов зависит от настройки предделителя
Time_ms:    inc Mng1
			reti
;====================================================================
;-------------------------->>Eve_TWI<<--------------------------------
;Используються r18,R20, Переходим сюда по прерыванию

Eve_TWI :	DIN r20,SREG ;сохраняем регист статуса в стеке
			push r20
			cli
			DIN r18,TWSR ;получам код статуса
;
			cpi r18,0x08 ;сравнить
			BRNE P0x08 ;переход если не равны
;			
			;Cюда перешли если успешно сформировано состояние старт
Tr_Adr:		call ShiftQue ;Всегда сдвигаю очередь после передачи старт
;<<<-----------Передавать что-то начала бесконечно
			DIN r20,AdrSSD
			DOUT TWDR,r20 ;пишем адрес в буфер передачи
			ldi r20,0b10000101 ;старт передачи адресного пакета
			DOUT TWCR,r20
			pop r20
			DOUT SREG,r20
			reti ;выход из прерывания
;
P0x08 :		cpi r18,0x18
			BRNE P0x18 ;переход если не равны
;
			;Сюда если был передан адрес и приянто подтверждение
			call InterSPI ;Запуск процедуры из очереди
			pop r20
			DOUT SREG,r20
			reti ;++++
;
P0x18 :		cpi r18,0x20	
			BRNE P0x20 ;переход если не равны
;
			;Был передан адрес и не принято подтверждение
			ldi r20,0b10100101 ;Формирую состояние повстарт
			DOUT TWCR,r20
			pop r20
			DOUT SREG,r20
			reti
;
P0x20 :		cpi r18,0x28
			BRNE P0x28 ;переход если не равны
;			
			;Cюда если был передан пакет данных и приянто пожтверждение
			call InterSPI
			pop r20
			DOUT SREG,r20
			reti ;++++
;
P0x28 :		cpi r18,0x30
			BRNE P0x30
;
P0x30 :		cpi r18,0x10
			BRNE P0x10
			;Было сформировано состояние повстарт
			DIN r20,AdrSSD
			DOUT TWDR,r20 ;пишем адрес в буфер передачи
			ldi r20,0b10000101 ;старт передачи адресного пакета
			DOUT TWCR,r20
			pop r20
			DOUT SREG,r20
			reti ;выход из прерывания
;			
P0x10 :		pop r20
			DOUT SREG,r20
			reti
;=============================================================
;0x00 окончание строки
		  S0: .db 0x03,0x0E,0x3C,0x64,0x34,0x1E,0x07,0x00			;а
		  S1: .db 0x41,0x7F,0x49,0x49,0x49,0x66,0x00,0x00			;б
		  S2: .db 0x41,0x7F,0x49,0x49,0x49,0x36,0x00,0x00			;в
		  S3: .db 0x41,0x7F,0x41,0x40,0x40,0x60,0x00,0x00			;г
.org S3+4 S4: .db 1,2,3,4,5,6,7,8			;д
		  S5: .db 0x41,0x7F,0x49,0x49,0x41,0x41,0x00,0x00			;е
		  S6:								;ж
.org S6+4 S7:								;з
.org S7+4 S8: .db 0x7F,0x03,0x07,0x18,0x30,0x7F,0x00,0x00			;и
.org S8+4 S9:								;й
.org S9+4 S10:								;к
.org S10+4 S11:	.db 0x01,0x41,0x7E,0x40,0x40,0x7F,0x40,0x00			;л
.org S11+4 S12:								;м
.org S12+4 S13: .db 0x41,0x7F,0x49,0x08,0x49,0x7F,0x41,0x00			;н
		   S14: .db 0x1C,0x22,0x41,0x41,0x41,0x22,0x1C,0x00			;о
		   S15:	.db 0x41,0x7F,0x41,0x40,0x41,0x7F,0x41,0x00			;п
		   S16:	.db 0x41,0x7F,0x49,0x48,0x48,0x30,0x00,0x00			;р
		   S17:	.db 0x1C,0x22,0x43,0x81,0x81,0x22,0x00,0x00			;с
.org S17+4 S18: .db 0x40,0x40,0x40,0x7F,0x40,0x40,0x40,0x00			;т
		   S19:								;у
.org S19+4 S20:								;ф
.org S20+4 S21:								;х
.org S21+4 S22:								;ц
.org S22+4 S23: .db 0x40,0x78,0x08,0x08,0x08,0x7F,0x41,0x00			;ч
.org S23+4 S24:								;ш
.org S24+4 S25:								;щ
.org S25+4 S26:								;ъ
.org S26+4 S27: .db 0x7F,0x11,0x11,0x1F,0x00,0x7F,0x00,0x00			;ы
		   S28:								;ь
.org S28+4 S29:								;э
.org S29+4 S30:								;ю
.org S30+4 S31: .db 0x00,0x01,0x71,0x4E,0x48,0x7F,0x41,0x00			;я
;
.org S31+4 S32:								;ж
.org S32+4 point: .db 0x00,0x7F,0x7F,0x7F,0x3E,0x1C,0x08,0x00       ;байты указателя(стрелочки)

;128x32
;Программатор
;Белый Vin
;Серый Gnd
;Синий Rst
;Зеленый D11
;Фиолетовый D12
;Черный D13
;
;
;SPI 
;MOSI=	D11=PB3
;SCK=	D13=PB5
;SS     PB1 --> D9  (16bit)
;PC0-5 = A0-A5 Диоды; PC0младший 
;Энкодер 
;Int0=PD2=S1=D2 
;Int1=PD3=Key=D3
;PD4     =S2=D4
;
;AD9833
;D11=DAT
;D9 =FSNK
;D13=CLK

;SSD1308
;PC4=SDA=A4
;PC5=SCL=A5
;Подтягивающие резисторы?
