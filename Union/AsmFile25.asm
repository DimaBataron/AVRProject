/*
 * AsmFile25.asm
 * �������� ����. 
 * ��������� ������ �� ���������� �����.
 * ������ �������� ���� �� ���������� SSD1306
 * ������ �������� ���� �� ���������� AD9833
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
.ORG   INT_VECTORS_SIZE      	; ����� ������� ���������
;���������� ����� � ���������� � �������
.include "E:/A/AssemblerApplication1/AssemblerApplication1/DefFile4.inc"

.cseg
; ��������������� ������� ���������� ������ ��������
TaskProcs: .dw WordTr            ; [00] 
           .dw TwoWordTr         ; [01] 
		   .dw StartInit		 ; [02] ��������� �������������
		   .dw TrData			 ; [03] �������� �������� �� �����
		   .dw Clean			 ; [04] �������
		   .dw PosYkP			 ; [05] ���������������� ������
		   .dw PosYkCol			 ; [06] ���������������� �������
		   .dw TrPointSym		 ; [07] ����� ������ �������(��������� ��������)
		   .dw StopSig			 ; [08] �������� ������� ����
		   .dw StartSig          ; [09] �������� ������� �����
;��� ������ ��������� �������� ����� ������ ������� ���� � �urrentByte
;�������������������
InitSSD : .db 0xA8,0x00,0xD3,00,0x40,0xA1,0xC0,0xDA,0x12,0x81,0xFF,0xA4,0xA6,0xD5 ;14
		  .db 0x80,0x8D,0x14,0x20,0x00,0xAF ;6
		;.db 0x00,0xAE,0x00,0x20,0x00,0x10,0x00,0xB0,0x00,0xC8,0x00,0x00,0x00,0x10,0x00
		;.db 0x40,0x00,0x81,0x00,0xFF,0x00,0xA0,0x00,0xA6,0x00,0xA4,0x00,0xD3,0x00,0x00
		;.db 0x00,0xD5,0x00,0xF0,0x00,0xD9,0x00,0x22,0x00,0xDA,0x00,0x12,0x00,0xDB,0x00
		;.db 0x20,0x00,0x8D,0x00,0x14,0x00,0xAF ;������ ��������� ���� �� �����
AdrSSD0:
;A0->A1; 22-12; 
;A8,3f->A8,00  ->���.������������������� (������ �� ������?)
;D3,00->D3,37   ����� ������ �� 0 �� 63
;0x40      ��������� ������
;0x81,0xFF �������� ������������
;0xA4 ����������� ����������� � ������ ���������� RAM
;0xD5,0x80 ��������� �������� � ������� �����������
;0x8D,0x14 ����������� ����������� ���������������
;0x20,0x00 ����� �������������� ���������
;0xAF  ��������� �������
;�����
MainM:		.db "������������",0
MainM1:		.db "������������",0
;
;============================================================
 Reset:	cli
		LDI R16,Low(RAMEND)	; ������������� �����
		OUT SPL,R16		; �����������!!!
		LDI R16,High(RAMEND)
		OUT SPH,R16
;============================================================
ldi ZL, low(TaskQueue) ;����� ����������������� ��� ���������� 0xFF
ldi ZH, high(TaskQueue)
ldi r16,0
ldi r17,0xFF
TaskQ0xFF:	inc r16
			st Z+,r17
			cpi r16,-56
			brne TaskQ0xFF
;===============================================================
;������� ���
AM_Flush:	LDI	ZL,Low(MasByte)	; ����� ������ ��� � ������
			LDI	ZH,High(MasByte)
			CLR	R16			; ������� R16
Flush:		ST 	Z+,R16			; ��������� 0 � ������ ������
			CPI	ZH,High(RAMEND+1)	; �������� ����� ����������?
			BRNE	Flush			; ���? �������� ������!
			CPI	ZL,Low(RAMEND+1)	; � ������� ���� ������ �����?
			BRNE	Flush
 
			CLR	ZL			; ������� ������
			CLR	ZH
;==============================================================
;������� ���������
		LDI	ZL, 30		; ����� ������ �������� ��������	
		CLR	ZH		; � ��� � ��� ����� ����
		DEC	ZL		; �������� �����
		ST	Z, ZH		; ���������� � ������� 0
		BRNE	PC-2		; ���� �� ��������� ��� �� �����������
;==============================================================
ldi ZL, low(MasByte) ; ������ � Z ����� ������� ���� Z(r31:r30)
DOUT CurrentByteL, ZL
DOUT ReadDatL,ZL 
;
ldi ZH, high(MasByte) 
DOUT CurrentByteH,ZH
DOUT ReadDatH,ZH
;
ldi Tmp2,0
;=============================================================
;������������ INT0 �� ���������� ������ ����� D2=PD2=INT0 ������������ �������
;� INT1 = PD3
		ldi r18,0b00001010	;�� ���������� ������ �� ������ INT0 � INT1
		DOUT EICRA,r18		
		ldi r18,0b00000011  ;��������� ������� ���������� INT0 � INT1
		DOUT EIMSK,r18
		;���������� ��� ������ �� ����������� ���� ���������������
;=========================================================
;����� ����� ������� � ������������ � ��� �����������
;��� ���������� ����������
; ��������� P� 0-5 = A0-A5
ldi FisByte,0b00110001  ;<<<<----����� �� ��������
out DDRC,FisByte ;����������� �������� ������ � 1(�����)
ldi FisByte,0b00110000  ; ������� � ������ ������������� ������ I2C
out PORTC,FisByte
;out PORTB,FisByte ; �������� ���� � 0.
;===========================================================
;Int0=PD2=S1=D2 
;Int1=PD3=S2=D3
;PD4     =Key=D4
ldi FisByte,0b00000000
out DDRD,FisByte ;����������� �������� ������ � 1(�����)
ldi FisByte,0b00000000
out PORTD,FisByte
;===========================================================
;����� ����� ������� � ������������ � ��� �����������
ldi FisByte,(1<<PB1)|(1<<PB3)|(1<<PB5)|(1<<PB2)
out DDRB,FisByte ;����������� �������� ������ � 1(�����)
out PORTB,FisByte ; ��������� ���� � 1.
;
ldi FisByte,0
out SPSR,FisByte
ldi FisByte,(1<<SPIE)|(1<<SPE)|(1<<MSTR)|(1<<CPOL)|(1<<SPR0)
out SPCR,FisByte ; ������������� ������ SPI �� ��������
;DSPI 16,0,0b11111001   
;� SPI �������� ������168 
;SCK	PB5 --> D13
;MISO	PB4 --> D12
;MOSI	PB3 --> D11
;SS		PB2 --> D10 (8bit)
;SS     PB1 --> D9	(16bit) ��������� �������
;������������� SS, M�SI � SCK ��� ��������.
;
;SPIE	1 ��������� ���������� �� ������ 
;SPE	1 ��������� ������ ������
;MSTR	1 �������� � ������ Master
;DORD	1 ������ ���������� ������� ���
;CPOL   1 �������� �������� �������������
;CPHA	0 �� ��������� ������
;SPR1:SPR0   01  clk/16 ����� ��������� ������� �� 16
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
;���������� �������� � �������
;��������� � �������� ��������� ��������
	ldi CE,0
	ldi CountEncoder,0
	sei		;���������� �� TWI �� ������� ��� ��������

	call StartInitQue ;��������� ���������� ������ ��������� ������������� TWI � �������

	ldi FisByte,0
	ldi SecByte,7
	call QuePosYkP ;��������� ������

	ldi FisByte,0
	ldi SecByte,15
	call QuePosYkCol ;��������� �������

	ldi FisByte,128 ;<<<<---------- ;�������� ���������� ��������� �������� ��������
	call QueClean
	call StartTrData   ;��������� ���������� ������ ����� ��������� ������ �� ����� �� TWI 

;������ ��������� ���� � ������ ������
	
	ldi FisByte,3 ;���������������� ������. ������
	ldi SecByte,5 ;�����
	call QuePosYkP ;������������ ������

	ldi FisByte,1
	ldi SecByte,15
	call QuePosYkCol ;������������ �������

	ldi FisByte, low(MainM*2)
	ldi SecByte, high(MainM*2)
	call QueTrData  ;������ ������

	ldi FisByte,5 ;���������������� ������. ������
	ldi SecByte,6 ;�����
	call QuePosYkP ;������������ ������

	ldi FisByte,1
	ldi SecByte,15
	call QuePosYkCol ;������������ �������

	ldi FisByte, low(MainM1*2)
	ldi SecByte, high(MainM1*2)
	call QueTrData  ;������ ������ 2

	call QueStopSig ; ������ � ������� ��������� ������� ���� ������

	call InitPoInfPro ;������������� ��������� �������� ����� ������� ���������
sei

	call InterSPI
;��� ����� ���������
ldi CE,0
;call Encoder
;sei		�������� ����������
Main:	nop
		nop
		nop
		rjmp Main
;===========================================================
;;���������
;------------------>>QueStartSig<<------------------------
;���������� � ������� �������� ������� �����.
QueStartSig:	cli
				ldi OSRG, TS_StartSig ;�������� ������ � �������
				call QueProcedur
				call PrSt
				ret
;------------------>>StartSig<<----------------------------
StartSig:	ldi r18,0b10100101 ;��������� ��������� ����� �� ���� TWI
			DOUT TWCR,r18
			reti
;------------------>>QueStopSig<<--------------------------
;��������� ���������� � ������� ��������� �������� ������� ���� ������ TWI
QueStopSig: cli
			ldi OSRG, TS_StopSig ;�������� ������ � �������
			call QueProcedur
			call PrSt
			ret
;-------------------->>StopSig<<-------------------------- 
;��������� �������� ������� ���� ������ TWI
;�������� ��������� ����
StopSig:	ldi r18,0b10010101
			DOUT TWCR,r18
			;����� �������� ���� ������� �������
			call ShiftQue
			ret
;------------------>>MenSMode<<------------------------------
;��������� ���������� ������ ������ �� ����� ���� ������
;������ ������.
;��������� ���� �������� ��������������� ������� ������.

MainMod1:	.db "�����",0
MainMod2:	.db "�����������",0
MainMod3:	.db "������",0
MainMod4:	.db "������2",0
;;�������
MenSMode:   ldi FisByte, 0
			ldi SecByte,7
			call QuePosYkP
			
			ldi FisByte,0
			ldi SecByte,15
			call QuePosYkCol
			
			ldi FisByte,128
			call QueClean 
;�����
			ldi FisByte, 2
			ldi SecByte,3
			call QuePosYkP

			ldi FisByte,1
			ldi SecByte,15
			call QuePosYkCol

			ldi FisByte, low(MainMod1*2)
			ldi SecByte, high(MainMod1*2)
			call QueTrData
;����������� 
		    ldi FisByte, 3
			ldi SecByte,4
			call QuePosYkP

			ldi FisByte,1
			ldi SecByte,15
			call QuePosYkCol

			ldi FisByte, low(MainMod2*2)
			ldi SecByte, high(MainMod2*2)
			call QueTrData
;������
			ldi FisByte, 4
			ldi SecByte,5
			call QuePosYkP

			ldi FisByte,1
			ldi SecByte,15
			call QuePosYkCol

			ldi FisByte, low(MainMod3*2)
			ldi SecByte, high(MainMod3*2)
			call QueTrData
;������2
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
;��������� ���������� ������ ��������� ������������� � �������
StartInitQue:	LDI r18,((AdrSSD0-InitSSD)*2) 
				DOUT LenMasInit,r18 ;���������� ������ ������� �������������
				ldi r18,0
				DOUT InitCount,r18 ;������� ��������� ����������������
				DOUT NumWhileInit,r18 ;���������� ���������� ����� �������� ������ �����
				LDI ZL,low(InitSSD*2) ; ������� ������� ���� ������, � ����������� ���� Z
				LDI  ZH,high(InitSSD*2)	; ������� ������� ���� ������, � ����������� ���� Z
				DOUT ZInitLow,ZL ; ��������� ��������� ����� ������� �������������.
				DOUT ZInitHi,ZH
;
	;��� ������������ ������ ��� ������ ��������
				LDI r18,0b01111000
				DOUT AdrSSD,r18		;���������� ����� ��������
				TWFscl 70,0 ;������ 102.6��� ������� ������ TWI Fscl ;SSD1306 �������� 400���
;
				ldi OSRG,TS_StartSig
				call QueProcedur
				ldi OSRG, TS_StartInit ; �������� ������ � �������
				call QueProcedur
				call PrSt
				ret
;------------------>>StartInit <<----------------------------
;��� ������� ���� ������������ ������������� ����� ����������\
;��������� ������������� ���������(�������� �������� �� �������)
;NumWhileInit				;LenMasInit					;InitCount
;ZInitLow					;ZInitHi				    ;
;NumWhileInit	+			���������� ���������� ����� �������� ������ �����
;LenMasInit		+			������ ������� �������������
;InitCount		+			������� ��������� �������������
;ZInitLow		+			� ���� ������� r30. ��������� ���� ������� ����� ������� ������������� ��� ������ ��.
;ZInitHi		+			� ���� ������� r31. C������� ���� ������� ����� 
;�������� r18,r22 
StartInit: DIN r18,NumWhileInit
		   DIN r22,LenMasInit
		   cp r18,r22
		   brge InitEnd   ;���� �������� ��� ����� �������������
		   DIN r18,InitCount
		   cpi r18,0
		   BRNE InCoun1   ;������� ���� �������� ���� �������
;C��� ��������� ��� �������� ������������ �����
		   inc r18
		   DOUT InitCount,r18
		   ldi r18,0
		   DOUT TWDR,r18
		   ldi r18,0b10000101 ; ���������� ��������
		   DOUT TWCR,r18
		   reti
;C��� ��� �������� ����� �������
InCoun1:   cpi r18,1
		   brne PstInit ;������� ���� ������������ ��������
;C��� ��� �������� ����� � ������
		   inc r18
		   DOUT InitCount,r18
		   DIN r18,NumWhileInit
		   inc r18
		   DOUT NumWhileInit,r18
		   DIN ZL,ZInitLow              ;����� ������ ������
		   DIN ZH,ZInitHi
		   LPM R18, Z+	;����� ���� �� ������ ����������� ����
		   DOUT ZInitLow,ZL
		   DOUT ZInitHi,ZH
		   DOUT TWDR,r18
		   ldi r18,0b10000101 ; ���������� ��������
		   DOUT TWCR,r18
		   reti
;C��� ���� ���� ������������ ��������� ��������
PstInit:   ldi r18,0
		   DOUT InitCount,r18
		   ldi r18,0b10100101 ;�������� ��������� ��������
		   DOUT TWCR,r18
		   reti
;C��� ���� �������� ��� ����� ��������������.
InitEnd:   call ShiftQue
		   ldi r18,0
		   DOUT NumWhileInit,r18
		   DOUT InitCount,r18
		   ;DIN r18,FlagCon
		   ;ANDI r18,0b11111101 ;b[1] - �������� ���� ��������� �������������
		   ;DOUT FlagCon,r18 ; �������� ���� ������������� �.�. ��� ����� ��������
		   ;����� �������� ��������� ������ ��������� ������.

		   ldi r18,0b10100101;�������� ��������� ��������. � ��� � ���� ��������?
		   DOUT TWCR,r18 
		   reti
;---------------->>>>>TrData<<<<---------------------------
;TrDataCountB		���� ���� ��� ����� �������� ����������� ���� (��� ������������� �������� ������� ��������)
;TrDataCount		���������� ���� ������ ������� ������� ��� ��������
;TrDatF				; ��� ������ ����� ���� ������ ������� ��� ������ �� ������ ���������.
;3 ������ ������� ��� ��������� ������������� ���������

;TrDatLow:			r30. ��������� ���� ������� ����� ������� �������� ������� ���������
;TrDatHi:			� ���� ������� r31. C������ ���� ������ ������� ��������
;TrSymByteL:		��������� �� ������ ������������� ����� ������ ������� �� ������� TrDat (��������)
;TrSymByteH:		��������� ��


;��������� ����������� �� ���� ������ ���� ��� ������. 0 ������� ��������� �������.
TrData: DIN FisByte,TrDatF
		CPI FisByte,0
		BRNE TD5 ;������� ���� �� 0
;C��� ���� ������� ��������� ��� ���������
		DIN ZL, ReadDatL ;����� �� ������� ������ ������� ����� ������
		DIN ZH, ReadDatH
		ld OSRG,Z+
		DOUT TrDatLow,OSRG;������� ����� ������� ����� ������� ��������� �������� TrDatLow=OSRG 
		ld OSRG,Z+
		DOUT TrDatHi,OSRG
		DOUT ReadDatH,ZH
		DOUT ReadDatL,ZL
		inc FisByte
		DOUT TrDatF,FisByte ;TrDatF=1
; C��� ��� ����������� ��������
TD5:	DIN r18, TrDataCountB
		cpi r18,0 
		BRNE TrComp ;   ���� �� ����� �������(��� ���������� ����������� ����)
;c��� ��������� ��� �������� ������������ �����
		ldi r18,1
		DOUT TrDataCountB,r18
		ldi r18,0x40 ;������������� ����������� ����, ��������������� � �������� ������� ����
		DOUT TWDR,r18
		ldi r18,0b10000101 ; ���������� ��������
		DOUT TWCR,r18
		reti
;����������� ���� ��������
TrComp: DIN r18,TrDataCount
		cpi r18,0 
		BRNE TrMasComp ; �������� �� ����� �� �������� ������� ����
;���� ��� ��������� ���� ������
		DIN ZL,TrDatLow
		DIN ZH, TrDatHi ;���� ���� �� ������� 
		LPM r18,Z+
		cpi r18,0
		BRNE TrDataCalc ; ��������� ��� ���������� ������� ���� �������
;�������� ����� �������� ��������� ��������
		ldi r18,0
		DOUT TrDataCountB,r18
		DOUT TrDataCount,r18
		DOUT TrDatF,r18
		call ShiftQue ; ������� ������� �.�. ����� ��������� ������� ��������
		ldi r18,0b10100101
		DOUT TWCR,r18
		reti
;
TrDataCalc: DOUT TrDatLow,ZL
			DOUT TrDatHi,ZH
			;�������� ����� ������ �������
			SUBI r18,0xE0 ; ���������� �� ���� ������� �������� ������������� �������� ������������ ������ ������� ����
			lsl r18
			lsl r18
			lsl r18 ;����� ����� �� 3 ������� ����������� ��������� �� 8
			LDI ZL,low(S0*2)  ;����� �������� ������� ���� ������� ������������� ����� �
			LDI ZH,high(S0*2)
			add ZL,r18       ;��������� � ������������ ��� ��������
			ldi r18,0
			adc ZH,r18  ;��������� � ����� �������� ���� ����
			;������ Z �������� ����� ����� ��� ������.
			DOUT TrSymByteL, ZL
			DOUT TrSymByteH,ZH
			RJMP TrMasBat
;��������� �� ����� �� ������� ��������
TrMasComp:	cpi r18,8
			BRGE EndTrData		;���� ����� ������� ���� ������������ ������
;c��� ��������� ��� �������� ������� ���� ��������
TrMasBat:	DIN r18,TrDataCount
			inc r18
			DOUT TrDataCount,r18
			DIN ZL,TrSymByteL
			DIN ZH, TrSymByteH
			LPM R18, Z+ ;���� ���� �� ������������ ������ 
			DOUT TrSymByteL,ZL
			DOUT TrSymByteH,ZH
			DOUT TWDR,r18
			ldi r18,0b10000101 ; ���������� ��������
			DOUT TWCR,r18
			reti
EndTrData:  ldi r18,0
			DOUT TrDataCount,r18
			call InterSPI
			ret
;
;------------------>>>QueTrData<<<--------------------------------------
;��������� ���������� �������� ������� ���� �� ����� � ������� ����������
;����� �������� ������ � FisByte ������� ����� ������ SecByte ������� �����
;������ ������� �������� ������� ���������.
QueTrData:  ldi OSRG, TS_TrData ; �������� ������ � �������
			call QueProcedur
			ldi Quant,1  ;��������� ��� ����� ���� �����
			call QueData
			call PrSt ;������ ����� � �������, ���� ������� ����� ������ ���������� ������
			ret
;----------------->>>PrSt<<<-----------------------------------------------
;�������� ������� ���������� ������ �� �������. ���� ���������� ���������, ������� �����
PrSt:	;�������� ��������� �� ��������
		push Tmp2
		in Tmp2,SREG ; ��������� �������� ������
		push Tmp2;
		;��� ��������� ���� ������ �� +0??
		ldi ZL,low(TaskQueue) 
		ldi ZH,high(TaskQueue) ;��������� ���� �� ��� ������ ����� ��� ��� ��������?
		ldi r18,1
		add ZL,r18
		clr r18
		adc ZH,r18
		ld Tmp2,Z ;����� ����� ������� ������
		cpi Tmp2,0xFF
		brne FrTr1 ; ������� ���� �� �����
;c��� ������� ���� ��� ������ ��� �����������. �������� ��������� ������� �������
		pop Tmp2 ; ���������� �����. ���� ��� ���������� ���� 
		out SREG,Tmp2 ; ���������, �� ��� �������� � ��� ��������.  �� ������� �.� ������ ��������� � ����� ���������������
		pop Tmp2;
		call InterSPI
		ret
;C��� ���� � ������� ��� ���� ������
FrTr1: pop Tmp2 ; ���������� �����. ���� ��� ���������� ���� 
	   out SREG,Tmp2 ; ���������, �� ��� �������� � ��� ��������.
	   pop Tmp2;
	   ret

;---------------------->>>>StartTrData<<<<------------- ��������� ���������� ������
StartTrData : ldi r18,0
			  DOUT TrDataCountB,r18	;���� ���� ��� ����� �������� ����������� ���� (��� ������������� �������� ������� ��������)
			  DOUT TrDataCount,r18	;���������� ���� ������ ������� ������� ��� ��������
			  DOUT TrDatF,r18	;��� ������ ����� ���� ������ ������� ��� ������ �� ������ ���������.
			  ret
;----------------->>>>QuePosYkP<<<<----------------------------------
;���������� � ������� ��������� ���������������� ���������.
QuePosYkP:	ldi OSRG, TS_PosYkP
			call QueProcedur
			ldi Quant,1
			call QueData
			call PrSt
			ret
;;----------------->>>PosYkP<<<-----------------------------------------
;��������� ���������������� ��������� ��������(������)
;������������ ����� � ��������� 
;NumWhilePos		EndTrCom			CountPosYk
;SelectPosYk		

;NumWhilePos		���������� ���������� ���� ����������������
;CountPosYk	        ������� ��������� ����������������.
;SelectPosYk		��������� ��� ����������� �����.
;SetPagSt:			��������� ����� �������� 0-7(������)
;SetPagEnd:			�������� ����� �������� 0-7(������)

;1.�������������: ��������� � ������ ������ 2����� SetPagSt SetPagEnd
;1� ���� ��������� ������ ������
;2� ���� �������� ������ ������
;� ������ ������ �������� ���������� � ������ ������ ��������, ������� ����� SetPagSt
; �����  SetPagEnd, ��������� � �������� ����� ��������(������ ��� �������������� � ������������ ���������)
;C��� ������� �� ���������� (�������� ����� �������� ������ TWI)
;������ �� ���������� ���� �� ����������
PosYkP:	   DIN r18,NumWhilePos
		   cpi r18,3
		   brge  EndTrCom  ;������� ���� �������� 3����� ���������������� ������
		   DIN Quant,CountPosYk
		   cpi Quant,0
		   BRNE CountContr ; ������� ���� �������� ��� ���� ������������
;���� ��������� ��� ������������ ��������� ��������
		   inc Quant
		   DOUT CountPosYk,Quant
		   ldi Quant, 0b10100101 ;�������� ��������� ��������
		   DOUT TWCR,Quant
		   reti
CountContr:	cpi Quant,1
		    BRNE CounComand ;<��������� ��� �������� ��������������� �������
;C��� ������� ��� �������� ������������ �����
		    inc Quant
		    DOUT CountPosYk,Quant
		    ldi Quant,0x00
			DOUT TWDR,Quant ; �������� ����������� ����
			ldi Quant,0b10000101
			DOUT TWCR,Quant ;���������� ��������
			reti
;C��� ��������� ��� �������� �������
CounComand: ldi Quant,0
			DOUT CountPosYk,Quant
			DIN Quant,SelectPosYk
			inc r18
			DOUT NumWhilePos,r18
			cpi Quant,0
			BRNE CouComCon ;������� ��� �������� ���������������� ���� �������
;����� ���������� ������ ���� �������
			ldi r18,0x22
			inc Quant
			DOUT SelectPosYk,Quant
			DOUT TWDR,r18
			ldi r18,0b10000101 ; ���������� ��������
			DOUT TWCR,r18
			reti
;C��� ��������� ��� �������� ���������� ���� �������
CouComCon: DIN ZL, ReadDatL ;����� �� ������� ������ ������� ����� ������
		   DIN ZH, ReadDatH
		   ld OSRG,Z+
		   DOUT TWDR, OSRG
		   DOUT ReadDatH,ZH
		   DOUT ReadDatL,ZL
		   ldi r18,0b10000101 ; ���������� ��������
		   DOUT TWCR,r18 ;�������� ��������� ��������
		   reti
;�������� ��� ������ ����� ������� ����� ������
EndTrCom:	ldi r18,0
			DOUT NumWhilePos,r18
			DOUT CountPosYk,r18
			DOUT SelectPosYk,r18
			call ShiftQue
			LDI r18,0b10100101
			DOUT TWCR,r18 ;�������� ��������� ��������
			reti

;----------------->>>QuePosYkCol<<--------------------------------------
;��������� ���������� � ������� ��������� ����������������� ������� ������
QuePosYkCol:		ldi OSRG, TS_PosYkCol ; �������� ������ � �������
					call QueProcedur
					ldi Quant,1  ;��������� ��� ����� ���� �����
					call QueData
					call PrSt
					ret
;------------------>>>PosYkCol<<<-----------------------------------------
;��������� ���������������� ��������� �������
;������������ ����� � ��������� 
;�������������: �������� � �������� FisByte � SecByte ����� ���������� � ��������� ������� 
;��������� ��������� PosYkCol ��� ���������� ������ � �������.
;��������� ����������.

;NumWhilePos		CountPosYk			SelectPosYk
;NumWhilePos		���������� ���������� ���� ����������������
;CountPosYk	        ������� ��������� ����������������.
;SelectPosYk		��������� ��� ����������� �����.

PosYkCol:  DIN r18,NumWhilePos
		   cpi r18,3
		   brge  EndTrCom12  ;������� ���� �������� 3����� ���������������� ������
		   DIN TmpAsH,CountPosYk ;������� ��������� ����������������.
		   cpi TmpAsH,0
		   BRNE CountContr1 ; ������� ���� �������� ��� ���� ������������
;���� ��������� ��� ������������ ��������� ��������
				inc TmpAsH
				DOUT CountPosYk,TmpAsH
				ldi TmpAsH, 0b10100101 ;�������� ��������� ��������
				DOUT TWCR,TmpAsH
				reti
CountContr1:	cpi TmpAsH,1
				BRNE CounComand1 ;<��������� ��� �������� ��������������� �������
;C��� ������� ��� �������� ������������ �����
				inc TmpAsH
				DOUT CountPosYk,TmpAsH
				ldi TmpAsH,0x00   
				DOUT TWDR,TmpAsH ; �������� ����������� ����
				ldi TmpAsH,0b10000101
				DOUT TWCR,TmpAsH ;���������� ��������
				reti
				Jmp CounComand1
EndTrCom12:		RJMP EndTrCom1
;C��� ��������� ��� �������� �������
CounComand1:	ldi TmpAsH,0
				DOUT CountPosYk,TmpAsH
				DIN TmpAsH,SelectPosYk ;��������� ��� ����������� �����.
				inc r18
				DOUT NumWhilePos,r18
				cpi TmpAsH,0
				BRNE CouComCon1 ;������� ��� �������� ���������������� ���� �������
;����� ���������� ������ ���� �������
			ldi r18,0x21 ;Set Column Address
			inc TmpAsH
			DOUT SelectPosYk,TmpAsH
			DOUT TWDR,r18
			ldi r18,0b10000101 ; ���������� ��������
			DOUT TWCR,r18
			reti
;C��� ��������� ��� �������� ���������� ���� �������
CouComCon1:		DIN ZL, ReadDatL ;����� �� ������� ������ ������� ����� ������
				DIN ZH, ReadDatH
				ld OSRG,Z+
				lsl OSRG
				lsl OSRG
				lsl OSRG ;����� ����� �� 3 ������� ����������� ��������� �� 8
				DOUT ReadDatH,ZH
				DOUT ReadDatL,ZL

				cpi OSRG,120 ; ��������� ������. �������� �� �����.
				Brne TrComDat1 ;�� ����� ������� �����
				ldi OSRG,127
TrComDat1:		DOUT TWDR,OSRG
				ldi r18,0b10000101
				DOUT TWCR,r18 ; ���������� ��������
				reti
;�������� ��� ������ ����� ������� ����� ������
EndTrCom1:		ldi r18,0
				DOUT NumWhilePos,r18
				DOUT CountPosYk,r18
				DOUT SelectPosYk,r18
				call ShiftQue
				LDI r18,0b10100101
				DOUT TWCR,r18 ;�������� ��������� ��������
				reti
;------------------>>>QueClean<<<------------------------
;��������� ���������� � ������� ������� �������.
;����� ������� � FisByte ��������� ���������� ��������� ��������.
QueClean:	cli
			ldi OSRG,0
			DOUT CleanByte,OSRG
			ldi OSRG,TS_Clean
			call QueProcedur
			ldi Quant,1 ;�������� ��� ���� ���� �����
			call QueData
			call PrSt
			ret
;------------------>> Clean <<-----------------------------
;r18 r20
;CleanNow:              ��������� � ������ ������ ������
;CleanSym:              ���������� �������� ������� ���� ��������
;CleanWhile:  			��������� ���� � ������� ������
;CleanByte:				���� ������� ��������� ��� ������������.
;CleanFlag:				���� ����������� � ��� ��� ��� ������� � ��������� � ��� ���������� ���� x40 �� ����. �� ������ �������� ��� ������!!!
;��������� � CleanSym ����������  (��� 8x8) �������� 
;� CleanByte ����� �� ��� ���������
Clean:  cli              ;��� ����� ������ ���� ��� �������?
		DIN FisByte,TrDatF
		CPI FisByte,0
		BRNE TD10 ;������� ���� �� 0
;C��� ���� ������� ��������� ��� ���������
		DIN ZL, ReadDatL ;����� �� ������� ������ ������� ����� ������
		DIN ZH, ReadDatH
		ld OSRG,Z+
		DOUT CleanSym,OSRG;������� ����� ������� ����� ������� ��������� �������� TrDatLow=OSRG 
		ld OSRG,Z+ ;��� ������ �������
		DOUT ReadDatH,ZH
		DOUT ReadDatL,ZL
		inc FisByte
		DOUT TrDatF,FisByte ;TrDatF=1
; C��� ��� ����������� ��������
TD10:		
	   DIN r18,	CleanNow
	   DIN Quant, CleanSym
	   cp r18,Quant
	   BRSH EndClean ; <<��������� ���� ��� ��������. ����������� ���������
;	   ��������� ���� ������ ������ 
	   DIN r20,CleanFlag
	   cpi r20,0
	   brne StartClean;<<--��������� ���� ����������� ������� ���������� �� �����
; ������� ��� �������� ����������� �������
		inc r20
		DOUT CleanFlag,r20
		ldi r20,0x40
		DOUT TWDR,r20 ;������� ����������� ��� ������ �������� �������� ���� ������
		ldi r20,0b10000101
		DOUT TWCR,r20 ; ���������� ��������
		reti
;C��� ��������� ��� ������ �������
StartClean: DIN r20, CleanWhile
			cpi r20,8
			BRGE CountINC ; <<--- ��������� ��� ���������� ��������� ���������� � ������ ������ �������
;����� ���� ������� ������ �������
			inc r20
			DOUT CleanWhile, r20
			DIN r20,CleanByte
			DOUT TWDR,r20
			ldi r20, 0b10000101
			DOUT TWCR,r20 ; ���������� ��������
			reti
;������ ������ ����������� �������
CountINC:	ldi r20,0
			DOUT CleanWhile,r20
			inc r18  ;���������� ������� ��������� ��������
			DOUT CleanNow,r18
			;������� ������� �������� ������� ��� ���� � ���������
			;128*8=256 ����, ������� ��������� ��� ������� ����� �������
			call InterSPI
			ret
;���� ��������� ��� �������� ��������.
EndClean:   ldi r18,0
			DOUT CleanNow,r18
			DOUT CleanFlag,r18
			DOUT TrDatF,r18
			ldi r18,0b10100101
			DOUT TWCR,r18 ;�������� ��������� ��������
			call ShiftQue
			reti

;--------------------->>>QueTrPointSym<<-----------------------------
;��������� ���������� � ������ ��������� �������� ������� �� �����.
QueTrPointSym:	ldi OSRG, TS_TrPointSym ; �������� ������ � �������
				call QueProcedur
				ldi Quant,1 ;��������� ��� ����� ���� �����
				call QueData
				call PrSt
				ret
;-------------------->>>TrPointSym<<<---------------------------------
;��������� ����������� �� ���� ������ ���� ��� ������. 0 ������� ��������� �������.
;����� ������ �������
TrPointSym: DIN FisByte,TrDatF
			CPI FisByte,0
			BRNE TD15 ;������� ���� �� 0
;C��� ���� ������� ��������� ��� ���������
			DIN ZL, ReadDatL ;����� �� ������� ������ ������� ����� ������
			DIN ZH, ReadDatH
			ld OSRG,Z+
			DOUT TrDatLow,OSRG;������� ����� ������� ����� ������� ��������� �������� TrDatLow=OSRG 
			ld OSRG,Z+
			DOUT TrDatHi,OSRG
			DOUT ReadDatH,ZH
			DOUT ReadDatL,ZL
			inc FisByte
			DOUT TrDatF,FisByte ;TrDatF=1
; C��� ��� ����������� ��������
TD15:	DIN r18, TrDataCountB
		cpi r18,0 
		BRNE TrComp1 ;   ���� �� ����� �������(��� ���������� ����������� ����)
;���� ��� �������� ������������ �����
		ldi r18,1
		DOUT TrDataCountB,r18
		ldi r18,0x40 ;������������� ����������� ����, ��������������� � �������� ������� ����
		DOUT TWDR,r18
		ldi r18,0b10000101 ; ���������� ��������
		DOUT TWCR,r18
		reti
TrComp1:	DIN Quant,TrDataCount
			cpi Quant,8
			BRGE EndTrData1		;���� ����� ������� ���� ������������ ������
;���� ��� �������� ���� ���������� ������� 
		DIN ZL, TrDatLow
		DIN ZH,TrDatHi
		LPM OSRG, Z+ ;���� ���� �� ������������ ������ 
		DOUT TWDR,OSRG
		inc Quant ;TrDataCount++
		DOUT TrDataCount,Quant
		DOUT TrDatLow,ZL
		DOUT TrDatHi,ZH
		ldi r18,0b10000101 ; ���������� ��������
		DOUT TWCR,r18
		;call InterSPI ;���������� ���� ����� ��������� ��������
		reti
EndTrData1: 	ldi r18,0
				DOUT TrDataCountB,r18
				DOUT TrDataCount,r18
				DOUT TrDatF,r18
				call ShiftQue
				ldi r18,0b10100101
				DOUT TWCR,r18 ; �������� ��������� ��������
				reti

;-------------------->>InitPoInfPro<<----------------------
;��������� ������ ��������� �������� � ������ ������ ������������ ��� ������ ���������
InitPoInfPro: ldi r18,0xFF
			  DOUT PosMemStr,r18
			  DOUT PosMemStrEnd,r18
			  DOUT PosMemCol,r18
			  DOUT PosMemColEnd,r18
			  ret
;----------------->>>PoInfPro<<<-----------------------------------------
;��������� ������ ��������� ��� ���������������� ��������� ���������� �������� �
;FsMM ��������� ������
;FsML ��������
;FsLM ��������� �������
;FsLL �������� �������
;��������� ���������� ��� ��� ��������� � ��������� ���. ������� ������ ��� ��� ��������� �� �����.
;��� ��������� ��������� � ������� ����������� �����������
;���������� ;PosMemStr
            ;PosMemStrEnd
            ;PosMemCol
            ;PosMemColEnd ������ ������� ���������
; ����� ������� �� ������ ������ 0xFF � ������ ��� ��������� ���������� ������� ��������� ����.
PoInfPro: DIN OSRG,PosMemStr
		  cpi OSRG,0xFF
		  brne PolInfY
;c��� ������� ���� ������� �������
PolInfN: mov FisByte, FsMM
		 mov SecByte, FsML
		 call QuePosYkP   ;�������� �� �������� �� ++++++
		 ;�������� ������� ���������  (��� ���������� ������)
		 DOUT PosMemStr, FisByte
		 DOUT PosMemStrEnd,SecByte
;�������� �������� ����� ������� ���������������� �������
		 mov FisByte, FsLM
		 mov SecByte, FsLL
		 DOUT PosMemCol, FisByte
		 DOUT PosMemColEnd,SecByte
		 call QuePosYkCol ;�������� �� �������� ++++
		 ldi FisByte, low(point*2)  ;����� ������ �������
		 ldi SecByte, high(point*2)
		 call QueTrPointSym	;�������� ++++
		 ret
;���� ������� ���� ����� �������� ������� ������� �����
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
;��������� �������� ����� �� SPI
WordTr: DIN r20, SREG
		push r20
		cpi Tmp2,2 ;�������� �� ��� 2 ����� = 1�����
		brge EndWordTr
;��������� ���� ��� �������� ���������� �����
		inc Tmp2 ;����������� �������� ���������� ����
		cli
		DIN ZL, ReadDatL ;����� �� ������� ������ ������� ����� ������
		DIN ZH, ReadDatH
		ld OSRG,Z+		 ;�������� ���� �� ������� ��������� ���������
		DOUT ReadDatH,ZH
		DOUT ReadDatL,ZL
		DPort_And B,0b11111111,0b11111101  ;����������� � 0 CS  PB1 --> D9 
;(16bit) ��������� �������
		OUT SPDR,r20 ;������� ��������
		pop OSRG
		DOUT SREG,OSRG ; �������������� ��������� �������. ���� ���������� ���� 
		sei
		ret				;��������� ��� ���������

;��������� ���� ���� �������� ��� �����
EndWordTr:	ldi Tmp2,0
			call ShiftQue ;������� ��������� ������ �������, �.�. ��� ��������� ���� ���������
			DPORT B, 0b00000000,0b00000010 ;����������� � 1 CS  PB1 --> D9
			call InterSPI
			pop OSRG
			DOUT SREG,OSRG ;�������������� ��������� �������
			reti
;--------------------->>>QueProcedur<<--------------------
;���������� ��������� � �������
QueProcedur :	push ZL ; ��������� ��� ��� ������������
				push ZH ; � �����
				push Tmp2
				in Tmp2,SREG ; ��������� �������� ������
				push Tmp2
				cli    ; ��������� ����������. 
				;
				ldi ZL, low(TaskQueue) ; ������ � Z ����� ������� �����.
				ldi ZH, high(TaskQueue) 
SEQL01:		ld Tmp2, Z+			; ������ � ���� ���� �� �������
			cpi Tmp2, 0xFF      ; � ���� ��������� ������ ����� = FF
			BRNE SEQL01          ; ���� �� ����� FF ����� ���������
; C��� ���� ����� ����� �������
			st -Z, OSRG ;��������� � ������� ����� ������. 
			pop Tmp2 ; ���������� �����. ���� ��� ���������� ���� 
			out SREG,Tmp2 ; ���������, �� ��� �������� � ��� ��������. 
			pop Tmp2
			pop ZH
			pop ZL
			reti
;------------------------->>>ShiftQue<<<--------------------------------
;��������� ������ ������� (������� � ���������)
ShiftQue:	cli 
			push Tmp2
			in Tmp2,SREG ; ��������� �������� ������
			push Tmp2
			ldi ZL, low(TaskQueue) ;������ � ������ ������
			ldi ZH, high(TaskQueue) 
SQL02:		ldd Tmp2, Z+1  ;����� � OSRG ���������
			st Z+, Tmp2 ; ����� ��� �� ������ ����� Z++
			cpi Tmp2,0xFF
			BRNE SQL02 ;��������� ���� �� ����� �������
;c��� ���� ����� �������
			pop Tmp2 ; ���������� �����. ���� ��� ���������� ���� 
			out SREG,Tmp2 ; ���������, �� ��� �������� � ��� ��������. 
			pop Tmp2;
			ret
;------------------------->>>QueData<<---------------------------
;����� ������ � ������ ���� ������ �� ����� ������ ���������
QueData:	cli    ; ��������� ����������.
			push ZL ; ��������� ��� ��� ������������
			push ZH ; � �����
			push Tmp2
			in Tmp2,SREG ; ��������� �������� ������
			push Tmp2;
			DIN ZL, CurrentByteL
			DIN ZH, CurrentByteH
			ST Z+,FisByte ;������ �������� �����
			ST Z+,SecByte ; ������ ��������
			cpi Quant,2 ;������� ������� ���� ����������
			BRLT EndQueData ; ���� ������ 2 ���������
;C��� ��� ������ ������� �����
			ST Z+,ThirByte ;�������
			ST Z+,FourtByte ;�������
;������ ���� ��� ������ 3�� �����
;			cpi Quant,3		 
;			BRLT EndQueData ;��������� ���� 2
;C��� ��� ������ �������� �����
;			ST Z+,FifByte ;�������
;			ST Z+,SixByte ;�������
EndQueData:		DOUT CurrentByteL,ZL
				DOUT CurrentByteH,ZH ;��������� ��� ����������� ������
				pop Tmp2 ; ���������� �����. ���� ��� ���������� ���� 
				out SREG,Tmp2 ; ���������, �� ��� �������� � ��� ��������. 
				pop Tmp2;
				pop ZH
				pop ZL
				ret

;------------------------>>>>TwoWordTr<<<<-----------------------------------
;�������� ���� ���� �� SPI
TwoWordTr:  DIN r20, SREG
			push r20
			cpi Tmp2,4 ;�������� �� ��� 4 ����� = 1�����
			brge EndTWordTr
;��������� ���� ��� �������� ���������� �����
		inc Tmp2 ;����������� �������� ���������� ����
		cli
		DIN ZL, ReadDatL ;����� �� ������� ������ ������� ����� ������
		DIN ZH, ReadDatH
		ld OSRG,Z+		 ;�������� ���� �� ������� ��������� ���������
		DOUT ReadDatH,ZH
		DOUT ReadDatL,ZL
		DPort_And B,0b11111111,0b11111101  ;����������� � 0 CS  PB1 --> D9 
;(16bit) ��������� �������
		OUT SPDR,r20 ;������� ��������
		pop OSRG
		DOUT SREG,OSRG ; �������������� ��������� �������. ���� ���������� ���� 
		sei
		ret				;��������� ��� ���������

;��������� ���� ���� �������� ��� �����
EndTWordTr:	ldi Tmp2,0
			call ShiftQue ;������� ��������� ������ �������, �.�. ��� ��������� ���� ���������
			DPORT B, 0b00000000,0b00000010 ;����������� � 1 CS  PB1 --> D9
			pop OSRG
			DOUT SREG,OSRG ;�������������� ��������� �������
			call InterSPI
			ret
;
;
;----------------------->>>>>PointCheck<<<<------------------------------------------
;��������� ������ ���������
PointCheck:		sbrs CountEncoder,1 ;������� ��������� ������� ���� ��� ����������
				rjmp PCh1
;C��� ������� ���� ������ �������������� ������
			ldi FsMM,2   ;��������� ������
			ldi FsML,3   ;��������
			ldi FsLM,0   ;��������� �������
			ldi FsLL, 15 ;�������� �������
			call PoInfPro ;��������� ������ ���������
			ret
PCh1:		sbrs CountEncoder,2 ;������� ��������� ������� ���� ��� ����������
			rjmp PCh2
;C��� ���� ������ ������������ ������
			ldi FsMM,3  ;��������� ������
			ldi FsML,4  ;��������
			ldi FsLM,0   ;��������� �������
			ldi FsLL, 15 ;�������� �������
			call PoInfPro
			ret
PCh2:		sbrs CountEncoder,3
			rjmp PCh3
;���� ���� ����� �������� ���� DAC
			ldi FsMM,4  ;��������� ������
			ldi FsML,5  ;��������
			ldi FsLM,0  ; ��������� �������
			ldi FsLL, 15; �������� �������
		    call PoInfPro
			ret
;C��� ���� ������� ��� DAC/2
PCh3:		ldi FsMM,5  ;��������� ������
			ldi FsML,6 ;��������
			ldi FsLM,0 ;��������� �������
			ldi FsLL, 15 ;�������� �������
			call PoInfPro
			ret
;----------------------->>>>>OpMode<<<<------------------------------------------
;��������� ��������� ������ ������ ������ AD9833
OpMode:		sbrs CountEncoder,1 ;������� ��������� ������� ���� ��� ����������
			rjmp OpM1
;C��� ������� ���� ������ �������������� ������
			ldi SecByte, 0b00000000
			sts DcomH,SecByte ;<<-------
			ret
OpM1:		sbrs CountEncoder,2 ;������� ��������� ������� ���� ��� ����������
			rjmp OpM2
;C��� ���� ������ ������������ ������
			ldi SecByte, 0b00000010
			sts DcomH,SecByte ;<<<------ ������� ����
			ret
OpM2:		sbrs CountEncoder,3
			rjmp OpM3
;���� ���� ����� �������� ���� DAC
			ldi SecByte,0b00100000
			sts DcomH,SecByte ;<<<------ ������� ����
			ret
;C��� ���� ������� ��� DAC/2
OpM3:		ldi SecByte,0b00101000
			sts DcomH,SecByte ;<<<------ ������� ����
			ret
; ------------------------>>>mul32<<----------------------
;��������� ��������� ���� ������������� 32� ��������� ����.
 ;Mn1 Mn2 VremenPrH VremenPrL ��������(�������� �� ��� ��������)  �� �������� � ��������
 ;�� ������� ������� ����� ����������
 ;Mng1 Mng2 Mng3 Mng4 ���������
 ;FsMM FsML FsLM FsLL ;��������� (FsMM �������)
;============================================
mul32:	ldi Quant,32 ;���������� ���������� ���
		clr FsMM;������� ���������
		clr FsML
		clr FsLM
		clr FsLL 
 Shft:	lsr Mng1 ;����� ��������� ������
		ror Mng2
		ror Mng3
		ror Mng4
		brcs Sum ;������� ���� ��� �������
;�������� �� ���� ���������� ������������
	;����� ����� ���������
ShftL:	lsl VremenPrL
		rol VremenPrH ;���������� ����� ����� ����� �������
		rol Mn2
		rol Mn1
		dec Quant
		BRNE Shft
; ���� ���� ������ ��� ����������
		;mov r1,r9  ;������ ���������� � �������� ���������
		;mov r2,r10
		;mov r3,r11
		;mov r4,r12 ;�� ������������ � �������� ����������
		ret  ;����� �� ���������
Sum:    add FsLL,VremenPrL
		adc FsLM,VremenPrH
		adc FsML,Mn2
		adc FsMM,Mn1
		BRCC ShftL ;������� ���� ��� ��������
ExErr:	SET ;��������� ����� ������
		RET
;------------------------->>>FrTr<<<<-------------------------------------
;�������� �������� ������� �� ����������
FrTr:	 ldi OSRG, TS_WordTr ; �������� ������ � ������� (������ ������ �������)
		 call QueProcedur
		 ldi FisByte, 0b00100001 ; ����� reset ���������. �������������� 
;����� ��������. ��� ������ ����� ����������
		
		 ldi SecByte,0b00000000  ;
		 ldi Quant, 1    ; ��������� ��� ����� ���� �����
		 call QueData 
;
		 ldi Quant,0b01000000 ;�������� ����� �������� ������� � ������
		 or FsLM,Quant
         or FsMM,Quant
		 ldi OSRG, TS_TwoWordTr ; �������� ������ � �������
		 call QueProcedur
; ������� ��� ������� ����� ������� ����� �������
		mov FisByte, FsLM  ;������� ����� ������� ����
		mov SecByte,FsLL   ;������� ����� ������� �����
		mov ThirByte,FsMM; ������� ���� ������� �����
		mov FourtByte,FsML ;������� ���� ������� �����
		ldi Quant,2 ;���� 2 �����
		call QueData
;� ���� ����� ��������� reset(ad9833) ����� ������ � ��������
;����� �� �������� �� ����� ������?
;����� ������� ����� ���������� ������ ������ � ������ ������.
		ldi OSRG, TS_WordTr ; �������� ������ � �������
		call QueProcedur
		ldi FisByte, 0b00000000 ;c�������� ����� 
		lds SecByte,DcomH ;<<<------ ����� ������� ����� (������� ����)
		ldi Quant, 1    ; ��������� ��� ����� ���� �����
		call QueData
;�������� ��������� �� ��������
	    call PrSt
	   ret
;������� ��� 
;------------------------->>>Conf_Time0<<<<--------------------------------
;������������ ������� 0 �� �������.
;TIMSK0 ������� ���������� ���������� ��� ���������� ��������������� 1 � �������������� ���. � 1 � I SEREG
;          TOIEn[0] ���� ���������� ���������� �� ������������ ������� ��������
;          OCIEn ���� ���������� ���������� �� ������� ���������� �������\��������
;          OCIEnA|B|C[2][3] ���� ���������� ���������� �� ������� "���������� �" �������\��������
;          TICIEIn ���� ���������� ���������� �� ������� "�������" ������� ��������
;          ICIEn ���� ���������� �� ������� "������"
;TIFR0    ���� ���������� ����������
;GTCCR ���������� �������������� �������� ���������.
;              TSM[7] = ��������� ������������� ������ 1 ����
;              PSRSYNC/PSRASY[0][1] ��� ������ ������������� (������ 1 � ��� ����)
;OCRnA|B �������� ��������� 
;TCCRnA|B ������������� ��� ���������� ������� ������� ��������
;TCCR(0|2)A             COM0A1   COM0A0  COM0B1  COM0B0    -----   ----    WGM01   WGM00
;TCCR(0|2)B             FOC0A    FOC0B   -----   ------    WGM02   CS02    CS01    CS00
;� ��������� �� 1024 ������������ ���������� ((16*10^6)/1024)/256= 61.03 ��� � �������
;�������� 0.1 ���
Conf_Time0:	ldi FisByte,1
			sts TIMSK0,FisByte
			ldi FisByte, (1<<CS02)|(1<<CS00)
			out TCCR0B,FisByte
			ret

;------------------------------->>>>Wait<<<--------------------------
;��������� �������� ����� ������� �� �������.
;������������ ��� ������ � ���������� ���� �� ����������� �������.
Wait:	ldi FisByte,0
		mov Mng1,FisByte
MPD:	cp SecByte,Mng1
		BRLT MPD3 ;������� ���� ������
		nop
		rjmp MPD
MPD3:   SBIC PIND,PD3          ;������� ��������� ������� ���� ��� �������
		ret
		ldi FisByte,0
		mov Mng1,FisByte
		ldi SecByte,95   ;95 ��� 2 <<<------������� ��� �������
MPD1:	cp SecByte,Mng1
		BRLT MPD4 ;������� ���� ������
		nop
		rjmp MPD1
MPD4:	ldi FisByte,0 ;�������� ������
		sts TIMSK0,FisByte
		cli
		SBIC PIND,PD3          ;������� ��������� ������� ���� ��� �������
		ret
;C��� ���� ������ ������ �� ���������� 2���.
		dec CE
		dec CE
		ret		
;==================================================================================================
;����������
;------------------------>>>InterSPI<<<----------------------------------------
;���������� �������� �� ������� ��������� �� ����������
InterSPI:	cli    ; ��������� ����������.
			push Tmp2
			in Tmp2,SREG ; ��������� �������� ������
			push Tmp2;
			ldi ZL,low(TaskQueue)
			ldi ZH,high(TaskQueue) 
			ld Tmp2,Z		;����� ����� ������� ������
			cpi Tmp2,0xFF	;���� � ������� ��� ����� ������� !!��������!!!
			BREQ EndInterSPI
; ��������� ���� ��� ������ ������ �� �������
			clr ZH ;��������� ������� ����
			lsl  Tmp2 ; ������ ����� ������ �������� �� 2. �.�. ������ �����������
			mov ZL, Tmp2
			subi ZL, low(-TaskProcs*2) ;�������� �� �������
			;���������� � ��������� ������� ������� �������
			sbci ZH, high(-TaskProcs*2) ; ���� ������ � ���������
			;������ Z ��������� �� ����� ��� ����� ����� ����������� ���������
			lpm Tmp2,Z+ ;����� ������� ���� ����� ��������� �� ������
			mov r0,Tmp2
			lpm Tmp2,Z+ ; ����� ������� ���� ������ ��������� �� ������ � r0
			mov ZH,Tmp2 ;������ � Z ����� ��������
			mov ZL,r0
			pop Tmp2 ; ���������� �����. ���� ��� ���������� ���� 
			out SREG,Tmp2 ; ���������, �� ��� �������� � ��� ��������.  �� ������� �.� ������ ��������� � ����� ���������������
			pop Tmp2;
			ijmp   ; ��������� � ������
			ret
EndInterSPI: ldi ZL, low(MasByte) ; ������ ��� �������� 
			 sts CurrentByteL, ZL ;��� ��������� ������ ��������� �������� ������ ����� � ������ �������
			 sts ReadDatL,ZL 

			 ldi ZH, high(MasByte) 
			 sts CurrentByteH,ZH
			 sts ReadDatH,ZH
			 pop Tmp2 ; ���������� �����. ���� ��� ���������� ���� 
			 out SREG,Tmp2 ; ���������, �� ��� �������� � ��� ��������. 
			 pop Tmp2;
			 ret
;
;
; ----------------------->>> Encoder <<<--------------------------------------------------
Encoder:		cli
				in FisByte, PIND
				andi FisByte,0b00010000 ;���������� ��������� ������� ������
				;��� ����������� � ����� ������� ���������
				mov CE,CountEncoder
				andi CE,0b01100000
				cpi CE,0
				BRNE EnC1 ;������� ���� �� �����
;C��� ����� ���� �� ���� ������� �� ��������� �����
				ldi Quant,1
				EOR CountEncoder,Quant
;��� ������������� ��������, ������������� ����
				sbi PORTC,0 ;��������� ����
				sbrs CountEncoder,0 ;������� ��������� ���� ��� ����������
				cbi PORTC,0 ;����� ����
				
				;out PORTC,CountEncoder ;<<<<---------------��������
;������ ��������� � ����������� �������� ��������� ������ �� ����� ������ 
				mov Quant,CountEncoder
				andi Quant,1 
				cpi Quant,0 
				brne SFren
;���� ���� ����� �������
				ldi  FsMM,3 ;��������� ������
				ldi  FsML,4 ; ��������
				ldi FsLM,0 ;��������� �������
				ldi FsLL,15 ;�������� �������
				rjmp PPoint
;c��� ���� ����� �������
SFren:			ldi  FsMM,5 ;��������� ������
				ldi  FsML,6 ; ��������
				ldi FsLM,0 ;��������� �������
				ldi FsLL,15 ;�������� �������	
;C��� ������� ��������� ������ ������ ����
PPoint:			call QueStartSig  ;�������� ������� �����
				call PoInfPro ;����� ��������� ������ ����
				call QueStopSig ; �������� ������� ���� ����� ��������
				reti ;��������� �� ����� ����������?? ����� �� ���������?

;C��� ������� ���� ���� ������� �� �������
EnC1:			cpi CE,0x20
				BRNE EnC2
;C��� ������� �� ������� �������
				mov CE,CountEncoder
				andi CE,0b00011110
				lsr CE  
				mov Quant, CountEncoder 
				andi Quant,0b00000001 ;��������� ��� 0-������� 1-�����
				cpi Quant,1
				BRNE EnC3 ;��������� ��� ��������� �������
;C��� ������� ��� ������ ������ ���������
				cpi FisByte,0
				BRNE EnC4 ;��������� ���� ������ ������
;C��� ������� ���� ������ �����, ��������� �������� ��������� ������ ������
				ldi Quant,1
				cp Quant,CE
				BRSH EnC5 ;������ ��� ����� �������
				lsr CE ; �� ����� �� �������
				jmp EnC7
;C��� ������� ���� ��� �������� ����� �� �������
EnC5:			ldi CE,0x08
				jmp EnC7


;C��� ������� ���� ������� ������
EnC4:			cpi CE,0x08
				BRGE EnC8
				lsl CE ; �� ����� �� �������
				rjmp EnC7
;���� ����� �� �������
EnC8:			ldi CE,1
;C��� ��� ������ �������� � CountEncoder � ����������� ����, ������ ��������
EnC7:			LSL CE
				andi CountEncoder,0b11100001
				or CountEncoder,CE
;---->>> ����� �������������� ����, ������� ��������<<<<------
;����� ������� �� �������� � ������. � �������� ���������, � �����
;����� � ���������� ���� �� ����������� �������
				call QueStartSig
				call PointCheck
				call QueStopSig
				;out PORTC,CountEncoder
				reti ; ��� Ret ��� � ������ �� �������� ����?





;���� �������� ���� ������ ����� ��������� ������� (������� ��� ���������)
EnC3: 			cpi FisByte,0
				BRNE EnC9 ;��������� ���� ������ ������
				;C��� ������� ���� ������ �����
				ldi Quant,1
				cp Quant,CE
				BRSH EnC10 ;������ ��� ����� �������
				lsr CE ; �� ����� �� �������
				jmp EnC11
;C��� ��� ���������� ������ �� �������. ������ ��������
EnC10:			ldi CE,0x08 ;<<----
				jmp EnC11
EnC9:			cpi CE,0x08
				brge EnC12  ;������� ���� ����� �� �������
				lsl CE
				RJMP EnC11
;����� �� �������
EnC12:          ldi CE,1
;���� ��������� ��� �������� ���� ������, ����������� ���� �������
EnC11:	LSL CE
		andi CountEncoder,0b11100001
		OR CountEncoder,CE ;������������� ����� ��������
; �������� ����������� ������� ������ <<<----------------------------
		out PORTC,CountEncoder
		reti ; ret ��� 	reti??	
;���� ��������� ������� ������ ����� ���������� �������

;C��� ��� �������� ������� �������
EnC2:	;cpi CE,0x40
		SBRS CE,6 ;������� ��������� ������� ���� ��� ����������
		jmp EnC13 ; ������� �� �������� �������
		;cpi FisByte,0
		SBRC CE,5 ;������� ��������� ������� ���� ��� �������
		jmp EnC13
		SBRS FisByte,4 ;������� ��������� ������� ���� ��� ����������
		jmp EnC14 ;��������� ���� ������ ������
;������ ����� ((( ��� �� ��������� �����)
		mov CE,CountEncoder
		andi CE,0b00000010
		cpi CE,2
		BRNE EnC20
;��������� ���� ���� ����������� �� 1 ���
	ldi FisByte,0x01
	clr SecByte
	add NumFrL,FisByte
	adc NumFrH,SecByte
	jmp EnC15

EnC20: 		SBRC CountEncoder,2    ;������� ��������� ������� ���� ��� �������
			RJMP EnC16 ;��������� ��� ���������� �� 10���
			SBRC CountEncoder,3    ;������� ��������� ������� ���� ��� �������
			RJMP EnC50 ;����������� �� 100���
;����������� �� 500���
			ldi FisByte,0xF4
			ldi SecByte, 1
			add NumFrL,FisByte
			adc NumFrH,SecByte
			rjmp EnC15
;��� ���������� �� 10���
EnC16:	ldi FisByte,0x0A
		clr SecByte
		add NumFrL,FisByte
		adc NumFrH,SecByte
		rjmp Enc15
;��� ���������� �� 100���
EnC50:	ldi FisByte,0x64
		clr SecByte
		add NumFrL,FisByte
		adc NumFrH,SecByte

;��������� �� ����� �� ���������� ����� �� �������
EnC15:	mov FisByte,NumFrH
		cpi FisByte,0x30
		brlt EnC51 ; ������� ���� ������
		clr NumFrH
		clr NumFrL
		rjmp EnC55
EnC51: 	mov FisByte,NumFrH
		cpi FisByte,0
	   brlt EnC52 ;������� ���� ������
EnC55: ldi FisByte,0
;������ ���������
		mov Mn1,FisByte
		mov Mn2,FisByte
		mov VremenPrH,NumFrH
		mov VremenPrL,NumFrL
;������ ��������� 10737
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

;������ �������� ����� �� ������ �� ����� � ��������� ��������(����� �������)
EnC53:  call mul32 ;���������	

		mov CE,FsMM
		andi CE,0b00001000
		cpi CE,8
		BRNE EnC17   ;������� 
; �������� ������ �������� ����� ����� �� �������
		clr FsMM
		clr FsML
		clr FsLM
		clr FsLL
; �������� �������� ����� ��������� � ����������
EnC17: ;����� ���� ���� ��������� ������ �������� � ����� � ����� ������� ����� ������
		push FsMM
		push FsML
		push FsLM
		lsl FsMM
		lsl FsML
		brcc Ts1 ;������� ���� ��� ��������
		ori FsMM,0b00000001 ;
Ts1:	lsl FsLM
		brcc Ts2 ;������� ���� ��� ��������
		ori FsML,0b00000001
Ts2:	lsl FsMM
		lsl FsML
		brcc Ts3 ;������� ���� ��� ��������
		ori FsMM,0b00000001
Ts3:	lsl FsLM
		brcc Ts4 ;������� ���� ��� ��������
		ori FsML,0b00000001
Ts4:	lsr FsLM
		lsr FsLM
;--->>>�������� �������� ��� ���������� ������ � ������ <<<-----
;����� �������� ��������� ���������� ������ ������ � ������� --<<<<
		call FrTr ;������� ��������� �������� ������ � ������ � AD9833
;---->>>�������������� ������ �������� �� ����� <<<-----
		pop FsLM
		pop FsML
		pop FsMM
        reti ;reti ��� ret?

EnC14:	 ;������ �����
		;andi CE,0b00000010
		SBRS CountEncoder,1 ;������� ��������� ������� ���� ��� ����������
		RJMP EnC21
;��������� ���� ���� ��������� �� 1 ���
	ldi FisByte,0x01
	clr SecByte
	sub NumFrL,FisByte
	sbc NumFrH,SecByte
	jmp EnC15
;�������� �� 50���
EnC21: 		
			;andi CE,0b00000100
			SBRC CountEncoder,2
			RJMP EnC22 ;��������� ��� ���������� �� 10���
			SBRC CountEncoder,3
			RJMP EnC60
;��������� �� 500���
			ldi FisByte,0xF4
			ldi SecByte, 1
			sub NumFrL,FisByte
			sbc NumFrH,SecByte
			jmp EnC15
;��������� �� 10���
EnC22:	ldi FisByte,0x0A
		clr SecByte
		sub NumFrL,FisByte
		sbc NumFrH,SecByte
		jmp EnC15
;��������� �� 100���
EnC60:	ldi FisByte,0x64
		clr SecByte
		sub NumFrL,FisByte
		sbc NumFrH,SecByte
;C��� ����� ���� ���� ������ �������
EnC13:  ldi CE,0
		ldi CountEncoder,0
;------->>����� ������� ��� ��� ���� <<----------------
		out PORTC,CountEncoder
		reti ;���������� ���� ������������
; -------------------------->>PresEn<<<---------------------------------
;���������� ������� ������ <<<<<---------------------
PresEn:   call Conf_Time0
		  mov CE,CountEncoder
		  andi CE,0b01100000
		  swap CE ; ����� ������� � ������� ����� �������
		  lsr CE  ; ������� ������ ������� ����� ����� ��������
		  inc CE  ; ���������� �� �������
		  
		  ldi SecByte,14;14 ��� 1 ������� �� ����� ������� �.�. ����� ������ ;���������� ��� ��������� ������������ ��������
		  sei   ;<<<<<-------�������� ������ ����� ����� ���������� ���������
		  call Wait
		  cli
		  cpi CE,0
		  BRLT PE41 ; ������� ���� C�<0
		  rjmp PE42

PE41:	  ldi CE,0
PE42:	  cpi CE,2
		  brlt PE1 ;������� ���� ������
		  cpi CE,3
		  breq PE2
;C��� ��������� ���� ������ �������
		  SBRC CountEncoder,0; ������� ��������� ������� ���� ��� �������
		  rjmp PE3
;C��� ������� ���� ������� ������� � ���� ��������� �������
		  SWAP CE
		  LSL CE
		  andi CountEncoder,0b10011111
		  OR CountEncoder,CE
		  call Encoder
		  reti
;C��� ��������� ���� ���� ������ ������� 
PE2:	swap CE
		lsl CE
		andi CountEncoder,0b10011111 ;�� �������� ������� ��������� � �������� ����
		OR CountEncoder,CE
		call Encoder
		reti
;C��� ��������� �� ������� �������
PE1:	swap CE
		lsl CE
		ori CE,0b00000010
		andi CountEncoder,0b10011111
		OR CountEncoder,CE
		ldi FisByte,0xFF
		DOUT PosMemStr,FisByte ; �������� � ������ ��������� ���������
		call QueStartSig ;��������� ������ �����
		call MenSMode ;���������� ����
		call QueStopSig ;���������� � ������� �������� ������� ����
		;call Encoder  ;<<<<-------------------- ������� � ����������
		reti
;������� ������� � ���� ������ ������
PE3: call OpMode ; �������� ������� ��������������� ���������� ������
	 ldi CountEncoder,0
	 ldi CE,0
	 ;������� ����� ������������
	 call Encoder
	 reti
;==================================================================================
;--------------------------->>Time_ms<<-------------------------------
;C��� ��������� �� ���������� �� �������. ������� ������� ������� �� ��������� ������������
Time_ms:    inc Mng1
			reti
;====================================================================
;-------------------------->>Eve_TWI<<--------------------------------
;������������� r18,R20, ��������� ���� �� ����������

Eve_TWI :	DIN r20,SREG ;��������� ������ ������� � �����
			push r20
			cli
			DIN r18,TWSR ;������� ��� �������
;
			cpi r18,0x08 ;��������
			BRNE P0x08 ;������� ���� �� �����
;			
			;C��� ������� ���� ������� ������������ ��������� �����
Tr_Adr:		call ShiftQue ;������ ������� ������� ����� �������� �����
;<<<-----------���������� ���-�� ������ ����������
			DIN r20,AdrSSD
			DOUT TWDR,r20 ;����� ����� � ����� ��������
			ldi r20,0b10000101 ;����� �������� ��������� ������
			DOUT TWCR,r20
			pop r20
			DOUT SREG,r20
			reti ;����� �� ����������
;
P0x08 :		cpi r18,0x18
			BRNE P0x18 ;������� ���� �� �����
;
			;���� ���� ��� ������� ����� � ������� �������������
			call InterSPI ;������ ��������� �� �������
			pop r20
			DOUT SREG,r20
			reti ;++++
;
P0x18 :		cpi r18,0x20	
			BRNE P0x20 ;������� ���� �� �����
;
			;��� ������� ����� � �� ������� �������������
			ldi r20,0b10100101 ;�������� ��������� ��������
			DOUT TWCR,r20
			pop r20
			DOUT SREG,r20
			reti
;
P0x20 :		cpi r18,0x28
			BRNE P0x28 ;������� ���� �� �����
;			
			;C��� ���� ��� ������� ����� ������ � ������� �������������
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
			;���� ������������ ��������� ��������
			DIN r20,AdrSSD
			DOUT TWDR,r20 ;����� ����� � ����� ��������
			ldi r20,0b10000101 ;����� �������� ��������� ������
			DOUT TWCR,r20
			pop r20
			DOUT SREG,r20
			reti ;����� �� ����������
;			
P0x10 :		pop r20
			DOUT SREG,r20
			reti
;=============================================================
;0x00 ��������� ������
		  S0: .db 0x03,0x0E,0x3C,0x64,0x34,0x1E,0x07,0x00			;�
		  S1: .db 0x41,0x7F,0x49,0x49,0x49,0x66,0x00,0x00			;�
		  S2: .db 0x41,0x7F,0x49,0x49,0x49,0x36,0x00,0x00			;�
		  S3: .db 0x41,0x7F,0x41,0x40,0x40,0x60,0x00,0x00			;�
.org S3+4 S4: .db 1,2,3,4,5,6,7,8			;�
		  S5: .db 0x41,0x7F,0x49,0x49,0x41,0x41,0x00,0x00			;�
		  S6:								;�
.org S6+4 S7:								;�
.org S7+4 S8: .db 0x7F,0x03,0x07,0x18,0x30,0x7F,0x00,0x00			;�
.org S8+4 S9:								;�
.org S9+4 S10:								;�
.org S10+4 S11:	.db 0x01,0x41,0x7E,0x40,0x40,0x7F,0x40,0x00			;�
.org S11+4 S12:								;�
.org S12+4 S13: .db 0x41,0x7F,0x49,0x08,0x49,0x7F,0x41,0x00			;�
		   S14: .db 0x1C,0x22,0x41,0x41,0x41,0x22,0x1C,0x00			;�
		   S15:	.db 0x41,0x7F,0x41,0x40,0x41,0x7F,0x41,0x00			;�
		   S16:	.db 0x41,0x7F,0x49,0x48,0x48,0x30,0x00,0x00			;�
		   S17:	.db 0x1C,0x22,0x43,0x81,0x81,0x22,0x00,0x00			;�
.org S17+4 S18: .db 0x40,0x40,0x40,0x7F,0x40,0x40,0x40,0x00			;�
		   S19:								;�
.org S19+4 S20:								;�
.org S20+4 S21:								;�
.org S21+4 S22:								;�
.org S22+4 S23: .db 0x40,0x78,0x08,0x08,0x08,0x7F,0x41,0x00			;�
.org S23+4 S24:								;�
.org S24+4 S25:								;�
.org S25+4 S26:								;�
.org S26+4 S27: .db 0x7F,0x11,0x11,0x1F,0x00,0x7F,0x00,0x00			;�
		   S28:								;�
.org S28+4 S29:								;�
.org S29+4 S30:								;�
.org S30+4 S31: .db 0x00,0x01,0x71,0x4E,0x48,0x7F,0x41,0x00			;�
;
.org S31+4 S32:								;�
.org S32+4 point: .db 0x00,0x7F,0x7F,0x7F,0x3E,0x1C,0x08,0x00       ;����� ���������(���������)

;128x32
;������������
;����� Vin
;����� Gnd
;����� Rst
;������� D11
;���������� D12
;������ D13
;
;
;SPI 
;MOSI=	D11=PB3
;SCK=	D13=PB5
;SS     PB1 --> D9  (16bit)
;PC0-5 = A0-A5 �����; PC0������� 
;������� 
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
;������������� ���������?
