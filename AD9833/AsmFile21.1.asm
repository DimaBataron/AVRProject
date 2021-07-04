/*
 * AsmFile21.asm
 *
 *  Created: 30.06.2021 9:31:59
 *   Author: dima
 *	Программа передачи байт на AD9833. Который непосредтвнно генерирует частоту
	в зависимости от того какие байты были переданы.
	Программа включает в себя:
	-процедуры формирования очереди выполнения.
	-очереди передачи байт по SPI.
	-процедуры поворота и нажатия на энкодер.
	Используются протокол передачи SPI а также аппаратные прерывания
	по спадающему фронту сигнала.
 */ 
 
.include "F:/AVR/7.0/packs/atmel/ATmega_DFP/1.6.364/avrasm/inc/m328Pdef.inc"
.include "E:/A/AssemblerApplication1/AssemblerApplication1/Macro.inc"
.def OSRG = r20		;назначить регистру символическое имя
.def Tmp2 = r21			; Этот регист сохранять в стеке(трогать нельзя) <<<---------
.def FisByte = r22		;байты передаваемые в массив данных
.def SecByte = r23 	    ;2
.def ThirByte= r24	;3
.def FourtByte=r25	;4
.def CountEncoder = r19  ;Этот регистр также трогать нельзя <<<<<--------------------
.def CE           = r18	 ;Иногда использую для нажатий
.def Quant=	   r17	; сколько слов кладем в память
.def FsMM		  = r26  ; эти 4 регистра трогать нельзя  <<<<-----------------------
.def FsML		  = r27  ; В стеке сохранять только в блоке где запрещены 
.def FsLM         = r28	 ; прерывания
.def FsLL         = r29
;Это номера соответствуют порядку задач в массиве процедур. 
.equ TS_WordTr       = 0	;Просто нумерация. Не более того
.equ TS_TwoWordTr    = 1    ;Зато теперь можно смело отправлять в очередь 

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
.org 0x0020 reti ; Timer0 Overflow Handler
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
;
.DSEG
TaskQueue:
		.org TaskQueue+200 ; Выделяем в ОЗУ место для очереди размеров в 200 байт.
MasByte: ;(Начало массива)
		.org MasByte+600     ; Выделяем 600 байт для данных в ОЗУ под массив
CurrentByteL:  .db  1   ;Адрес текущего байта данных для записи
CurrentByteH:  .db  1  
;Дальше пишем наши данные в ОЗУ  
ReadDatL:    .db 1 ;адрес текущего передаваемого байта(чтения) данных из массива передачи
ReadDatH:	 .db 1 ;
;
;Данные выбраного режима
DcomH:		.db 1
.CSEG
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
call Encoder
sei
Main:	nop
		nop
		nop
		rjmp Main
;===========================================================
;;Процедуры
;------------------>>WordTr<<-----------------------------------------
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



;--------------------->>>ShiftQue<<<--------------------------------
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


;------------------->>>QueData<<---------------------------
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
;----------------->>>>>OpMode<<<<------------------------------------------
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
;
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
;==================================================================================================
;Прерывания
;----------------------->>>InterSPI<<<----------------------------------------
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
; ------------------>>> Encoder <<<--------------------------------------------------
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
EnC10:			ldi CE,0x04
				jmp EnC11
EnC9:			cpi CE,0x04
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
	ldi FisByte,0b11110001
	ldi SecByte,0b00101001
	ldi ThirByte,0x00
	ldi FourtByte,0x00
	add FsLL,FisByte
	adc FsLM,SecByte
	adc FsML,ThirByte
	adc FsMM,FourtByte 
	jmp EnC15

EnC20: 		mov CE,CountEncoder
			andi CE,0b00000100
			cpi CE,4
			BREQ EnC16 ;переходим для увеличения на 50Кгц
;Увеличиваем на 500кГц
		ldi FisByte,0b10110100
		ldi SecByte,0b11101010
		ldi ThirByte,0b01010001 
		ldi FourtByte,0x00
		add FsLL,FisByte
		adc FsLM,SecByte
		adc FsML,ThirByte
		adc FsMM,FourtByte
		rjmp EnC15
;для увеличения на 50Кгц
EnC16:	ldi FisByte,0xF2
		ldi SecByte,0x8F
		clr ThirByte        
		clr FourtByte
		add FsLL,FisByte
		adc FsLM,SecByte
		adc FsML,ThirByte
		adc FsMM,FourtByte
;Проверяем не вышло ли полученное число за пределы
EnC15:	mov CE,FsMM
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
		mov CE,CountEncoder
		andi CE,0b00000010
		cpi CE,2
		BRNE EnC21
;Переходим сюда если уменьшаем на 1 кГц
	ldi FisByte,0b11110001
	ldi SecByte,0b00101001
	ldi ThirByte,0x00
	ldi FourtByte,0x00
	sub FsLL,FisByte
	sbc FsLM,SecByte
	sbc FsML,ThirByte
	sbc FsMM,FourtByte 
	jmp EnC15
;Проверка на 50кгц
EnC21: 		mov CE,CountEncoder
			andi CE,0b00000100
			cpi CE,4
			BREQ EnC22 ;переходим для уменьшения на 50Кгц
;Уменьшаем на 500кГц
		ldi FisByte,0b10000101
		ldi SecByte,0b11101011
		ldi ThirByte,0b01010001
		ldi FourtByte,0x00
		sub FsLL,FisByte
		sbc FsLM,SecByte
		sbc FsML,ThirByte
		sbc FsMM,FourtByte
		jmp EnC15
;Уменьшаем на 50кГц
EnC22:	ldi FisByte,0xF2          
		ldi SecByte,0x8F
		clr ThirByte
		clr FourtByte
		sub FsLL,FisByte
		sbc FsLM,SecByte
		sbc FsML,ThirByte
		sbc FsMM,FourtByte
		jmp EnC15
;Cюда зашли если было третье нажатие
EnC13:  ldi CE,0
		ldi CountEncoder,0
;------->>Здесь вывести все что надо <<----------------
		out PORTC,CountEncoder
		reti ;Прерывания надо восстановить
;=========================================================================
;Обработчик нажатия кнопки
PresEn:   mov CE,CountEncoder
		  andi CE,0b01100000
		  swap CE ; меняю старшие и младшие байты местами
		  lsr CE  ; сдвигаю вправо получаю число раное нажатиям
		  inc CE  ; увеличиваю по нажатию
		  cpi CE,2
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
		andi CountEncoder,0b10011111
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
