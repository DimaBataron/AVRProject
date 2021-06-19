/*
 * AsmFile17.asm
 *
 *  Created: 14.06.2021 11:47:06
 *   Author: dima
 *  *	Программа передачи данных на экран SSD1306 128x64 v.0.1
 * TWI устанавливает бит FlagCon[0] по прерыванию. Далее в цикле после установки этого флага 
 * идет проверка на флаг события. Флаги событий можно устанавливать например по прерыванию от энкодера.
 * События используют внешние переменные в ОЗУ. 
 * Изменение данных в них приведет к изменению алгоритма работы.
 * Флаг события автоматически сбрасывает сама процедура после выполнения задания полностью.
 */ 
 .include "F:/AVR/7.0/packs/atmel/ATmega_DFP/1.6.364/avrasm/inc/m328Pdef.inc"
.include "E:/A/AssemblerApplication1/AssemblerApplication1/Macro.inc"
; Replace with your application code
; FLASH ===================================================
;Инициализация стэка
.org 0x0000 jmp RESET ; Reset Handler
.org 0x0002 jmp Encoder_S1; jmp EXT_INT0 ; IRQ0 Handler
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
;
.DSEG
FlagCon: .byte 1	;b[0] - флаг передачи устанавливается только в TWI После операции
                    ;b[1] - флаг стартовой инициализации
                    ;b[2] - флаг позиционирования указателя строки
                    ;b[3] -  флаг позиционирования указателя столбца
                    ;b[4] - флаг очистки дисплея
                    ;b[5] - флаг отправки команд
                    ;b[6] - флаг отправки данных
					;b[7] - символизирует о следуюем пакете настроек и данных в буфере. 
InitCount: .byte 1		;счетчик состояния инициализации
LenMasInit: .byte 1		;длинна массива инициализации
NumWhileInit : .byte 1	;количество повторений цикла передачи конфиг битов
ZInitLow: .byte 1       ;в этой области r30. Сохраняем сюда младший адрес массива инициализации при старте мк.
ZInitHi: .byte 1		;в этой области r31. Cохраняю сюда старший адрес массива при инициализации.
AdrSSD: .byte 1			;адрес ведомого
;
NumWhilePos: .byte 1	 ;количество переданных байт позиционирования
SetPagSt:	 .byte 1     ;стартовый адрес страницы 0-7(строки)
SetPagEnd:	 .byte 1     ;конечный адрес страницы 0-7(строки)
SetColSt:	 .byte 1     ; начальный столбец 0-15(символ)
SetColEnd:	 .byte 1     ;Конечный столбец 0-15 (символ)
CountPosYk:	 .byte 1     ;счетчик состояния позиционирования.
SelectPosYk: .byte 1     ;вложенный для определения байта.
XPosYkLO:    .byte 1     ;для хранения указателя передаваемого байта команды из ОЗУ
XPosYkHi:    .byte 1     ; тоже только старшего
;
CleanSym:    .byte 1 ;количество символов которые надо очистить
CleanNow:    .byte 1 ;очищаемый в данный момент символ
CleanWhile:  .byte 1 ; очищаемый байт в текущий момент
CleanByte:    .byte 1 ; байт которым заполняем все пространство.
CleanFlag:    .byte 1; флаг указывающий о том что уже входили в процедуру и что передавать байт x40 не надо. Не забыть сбросить при выходе!!!
;
TrDatLow:     .byte 1  ;r30. Сохраняем сюда младший адрес массива символов которые выводятся
TrDatHi:      .byte 1  ;в этой области r31. Cтарший байт адреса массива символов
TrDataCount:  .byte 1  ;количество байт одного символа которые уже передали
TrDataCountB: .byte 1  ;флаг того что нужно передать управляющий байт (При инициализации передачи массива символов)
TrSymByteL:   .byte 1  ;указатель на массив передаваемого байта одного символа
TrSymByteH:   .byte 1  ;указатель на массив 
;
XPosComLo:    .byte 1 ;указатель на массив байта команды установки столбца
XPosComHi:	  .byte 1 ;старший байт
;Дальше массив буферных переменных для формирования следующего кадра
SetPagStB:    .byte 1 ;буфер начальной строки
SetPagEndB:	  .byte 1 ;
SetColStB:    .byte 1 ; буфер начального столбца
SetColEndB:	  .byte 1 ;
XPosYkLOB:    .byte 1 ; буфер начального адреса массива позиционирования указателя строки(страницы)
XPosYkHiB:	  .byte 1
XPosComLoB:	  .byte 1 ;буфер начального адреса массива позиционирования указателя столбца(символа)
XPosComHiB:	  .byte 1
CleanSymB:    .byte 1 ;буфер количества символов которые надо очистить
TrDatHiB:	  .byte 1 ;буфер указателя массива данных
TrDatLowB:	  .byte 1
;
CountEncoder: .byte 1 ;счетчик осчитываемый поворотом энкодера
FlagConMas:	  .byte 1 ;буфер флагов
.CSEG
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
Text:	  .db "ты",0 ;ничегонепоняла
Text1:	  .db "ничего",0
Text2:	  .db "не",0
Text3:	  .db "поняла",0
;
 Reset:	cli
		LDI R16,Low(RAMEND)	; Инициализация стека
		OUT SPL,R16		; Обязательно!!!
		LDI R16,High(RAMEND)
		OUT SPH,R16
;===== Инициализируем оперативку начальными значениями==========================
		LDI r18,((AdrSSD0-InitSSD)*2) 
		DOUT LenMasInit,r18 ;Записываем длинну массива инициализации
		ldi r18,0
		DOUT InitCount,r18 ;счетчик состояния инициалиализации
		DOUT NumWhileInit,r18 ;количество повторений цикла передачи конфиг битов
		DOUT NumWhilePos,r18  ;количество переданных байт позиционирования
		DOUT CountPosYk,r18
		DOUT SelectPosYk,r18
		LDI 	ZL,low(InitSSD*2) 	; заносим младший байт адреса, в регистровую пару Z
		LDI  	ZH,high(InitSSD*2)	; заносим старший байт адреса, в регистровую пару Z
		DOUT ZInitLow,ZL ; запоминаю начальный адрес массива инициализации.
		DOUT ZInitHi,ZH
		LDI 	XL,low(SetPagSt) 	;заносим младший байт адреса, в регистровую пару X
		LDI  	XH,high(SetPagSt)	;заносим старший байт адреса, в регистровую пару X
		DOUT XPosYkLO,XL ; запоминаю начальный адрес массива позиционирования
		DOUT XPosYkHi,XH
		;
		LDI XL,low(SetColSt)  ;Запоминаем адреса данных установки столбца.
		LDI XH,high(SetColSt) ;Далее в коде меняем только эти переменные
		DOUT XPosComLo, XL
		DOUT XPosComHi, XH
		;
		ldi r18,0
		DOUT CleanNow,r18
		DOUT CleanWhile,r18
		DOUT CleanByte,r18
		DOUT CleanFlag,r18
		;
		DOUT TrDataCount,r18
		DOUT TrDataCountB,r18
		;
		DOUT CountEncoder,r18
;
;==================================================================================
;Конфигурация INT0 по спадающему фронту Вывод D2=PD2 конфигурирую енкодер
;И INT1
		ldi r18,0b00000010	;По спадающему фронту на выходе INTn
		DOUT EICRA,r18		
		ldi r18,0b00000001  ;разрешаем внешние прерывания INT0
		DOUT EIMSK,r18
;=========================================================
;Код формирования данных для начала передачи
		LDI r18,0b01111000
		DOUT AdrSSD,r18		;записываем адрес ведомого
		TWFscl 70,0 ;ставлю 102.6кГЦ скороть работы TWI Fscl ;SSD1306 максимум 400кГц
		;
		
		ldi r18,0x12
		DOUT FlagCon,r18 ;устанавливаю флаг начала стартовой инициализации
		 ;позицонирования указателя строки
		;очистки дисплея и отправки данных
		/*
		ldi r18,0
		DOUT SetPagSt,r18 ;стартовая  строка (0-7)
		ldi r18,7
		DOUT SetPagEnd,r18 ; конечная строка (0-7)
		;
		ldi r18,0 ; начальный столбец
		DOUT SetColSt,r18
		ldi r18,15 ; конечный столбец
		DOUT SetColEnd,r18
		*/
		ldi r18,128
		DOUT CleanSym,r18  ;количество символов которые надо очистить
		/*
		;
		LDI 	ZL,low(Text*2) 	; заносим младший байты адреса символов которые нужно выводить
		LDI  	ZH,high(Text*2)	
		DOUT TrDatLow,ZL    
		DOUT TrDatHi,ZH ;сохраняем байты массива символов которые нужно вывести.      
		*/
		ldi r18,0b10100101 ;формируем состояние СТАРТ на шине TWI
		DOUT TWCR,r18
		sei		;разрешаю прерывания
;=============ОСНОВНОЙ ЦИКЛ ПРОГРАММЫ=================================
Main:	DIN r18,FlagCon
		ANDI r18,1
		cpi r18,1
		BRNE Main ; переходим к началу если FlagCon[0]=0 
;		
		DIN r18,FlagCon
		ANDI r18,0b11111110
		DOUT FlagCon,r18    ;отключаю флаг успешной передачи. Он восстановится только модулем TWI
		ANDI r18,2
		cpi r18,2   ;Проверяю установлен ли флаг стартовой инициализации
		Brne FlPosYk   ; перехожу для проверки флага установки указателя строки
;b[1] -сюда если  флаг стартовой инициализации устанолен
		call StartInit
		jmp Main
;
FlPosYk: DIN r18,FlagCon
		 ANDI r18,4
		 cpi r18,4
		 Brne FlConYk   ; перехожу для проверки флага очистки
;b[2] - сюда если установлен флаг позиционирования указателя строки
		call PosYkP
		jmp Main
;
FlConYk: DIN r18,FlagCon
		 ANDI r18,8
		 cpi r18,8
		 Brne CleanFl
;b[3] - сюда если установлен флаг позиционирования столбца
		 call PosYkCol
		 jmp Main
; ПРОПУСТИЛ ДОПИСАТЬ
CleanFl: DIN r18,FlagCon
		 ANDI r18,16  ;проверяю установлн ли флаг очистки
		 cpi r18,16
		 Brne SymTr; перехожу для проверки флага отправки массива данных строки (ИЗМЕНИТЬ)
;b[4] сюда если устанолен флаг очистки дисплея
		 call Clean
		 jmp Main
SymTr:   DIN r18,FlagCon
		 ANDI r18,64
		 cpi r18,64
		 BRNE BufFlag ;перехожу если сбросили флаг передачи.
;b[6]- cюда если устанолен флаг передачи
		 call TrData
		 jmp Main
BufFlag: DIN r18,FlagCon
		 ANDI r18,128
		 cpi r18,128
		 BRNE End
;b[7] - сюда если надо передать следующие байты в память экрана
		 call BufData
		 jmp Main

End:	sei   ;выходим из передачи формируем повстарт после которого флаги прерывания сбрасываются и не восстанавливаются
		;Формирую состояние стоп
		ldi r18,0b10010101
		DOUT TWCR,r18
		jmp Main ; переходим если меньше или равно
;====================Процедуры=============================================
	;-------------->>StartInit <<----------------------------
;Для запуска этой подпрограммы используються такие переменные
;NumWhileInit				;LenMasInit					;InitCount
;ZInitLow					;ZInitHi				    ;
;Регистры r18,r19 
StartInit: DIN r18,NumWhileInit
		   DIN r19,LenMasInit
		   cp r18,r19
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
		   inc r18
		   DOUT InitCount,r18
		   DIN r18,NumWhileInit
		   inc r18
		   DOUT NumWhileInit,r18
		   DIN ZL,ZInitLow
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
InitEnd:   ldi r18,0
		   DOUT NumWhileInit,r18
		   DOUT InitCount,r18
		   DIN r18,FlagCon
		   ANDI r18,0b11111101 ;b[1] - отключаю флаг стартовой инициализации
		   DOUT FlagCon,r18 ; Отключаю флаг инициализации т.к. все байты передали
		   ldi r18,0b10100101;Формирую состояние повстарт
		   DOUT TWCR,r18 
		   reti
;
;
;---------------->>>PosYkP<<<-----------------------------------------
;Процедура позиционирования указателя страница(строка)
;Используемые байты в оперативе 
;NumWhilePos		EndTrCom			CountPosYk
;SelectPosYk		XPosYkLO			XPosYkHi
;1.Использование: Загрузить в ОЗУ по адресам  SetPagSt SetPagEnd
;Стартовый и конечный адрес страницы(только для горизонтальной и вертикальной адресации)
;2.Занести в пару значений XPosYkHi:XPosYkLO адрес ОЗУ SetPagSt
;3.Установить флаг FlagCon[2]
;4.После установки всех флагов сформировать состояние старт.
PosYkP:	   DIN r18,NumWhilePos
		   cpi r18,3
		   brge  EndTrCom  ;переход если передали 3байта позиционирования строки
		   DIN r19,CountPosYk
		   cpi r19,0
		   BRNE CountContr ; Переход если повстарт уже было сформировано
;Сюда переходим для формирования состояния повстарт
		   inc r19
		   DOUT CountPosYk,r19
		   ldi r19, 0b10100101 ;формирую состояние повстарт
		   DOUT TWCR,r19
		   reti
CountContr:	cpi r19,1
		    BRNE CounComand ;<Переходим для передачи непосредственно команды
;Cюда перешли для передачи управляющего байта
		    inc r19
		    DOUT CountPosYk,r19
		    ldi r19,0x00
			DOUT TWDR,r19 ; передаем управляющий байт
			ldi r19,0b10000101
			DOUT TWCR,r19 ;Продолжаем передачу
			reti
;Cюда переходим для передачи команды
CounComand: ldi r19,0
			DOUT CountPosYk,r19
			DIN r19,SelectPosYk
			inc r18
			DOUT NumWhilePos,r18
			cpi r19,0
			BRNE CouComCon ;Переход для отправки конфигурационных байт команды
;Здесь отправляем первый байт команды
			ldi r18,0x22
			inc r19
			DOUT SelectPosYk,r19
			DOUT TWDR,r18
			ldi r18,0b10000101 ; Продолжаем передачу
			DOUT TWCR,r18
			reti
;Cюда переходим для отправки оставшихся байт команды
CouComCon:  DIN XL,XPosYkLO
			DIN XH,XPosYkHi
			LD r18,X+
			DOUT TWDR,r18
			DOUT XPosYkLO, XL
			DOUT XPosYkHi,XH
			ldi r18,0b10000101
			DOUT TWCR,r18 ; Продолжаем передачу
			reti
;Передали все данные тепрь главное выйти отсюда
EndTrCom:	ldi r18,0
			DOUT NumWhilePos,r18
			DOUT CountPosYk,r18
			DOUT SelectPosYk,r18
			DIN r18,FlagCon
			ANDI r18,0b11111011
			DOUT FlagCon,r18
			LDI r18,0b10100101
			DOUT TWCR,r18 ;Формирую состояние повстарт
			reti
;=======================================================================
;---------------->>>PosYkCol<<<-----------------------------------------
;Процедура позиционирования указателя страница(строка)
;Используемые байты в оперативе 
;NumWhilePos		CountPosYk			SetColSt			SetColEnd
;SelectPosYk		XPosComLo			XPosComHi
;1.Использование: Загрузить в ОЗУ по адресам  SetColSt SetColEnd
;Стартовый и конечный адрес страницы(только для горизонтальной и вертикальной адресации)
;2.Занести в пару значений XPosComHi:XPosComLo адрес ОЗУ SetColSt
;3.Установить флаг FlagCon[3]
;4.После установки всех флагов сформировать состояние старт

PosYkCol:  DIN r18,NumWhilePos
		   cpi r18,3
		   brge  EndTrCom12  ;переход если передали 3байта позиционирования строки
		   DIN r19,CountPosYk ;счетчик состояния позиционирования.
		   cpi r19,0
		   BRNE CountContr1 ; Переход если повстарт уже было сформировано
;Сюда переходим для формирования состояния повстарт
				inc r19
				DOUT CountPosYk,r19
				ldi r19, 0b10100101 ;формирую состояние повстарт
				DOUT TWCR,r19
				reti
CountContr1:	cpi r19,1
				BRNE CounComand1 ;<Переходим для передачи непосредственно команды
;Cюда перешли для передачи управляющего байта
				inc r19
				DOUT CountPosYk,r19
				ldi r19,0x00   
				DOUT TWDR,r19 ; передаем управляющий байт
				ldi r19,0b10000101
				DOUT TWCR,r19 ;Продолжаем передачу
				reti
				Jmp CounComand1
EndTrCom12:		RJMP EndTrCom1
;Cюда переходим для передачи команды
CounComand1:	ldi r19,0
				DOUT CountPosYk,r19
				DIN r19,SelectPosYk ;вложенный для определения байта.
				inc r18
				DOUT NumWhilePos,r18
				cpi r19,0
				BRNE CouComCon1 ;Переход для отправки конфигурационных байт команды
;Здесь отправляем первый байт команды
			ldi r18,0x21 ;Set Column Address
			inc r19
			DOUT SelectPosYk,r19
			DOUT TWDR,r18
			ldi r18,0b10000101 ; Продолжаем передачу
			DOUT TWCR,r18
			reti
;Cюда переходим для отправки оставшихся байт команды
CouComCon1:		DIN XL,XPosComLo ; Переписать
				DIN XH,XPosComHi  ;
				LD r18,X+
				; Сдесь изменил
				lsl r18
				lsl r18
				lsl r18 ;умножение на 8
				cpi r18,120 ; Последний символ. Сдвигаем до конца.
				Brne TrComDat1 ;не конец перейти далее
				ldi r18,127
TrComDat1:		DOUT TWDR,r18
				DOUT XPosComLo,XL
				DOUT XPosComHi,XH
				ldi r18,0b10000101
				DOUT TWCR,r18 ; Продолжаем передачу
				reti
;Передали все данные тепрь главное выйти отсюда
EndTrCom1:		ldi r18,0
				DOUT NumWhilePos,r18
				DOUT CountPosYk,r18
				DOUT SelectPosYk,r18
				DIN r18,FlagCon
				ANDI r18,0b11110111  
				DOUT FlagCon,r18
				LDI r18,0b10100101
				DOUT TWCR,r18 ;Формирую состояние повстарт
				reti
;
;---------------------->> Clean <<-----------------------------
Clean: DIN r18,	CleanNow
	   DIN r19, CleanSym
	   cp r18,r19
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
			DIN r20, FlagCon
			ORI r20,0b00000001 ;b[0] - флаг передачи устанавливается только в TWI После операции
			;Устанавливаю этот флаг чтобы перейти снова сюда
			DOUT FlagCon,r20
			ret
;Сюда Переходим для оконания передачи.
EndClean:   ldi r18,0
			DOUT CleanNow,r18
			DOUT CleanFlag,r18
			DIN r18,FlagCon
			ANDI r18,0b11101111 ;Отключаю флаг очистки
			DOUT FlagCon,r18
			ldi r18,0b10100101
			DOUT TWCR,r18
			;Формирую состояние повстарт
			reti
;
;---------------------TrData------------------------------
;Процедура принимающая на вход массив байт для вывода. 0 признак онончания массива.
TrData: DIN r18, TrDataCountB
		cpi r18,0 
		BRNE TrComp ;   если не равно переход(уже передавали управляющий байт
;cюда переходим для передачи управляющего байта
		ldi r18,1
		DOUT TrDataCountB,r18
		ldi r18,0x40 ;устанавливаем управляющий байт, символизирующий о сплошном массиве байт
		DOUT TWDR,r18
		ldi r18,0b10000101 ; Продолжаем передачу
		DOUT TWCR,r18
		reti
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
		DIN r18,FlagCon
		ANDI r18, 0b10111111
		DOUT FlagCon,r18
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
			DIN r18,FlagCon
			ORI r18, 0b00000001 ;b[0] - устанавливаю флаг передачи чтобы войти сюда снова
			DOUT FlagCon,r18
			ret
;
;--------------------->>PosColRowSt<<-------------------------
; Процедура формирования буферных значний конфигурации экрана для следующего кадра
PosColRowSt: ldi r18,3
			 DOUT SetPagStB,r18 ;стартовая  строка (0-7)
			 ldi r18,3
			 DOUT SetPagEndB,r18 ; конечная строка (0-7)
			 ldi r18,6 ; начальный столбец
			 DOUT SetColStB,r18
			 ldi r18,15 ; конечный столбец
			 DOUT SetColEndB,r18
			 LDI XL,low(SetPagStB) ;заносим младший байт адреса, в регистровую пару X
			 LDI  XH,high(SetPagStB)	;заносим старший байт адреса, в регистровую пару X
			 DOUT XPosYkLOB,XL ; запоминаю начальный адрес массива позиционирования
			 DOUT XPosYkHiB,XH
;
			LDI XL,low(SetColStB)  ;Запоминаем адреса данных установки столбца.
			LDI XH,high(SetColStB) ;Далее в коде меняем только эти переменные
			DOUT XPosComLoB, XL
			DOUT XPosComHiB, XH
			ldi r18,10
			DOUT CleanSymB,r18  ;количество символов которые надо очистить
			DIN r18,FlagCon
			ORI r18,0b10000000
			DOUT FlagCon,r18 ;указываем что в буфере лежат данные и код
			ret
;
;------------------>>BufData<<------------------------------------
;Процедура записывающая буферные данные в основные переменные для рисования следующего кадра
BufData:  DIN r18, SetPagStB
		  DOUT SetPagSt,r18
		  ;
		  DIN r18, SetPagEndB
		  DOUT SetPagEnd,r18
		  ;
		  DIN r18, SetColStB
		  DOUT SetColSt,r18
		  ;
		  DIN r18, SetColEndB
		  DOUT SetColEnd,r18
		  ;
		  DIN r18, XPosYkLOB
		  DOUT XPosYkLO,r18
		  ;
		  DIN r18, XPosYkHiB
		  DOUT XPosYkHi,r18
		  ;
		  DIN r18, XPosComLoB
		  DOUT XPosComLo,r18
		  ;
		  DIN r18, XPosComHiB
		  DOUT XPosComHi,r18
		  ;
		  DIN r18, CleanSymB
		  DOUT CleanSym,r18
		  ;
		  DIN r18, TrDatLowB  
		  DOUT TrDatLow,r18
		  ;
		  DIN r18, TrDatHiB
		  DOUT TrDatHi,r18  
		  
		  DIN r18,FlagConMas
		  cpi r18,0x1C
		  BREQ StartTR  ;переход если равны
		  DIN r18,TrDatLowB ;Записываю начальный адрес массива символов из буфера в основные переменные
		  DOUT TrDatLow,r18
		  DIN r18,TrDatHiB
		  DOUT TrDatHi,r18   
StartTR:  DIN r18,FlagCon
		  DIN r19,FlagConMas
		  OR r18,r19
		  DOUT FlagCon,r18
		  ldi r18,0
		  DOUT FlagConMas,r18
		  DIN r18,FlagCon
		  ANDI r18,0b01111111 ;=отключаю флаг символизирующий о следуюем пакете настроек и данных в буфере.
		  DOUT FlagCon,r18
		  reti
		  
;===================ПРЕРЫВАНИЯ============================================
;Используються r18,R20, Переходим сюда по прерыванию
Eve_TWI :	DIN r18,TWSR ;получам код статуса
			DIN r20,SREG ;сохраняем регист статуса в стеке
			push r20
;
			cpi r18,0x08 ;сравнить
			BRNE P0x08 ;переход если не равны
;			
			;Cюда перешли если успешно сформировано состояние старт
Tr_Adr:		DIN r20,AdrSSD
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
			DIN r20,FlagCon
			ORI r20,0b00000001 ; Логическое ИЛИ рон и константы 
			DOUT FlagCon,r20  ;Устанавливаем флаг передачи
			pop r20
			DOUT SREG,r20
			ret ;++++
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
			DIN r20,FlagCon
			ORI r20,0b00000001 ;
			DOUT FlagCon,r20  ;Устанавливаем флаг передачи данных
			pop r20
			DOUT SREG,r20
			ret ;++++
;
P0x28 :		cpi r18,0x30
			BRNE P0x30
; ЗДЕСЬ ПЕРЕПИСАТЬ ДЛЯ МОИХ ФУНКЦИЙ
/*
			;Был передан пакет данных подтверждение не принято
			DIN r20,FlagCon
			ANDI r20,1 ;установлен ли флаг передачи конфигурационных байт?
			cpi r18,0
			BREQ  P0x10 ;переходим если 0 ;ДОПИСАТЬ ДЛЯ СЛУЧАЯ КОГДА НЕ ПЕРЕДАНЫ БАЙТЫ ДАННЫХ

			;сюда если не получилось передать конфиг байт
			DIN r20,NumWhile ;уменьшаем счетчик переданных байт.
			DEC r20
			DOUT NumWhile,r20
			;Z=R31:R30 регистровая пара в которой хранится адрес того что передаем
			SBIW R30:R31,1 ;вычитаем из указателя адреса в памяти программ байт
			;Передаю снова
			DIN r20,FlagCon
			ORI r20,1 ; Логическое ИЛИ рон и константы 
			DOUT FlagCon,r20; Передаем тот-же конфиг байт снова
			pop r20
			DOUT SREG,r20
			ret ;++++
*/
;
P0x30 :		cpi r18,0x10
			BRNE P0x10
			;Было сформировано состояние повстарт
			rjmp Tr_Adr
;			
P0x10 :		pop r20
			DOUT SREG,r20
			reti
;==================================================================================
;r18 к19
;Переходим сюда по прерыванию Int0 
;							;PD4 = S2 = D4 (влево отключаем, вправо включаем)
;							 PD2 = S1 = D2 = INT0
Encoder_S1: DIN r18,SREG ;сохраняем регист статуса в стеке
			push r18
			DIN r18,PIND
			ANDI r18,(1<<PD4)
			cpi r18,0  ;сравнение рон с константой 
			BRNE One
			;сюда перешли если = 0 крутим влево  уменьшаем счетчик
			DIN r18,CountEncoder
			ldi r19,0
			cp r19,r18  ;тут внимание мог ощибится
			BRLT NotNull;переход если больше 
			ldi r18,4
			DOUT CountEncoder,r18 
			RJMP FlagInst  ;проверка того что накрутили
NotNull:	dec r18
			DOUT CountEncoder,r18
			RJMP FlagInst  ; проверка того что накрутили
; Сюда перешли если крутим вправо увеличиваем счетчик
One:		DIN r18,CountEncoder
			cpi r18,4
			BRLT IncCount ;переходим если меньше 4
			;cюда если больше или равно
			ldi r18,0
			DOUT CountEncoder,r18
			RJMP  FlagInst ; проверка того что накрутили
IncCount:	inc r18
			DOUT CountEncoder,r18
FlagInst:	call PosColRowSt
			DIN r18,CountEncoder
			cpi r18,0
			BRNE CountNeNULL  ;если не равно переходим
;Cюда для очистки экранчика
			ldi r19,0x1C
			;b[2] - флаг позиционирования указателя строки
			;b[3] -  флаг позиционирования указателя столбца
			;b[4] - флаг очистки дисплея
			DOUT FlagConMas,r19
			JMP EndBufFlag
; CountEncoder==1?
CountNeNULL: cpi r18,1
			 BRNE CountNOne ;если не равно переходим
			 ldi r19,0x5C
			 ;b[2] - флаг позиционирования указателя строки
			 ;b[3] -  флаг позиционирования указателя столбца
			 ;b[4] - флаг очистки дисплея
			 ;Флаг отправки данных
			 DOUT FlagConMas,r19
			 LDI ZL,low(Text*2) ; заносим младший байты адреса символов которые нужно выводить
			 LDI  ZH,high(Text*2)
			 DOUT TrDatLowB,ZL    
			 DOUT TrDatHiB,ZH ;сохраняем байты массива символов которые нужно вывести
			 JMP EndBufFlag
CountNOne:	 cpi r18,2
			 BRNE CountNTwo ;если не равно переходим
			 ldi r19,0x5C
			 DOUT FlagConMas,r19
			 LDI ZL,low(Text1*2) ; заносим младший байты адреса символов которые нужно выводить
			 LDI ZH,high(Text1*2)
			 DOUT TrDatLowB,ZL    
			 DOUT TrDatHiB,ZH ;сохраняем байты массива символов которые нужно вывести
			 JMP EndBufFlag
CountNTwo:	 cpi r18,3
			 BRNE CountNTree ;если не равно переходим
			 ldi r19,0x5C
			 DOUT FlagConMas,r19
			 LDI ZL,low(Text2*2) ; заносим младший байты адреса символов которые нужно выводить
			 LDI ZH,high(Text2*2)
			 DOUT TrDatLowB,ZL    
			 DOUT TrDatHiB,ZH ;сохраняем байты массива символов которые нужно вывести 
			 JMP EndBufFlag
CountNTree:	 cpi r18,4
			 BRNE EndBufFlag ;если не равно переходим
			 ldi r19,0x5C
			 DOUT FlagConMas,r19
			 LDI ZL,low(Text3*2) ; заносим младший байты адреса символов которые нужно выводить
			 LDI ZH,high(Text3*2)
			 DOUT TrDatLowB,ZL    
			 DOUT TrDatHiB,ZH ;сохраняем байты массива символов которые нужно вывести 
EndBufFlag:	 DIN r18,FlagCon
			 ANDI r18,0b01111110
			 cpi r18,0
			 BRNE EndBufFlag1 ;переход если не надо формировать состояние старт
;Cюда для формирвоания старт и передачи массива инициализации
			LDI ZL,low(InitSSD*2) ; заносим младший байт адреса, в регистровую пару Z
			LDI  ZH,high(InitSSD*2)	; заносим старший байт адреса, в регистровую пару Z
			DOUT ZInitLow,ZL ; запоминаю начальный адрес массива инициализации.
			DOUT ZInitHi,ZH ;(Записываю начальные байты инициализации
			DIN r18,FlagCon
			ORI r18,0b00000010
			DOUT FlagCon,r18 ;устанавливаю флаг стартовой инициализации
			ldi r18,0b10100101 ;формируем состояние СТАРТ на шине TWI
			DOUT TWCR,r18
EndBufFlag1:  pop r18
			  DOUT SREG,r18
			  reti
;===========================================================	
;к PD4 = S2 = D4 (влево отключаем, вправо включаем)
;  PD2 = S1 = D2 = INT0
;Подключу светодиод к PD7
;==========================================================
;РЕГИСТРЫ ВНЕШНИХ ПРЕРЫВАНИЙ
;
;EIFR и PCIFR регистр флагов внешних прерываний
;PCIFR Для индикации прерываний по изменению состояния выводов	
;EIFR для индикации обычных внешних прерываний
;EIMSK для разрешения/запрещения "обычных внешних прерываний"
;PCICR для разрешения/запрещения по изменению состояния выводов
;
;EIMSK
;Для разрешения внешнего прерывания Int0/Int1 в биты Int0/Int1
;записывается 1. Условие генерации определяется содержимым битов
;ISC1 и ISC0 регистра EICRA
;EICRA
;ISCn1		ISCn0		Условие
;	 0			0		По низкому уровню
;	 0			1		Зарезервировано 
;	 1			0		По спадающему фронту на выходе INTn
;	 1			1		По нарастающему фронту 
;
;Флаг INTF0 устанавливается в 1 в результате события 
;на выводе INT0 
;Флаг INTF0 cброшен постоянно если генерация должна происходить
;по НИЗКОМУ уровню сигнала
;
;PCIF0 Флаг прерывания по изменению состояния выводов 0-группы
;если в результате события на любом из выводов PCINT0..7 сформировался
;запрос на прерывание то этот бит устанавливается в 1.
;====================================================================
;Call-used registers (r18-r27, r30-r31). Регистры, используемые при вызовах функций.
; Могут быть заняты компилятором gcc для локальных данных (переменных). 
;Вы свободно можете их использовать в подпрограммах на ассемблере, без необходимости 
;сохранения и восстановления (не нужно их сохранять в стек командой push и извлекать 
;из стека командой pop).
;=======================================================================
;Программатор
;Белый Vin
;Серый Gnd
;Синий Rst
;Зеленый D11
;Фиолетовый D12
;Черный D13
;
;0x00 окончание строки
		  S0: .db 0x03,0x0E,0x3C,0x64,0x34,0x1E,0x07,0x00			;а
		  S1:								;б
.org S1+4 S2: .db 1,2,3,4,5,6,7,8			;в
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
.org S15+4 S16:								;р
.org S16+4 S17:								;с
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
;128x32