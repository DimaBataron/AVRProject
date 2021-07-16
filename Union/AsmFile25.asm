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
.org 0x0030 reti; jmp TWI ; 2-wire Serial Interface Handler
.org 0x0032 reti; jmp SPM_RDY ; Store Program Memory Ready Handler
.ORG   INT_VECTORS_SIZE      	; Конец таблицы прерывани
;Символьные имена и переменные с данными
.include "E:/A/AssemblerApplication1/AssemblerApplication1/DefFile4.inc"

.cseg
; Непосредственно таблица содержащая адреса процедур
TaskProcs: .dw WordTr            ; [00] 
           .dw TwoWordTr         ; [01] 
;При старте программы сохраняю адрес начала массива байт в СurrentByte
;
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
ldi FisByte,0b00111111
out DDRC,FisByte ;Навравление передачи данных в 1(Выход)
ldi FisByte,0b00000000
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
;
;
;
;
ldi CE,0
cli
;Тут старт программы
call Encoder
sei
Main:	nop
		nop
		nop
		rjmp Main
;===========================================================
;;Процедуры
;------------------>>StartInit <<----------------------------
;Для запуска этой подпрограммы используються такие переменные
;NumWhileInit				;LenMasInit					;InitCount
;ZInitLow					;ZInitHi				    ;

;NumWhileInit				количество повторений цикла передачи конфиг битов
;LenMasInit					;длинна массива инициализации
;InitCount					;счетчик состояния инициализации
;ZInitLow					в этой области r30. Сохраняем сюда младший адрес массива инициализации при старте мк.
;ZInitHi					;в этой области r31. Cохраняю сюда старший адрес 
							;массива при инициализации.
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
;Cюда для передачи байта с адреса
		   inc r18
		   DOUT InitCount,r18
		   DIN r18,NumWhileInit
		   inc r18
		   DOUT NumWhileInit,r18
		   DIN ZL,ZInitLow              ;берем данные отсюда <<<----- Переписать на мой массив очереди
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
		   ;DIN r18,FlagCon
		   ;ANDI r18,0b11111101 ;b[1] - отключаю флаг стартовой инициализации
		   ;DOUT FlagCon,r18 ; Отключаю флаг инициализации т.к. все байты передали
		   ;Здесь добавить процедуру взятия следующей задачи.

		   ldi r18,0b10100101;Формирую состояние повстарт. А это к чему приведет?
		   DOUT TWCR,r18 
		   reti
;;----------------->>>PosYkP<<<-----------------------------------------
;Процедура позиционирования указателя страница(строка)
;Используемые байты в оперативе 
;NumWhilePos		EndTrCom			CountPosYk
;SelectPosYk		XPosYkLO			XPosYkHi

;NumWhilePos		количество переданных байт позиционирования
;CountPosYk	        счетчик состояния позиционирования.
;SelectPosYk		вложенный для определения байта.
;XPosYkLO			для хранения указателя передаваемого байта команды из ОЗУ
;XPosYkHi			тоже только старшего
;SetPagSt:			стартовый адрес страницы 0-7(строки)
;SetPagEnd:			конечный адрес страницы 0-7(строки)

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
			DIN r18,FlagCon       ;<<<<<----------------Здесь навреное изменить
			ANDI r18,0b11111011
			DOUT FlagCon,r18
			LDI r18,0b10100101
			DOUT TWCR,r18 ;Формирую состояние повстарт
			reti
;------------------>>>PosYkCol<<<-----------------------------------------
;Процедура позиционирования указателя страница(строка)
;Используемые байты в оперативе 
;NumWhilePos		CountPosYk			SetColSt			SetColEnd
;SelectPosYk		XPosComLo			XPosComHi
;1.Использование: Загрузить в ОЗУ по адресам  SetColSt SetColEnd
;Стартовый и конечный адрес страницы(только для горизонтальной и вертикальной адресации)
;2.Занести в пару значений XPosComHi:XPosComLo адрес ОЗУ SetColSt
;3.Установить флаг FlagCon[3]
;4.После установки всех флагов сформировать состояние старт
;NumWhilePos		количество переданных байт позиционирования

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
				DIN r18,FlagCon          ;<<<<<<------------------Cюда
				ANDI r18,0b11110111  
				DOUT FlagCon,r18
				LDI r18,0b10100101
				DOUT TWCR,r18 ;Формирую состояние повстарт
				reti
;------------------>> Clean <<-----------------------------
;r18 r19 r20
;CleanNow:              очищаемый в данный момент символ
;CleanSym:              количество символов которые надо очистить
;CleanWhile:  			очищаемый байт в текущий момент
;CleanByte:				байт которым заполняем все пространство.
;CleanFlag:				флаг указывающий о том что уже входили в процедуру и что передавать байт x40 не надо. Не забыть сбросить при выходе!!!
;Загружаем в CleanSym количество  (бит 8x8) символов 
;В CleanByte ложим то чем заполняем
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
			DIN r20, FlagCon    ;<<<-----Здесь что-то не так
			ORI r20,0b00000001 ;b[0] - флаг передачи устанавливается только в TWI После операции
			;Устанавливаю этот флаг чтобы перейти снова сюда
			DOUT FlagCon,r20
			ret
;Сюда Переходим для оконания передачи.
EndClean:   ldi r18,0
			DOUT CleanNow,r18
			DOUT CleanFlag,r18
			DIN r18,FlagCon
			ANDI r18,0b11101111 ;Отключаю флаг очистки  ;Здесь не флаг а вызов следующей.
			DOUT FlagCon,r18
			ldi r18,0b10100101
			DOUT TWCR,r18       ;И что делать с состоянием повстарт
			;Формирую состояние повстарт
			reti
;---------------->>>>>TrData<<<<---------------------------
;TrDataCountB		флаг того что нужно передать управляющий байт (При инициализации передачи массива символов)
;TrDataCount		количество байт одного символа которые уже передали
;TrDatLow:			r30. Сохраняем сюда младший адрес массива символов которые выводятся
;TrDatHi:			в этой области r31. Cтарший байт адреса массива символов
;TrSymByteL:		указатель на массив передаваемого байта одного символа
;TrSymByteH:		указатель на массив 
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
			ret
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
		push Tmp2
		in Tmp2,SREG ; Сохраняем значение флагов
		push Tmp2;
		ldi ZL,low(TaskQueue+6)
		ldi ZH,high(TaskQueue+6) 
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
		ldi SecByte,2   ;95 <<<------Заменил для отладки
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
Encoder:		in FisByte, PIND
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
				out PORTC,CountEncoder
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
;ПОСЛЕ НАЖАТИЯ НЕ ВЫХОДИТЬ В НАЧАЛО. А передать настройки, и ждать/
;Выход в предыдущее меню по длительному нажатию
				out PORTC,CountEncoder
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
		  
		  ldi SecByte,1;14 изменил на время отладки Т.К. долго думает ;Переменная для сравнения длительности задержки
		  sei   ;<<<<<-------Внимание дальше может везде возникнуть перывание
		  call Wait
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
		call Encoder
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
;=============================================================
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


