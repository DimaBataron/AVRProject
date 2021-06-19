/*
 * AsmFile17.asm
 *
 *  Created: 14.06.2021 11:47:06
 *   Author: dima
 *  *	��������� �������� ������ �� ����� SSD1306 128x64 v.0.1
 * TWI ������������� ��� FlagCon[0] �� ����������. ����� � ����� ����� ��������� ����� ����� 
 * ���� �������� �� ���� �������. ����� ������� ����� ������������� �������� �� ���������� �� ��������.
 * ������� ���������� ������� ���������� � ���. 
 * ��������� ������ � ��� �������� � ��������� ��������� ������.
 * ���� ������� ������������� ���������� ���� ��������� ����� ���������� ������� ���������.
 */ 
 .include "F:/AVR/7.0/packs/atmel/ATmega_DFP/1.6.364/avrasm/inc/m328Pdef.inc"
.include "E:/A/AssemblerApplication1/AssemblerApplication1/Macro.inc"
; Replace with your application code
; FLASH ===================================================
;������������� �����
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
.ORG   INT_VECTORS_SIZE      	; ����� ������� ���������
;
.DSEG
FlagCon: .byte 1	;b[0] - ���� �������� ��������������� ������ � TWI ����� ��������
                    ;b[1] - ���� ��������� �������������
                    ;b[2] - ���� ���������������� ��������� ������
                    ;b[3] -  ���� ���������������� ��������� �������
                    ;b[4] - ���� ������� �������
                    ;b[5] - ���� �������� ������
                    ;b[6] - ���� �������� ������
					;b[7] - ������������� � �������� ������ �������� � ������ � ������. 
InitCount: .byte 1		;������� ��������� �������������
LenMasInit: .byte 1		;������ ������� �������������
NumWhileInit : .byte 1	;���������� ���������� ����� �������� ������ �����
ZInitLow: .byte 1       ;� ���� ������� r30. ��������� ���� ������� ����� ������� ������������� ��� ������ ��.
ZInitHi: .byte 1		;� ���� ������� r31. C������� ���� ������� ����� ������� ��� �������������.
AdrSSD: .byte 1			;����� ��������
;
NumWhilePos: .byte 1	 ;���������� ���������� ���� ����������������
SetPagSt:	 .byte 1     ;��������� ����� �������� 0-7(������)
SetPagEnd:	 .byte 1     ;�������� ����� �������� 0-7(������)
SetColSt:	 .byte 1     ; ��������� ������� 0-15(������)
SetColEnd:	 .byte 1     ;�������� ������� 0-15 (������)
CountPosYk:	 .byte 1     ;������� ��������� ����������������.
SelectPosYk: .byte 1     ;��������� ��� ����������� �����.
XPosYkLO:    .byte 1     ;��� �������� ��������� ������������� ����� ������� �� ���
XPosYkHi:    .byte 1     ; ���� ������ ��������
;
CleanSym:    .byte 1 ;���������� �������� ������� ���� ��������
CleanNow:    .byte 1 ;��������� � ������ ������ ������
CleanWhile:  .byte 1 ; ��������� ���� � ������� ������
CleanByte:    .byte 1 ; ���� ������� ��������� ��� ������������.
CleanFlag:    .byte 1; ���� ����������� � ��� ��� ��� ������� � ��������� � ��� ���������� ���� x40 �� ����. �� ������ �������� ��� ������!!!
;
TrDatLow:     .byte 1  ;r30. ��������� ���� ������� ����� ������� �������� ������� ���������
TrDatHi:      .byte 1  ;� ���� ������� r31. C������ ���� ������ ������� ��������
TrDataCount:  .byte 1  ;���������� ���� ������ ������� ������� ��� ��������
TrDataCountB: .byte 1  ;���� ���� ��� ����� �������� ����������� ���� (��� ������������� �������� ������� ��������)
TrSymByteL:   .byte 1  ;��������� �� ������ ������������� ����� ������ �������
TrSymByteH:   .byte 1  ;��������� �� ������ 
;
XPosComLo:    .byte 1 ;��������� �� ������ ����� ������� ��������� �������
XPosComHi:	  .byte 1 ;������� ����
;������ ������ �������� ���������� ��� ������������ ���������� �����
SetPagStB:    .byte 1 ;����� ��������� ������
SetPagEndB:	  .byte 1 ;
SetColStB:    .byte 1 ; ����� ���������� �������
SetColEndB:	  .byte 1 ;
XPosYkLOB:    .byte 1 ; ����� ���������� ������ ������� ���������������� ��������� ������(��������)
XPosYkHiB:	  .byte 1
XPosComLoB:	  .byte 1 ;����� ���������� ������ ������� ���������������� ��������� �������(�������)
XPosComHiB:	  .byte 1
CleanSymB:    .byte 1 ;����� ���������� �������� ������� ���� ��������
TrDatHiB:	  .byte 1 ;����� ��������� ������� ������
TrDatLowB:	  .byte 1
;
CountEncoder: .byte 1 ;������� ������������ ��������� ��������
FlagConMas:	  .byte 1 ;����� ������
.CSEG
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
Text:	  .db "��",0 ;��������������
Text1:	  .db "������",0
Text2:	  .db "��",0
Text3:	  .db "������",0
;
 Reset:	cli
		LDI R16,Low(RAMEND)	; ������������� �����
		OUT SPL,R16		; �����������!!!
		LDI R16,High(RAMEND)
		OUT SPH,R16
;===== �������������� ���������� ���������� ����������==========================
		LDI r18,((AdrSSD0-InitSSD)*2) 
		DOUT LenMasInit,r18 ;���������� ������ ������� �������������
		ldi r18,0
		DOUT InitCount,r18 ;������� ��������� ����������������
		DOUT NumWhileInit,r18 ;���������� ���������� ����� �������� ������ �����
		DOUT NumWhilePos,r18  ;���������� ���������� ���� ����������������
		DOUT CountPosYk,r18
		DOUT SelectPosYk,r18
		LDI 	ZL,low(InitSSD*2) 	; ������� ������� ���� ������, � ����������� ���� Z
		LDI  	ZH,high(InitSSD*2)	; ������� ������� ���� ������, � ����������� ���� Z
		DOUT ZInitLow,ZL ; ��������� ��������� ����� ������� �������������.
		DOUT ZInitHi,ZH
		LDI 	XL,low(SetPagSt) 	;������� ������� ���� ������, � ����������� ���� X
		LDI  	XH,high(SetPagSt)	;������� ������� ���� ������, � ����������� ���� X
		DOUT XPosYkLO,XL ; ��������� ��������� ����� ������� ����������������
		DOUT XPosYkHi,XH
		;
		LDI XL,low(SetColSt)  ;���������� ������ ������ ��������� �������.
		LDI XH,high(SetColSt) ;����� � ���� ������ ������ ��� ����������
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
;������������ INT0 �� ���������� ������ ����� D2=PD2 ������������ �������
;� INT1
		ldi r18,0b00000010	;�� ���������� ������ �� ������ INTn
		DOUT EICRA,r18		
		ldi r18,0b00000001  ;��������� ������� ���������� INT0
		DOUT EIMSK,r18
;=========================================================
;��� ������������ ������ ��� ������ ��������
		LDI r18,0b01111000
		DOUT AdrSSD,r18		;���������� ����� ��������
		TWFscl 70,0 ;������ 102.6��� ������� ������ TWI Fscl ;SSD1306 �������� 400���
		;
		
		ldi r18,0x12
		DOUT FlagCon,r18 ;������������ ���� ������ ��������� �������������
		 ;��������������� ��������� ������
		;������� ������� � �������� ������
		/*
		ldi r18,0
		DOUT SetPagSt,r18 ;���������  ������ (0-7)
		ldi r18,7
		DOUT SetPagEnd,r18 ; �������� ������ (0-7)
		;
		ldi r18,0 ; ��������� �������
		DOUT SetColSt,r18
		ldi r18,15 ; �������� �������
		DOUT SetColEnd,r18
		*/
		ldi r18,128
		DOUT CleanSym,r18  ;���������� �������� ������� ���� ��������
		/*
		;
		LDI 	ZL,low(Text*2) 	; ������� ������� ����� ������ �������� ������� ����� ��������
		LDI  	ZH,high(Text*2)	
		DOUT TrDatLow,ZL    
		DOUT TrDatHi,ZH ;��������� ����� ������� �������� ������� ����� �������.      
		*/
		ldi r18,0b10100101 ;��������� ��������� ����� �� ���� TWI
		DOUT TWCR,r18
		sei		;�������� ����������
;=============�������� ���� ���������=================================
Main:	DIN r18,FlagCon
		ANDI r18,1
		cpi r18,1
		BRNE Main ; ��������� � ������ ���� FlagCon[0]=0 
;		
		DIN r18,FlagCon
		ANDI r18,0b11111110
		DOUT FlagCon,r18    ;�������� ���� �������� ��������. �� ������������� ������ ������� TWI
		ANDI r18,2
		cpi r18,2   ;�������� ���������� �� ���� ��������� �������������
		Brne FlPosYk   ; �������� ��� �������� ����� ��������� ��������� ������
;b[1] -���� ����  ���� ��������� ������������� ���������
		call StartInit
		jmp Main
;
FlPosYk: DIN r18,FlagCon
		 ANDI r18,4
		 cpi r18,4
		 Brne FlConYk   ; �������� ��� �������� ����� �������
;b[2] - ���� ���� ���������� ���� ���������������� ��������� ������
		call PosYkP
		jmp Main
;
FlConYk: DIN r18,FlagCon
		 ANDI r18,8
		 cpi r18,8
		 Brne CleanFl
;b[3] - ���� ���� ���������� ���� ���������������� �������
		 call PosYkCol
		 jmp Main
; ��������� ��������
CleanFl: DIN r18,FlagCon
		 ANDI r18,16  ;�������� ��������� �� ���� �������
		 cpi r18,16
		 Brne SymTr; �������� ��� �������� ����� �������� ������� ������ ������ (��������)
;b[4] ���� ���� ��������� ���� ������� �������
		 call Clean
		 jmp Main
SymTr:   DIN r18,FlagCon
		 ANDI r18,64
		 cpi r18,64
		 BRNE BufFlag ;�������� ���� �������� ���� ��������.
;b[6]- c��� ���� ��������� ���� ��������
		 call TrData
		 jmp Main
BufFlag: DIN r18,FlagCon
		 ANDI r18,128
		 cpi r18,128
		 BRNE End
;b[7] - ���� ���� ���� �������� ��������� ����� � ������ ������
		 call BufData
		 jmp Main

End:	sei   ;������� �� �������� ��������� �������� ����� �������� ����� ���������� ������������ � �� �����������������
		;�������� ��������� ����
		ldi r18,0b10010101
		DOUT TWCR,r18
		jmp Main ; ��������� ���� ������ ��� �����
;====================���������=============================================
	;-------------->>StartInit <<----------------------------
;��� ������� ���� ������������ ������������� ����� ����������
;NumWhileInit				;LenMasInit					;InitCount
;ZInitLow					;ZInitHi				    ;
;�������� r18,r19 
StartInit: DIN r18,NumWhileInit
		   DIN r19,LenMasInit
		   cp r18,r19
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
		   inc r18
		   DOUT InitCount,r18
		   DIN r18,NumWhileInit
		   inc r18
		   DOUT NumWhileInit,r18
		   DIN ZL,ZInitLow
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
InitEnd:   ldi r18,0
		   DOUT NumWhileInit,r18
		   DOUT InitCount,r18
		   DIN r18,FlagCon
		   ANDI r18,0b11111101 ;b[1] - �������� ���� ��������� �������������
		   DOUT FlagCon,r18 ; �������� ���� ������������� �.�. ��� ����� ��������
		   ldi r18,0b10100101;�������� ��������� ��������
		   DOUT TWCR,r18 
		   reti
;
;
;---------------->>>PosYkP<<<-----------------------------------------
;��������� ���������������� ��������� ��������(������)
;������������ ����� � ��������� 
;NumWhilePos		EndTrCom			CountPosYk
;SelectPosYk		XPosYkLO			XPosYkHi
;1.�������������: ��������� � ��� �� �������  SetPagSt SetPagEnd
;��������� � �������� ����� ��������(������ ��� �������������� � ������������ ���������)
;2.������� � ���� �������� XPosYkHi:XPosYkLO ����� ��� SetPagSt
;3.���������� ���� FlagCon[2]
;4.����� ��������� ���� ������ ������������ ��������� �����.
PosYkP:	   DIN r18,NumWhilePos
		   cpi r18,3
		   brge  EndTrCom  ;������� ���� �������� 3����� ���������������� ������
		   DIN r19,CountPosYk
		   cpi r19,0
		   BRNE CountContr ; ������� ���� �������� ��� ���� ������������
;���� ��������� ��� ������������ ��������� ��������
		   inc r19
		   DOUT CountPosYk,r19
		   ldi r19, 0b10100101 ;�������� ��������� ��������
		   DOUT TWCR,r19
		   reti
CountContr:	cpi r19,1
		    BRNE CounComand ;<��������� ��� �������� ��������������� �������
;C��� ������� ��� �������� ������������ �����
		    inc r19
		    DOUT CountPosYk,r19
		    ldi r19,0x00
			DOUT TWDR,r19 ; �������� ����������� ����
			ldi r19,0b10000101
			DOUT TWCR,r19 ;���������� ��������
			reti
;C��� ��������� ��� �������� �������
CounComand: ldi r19,0
			DOUT CountPosYk,r19
			DIN r19,SelectPosYk
			inc r18
			DOUT NumWhilePos,r18
			cpi r19,0
			BRNE CouComCon ;������� ��� �������� ���������������� ���� �������
;����� ���������� ������ ���� �������
			ldi r18,0x22
			inc r19
			DOUT SelectPosYk,r19
			DOUT TWDR,r18
			ldi r18,0b10000101 ; ���������� ��������
			DOUT TWCR,r18
			reti
;C��� ��������� ��� �������� ���������� ���� �������
CouComCon:  DIN XL,XPosYkLO
			DIN XH,XPosYkHi
			LD r18,X+
			DOUT TWDR,r18
			DOUT XPosYkLO, XL
			DOUT XPosYkHi,XH
			ldi r18,0b10000101
			DOUT TWCR,r18 ; ���������� ��������
			reti
;�������� ��� ������ ����� ������� ����� ������
EndTrCom:	ldi r18,0
			DOUT NumWhilePos,r18
			DOUT CountPosYk,r18
			DOUT SelectPosYk,r18
			DIN r18,FlagCon
			ANDI r18,0b11111011
			DOUT FlagCon,r18
			LDI r18,0b10100101
			DOUT TWCR,r18 ;�������� ��������� ��������
			reti
;=======================================================================
;---------------->>>PosYkCol<<<-----------------------------------------
;��������� ���������������� ��������� ��������(������)
;������������ ����� � ��������� 
;NumWhilePos		CountPosYk			SetColSt			SetColEnd
;SelectPosYk		XPosComLo			XPosComHi
;1.�������������: ��������� � ��� �� �������  SetColSt SetColEnd
;��������� � �������� ����� ��������(������ ��� �������������� � ������������ ���������)
;2.������� � ���� �������� XPosComHi:XPosComLo ����� ��� SetColSt
;3.���������� ���� FlagCon[3]
;4.����� ��������� ���� ������ ������������ ��������� �����

PosYkCol:  DIN r18,NumWhilePos
		   cpi r18,3
		   brge  EndTrCom12  ;������� ���� �������� 3����� ���������������� ������
		   DIN r19,CountPosYk ;������� ��������� ����������������.
		   cpi r19,0
		   BRNE CountContr1 ; ������� ���� �������� ��� ���� ������������
;���� ��������� ��� ������������ ��������� ��������
				inc r19
				DOUT CountPosYk,r19
				ldi r19, 0b10100101 ;�������� ��������� ��������
				DOUT TWCR,r19
				reti
CountContr1:	cpi r19,1
				BRNE CounComand1 ;<��������� ��� �������� ��������������� �������
;C��� ������� ��� �������� ������������ �����
				inc r19
				DOUT CountPosYk,r19
				ldi r19,0x00   
				DOUT TWDR,r19 ; �������� ����������� ����
				ldi r19,0b10000101
				DOUT TWCR,r19 ;���������� ��������
				reti
				Jmp CounComand1
EndTrCom12:		RJMP EndTrCom1
;C��� ��������� ��� �������� �������
CounComand1:	ldi r19,0
				DOUT CountPosYk,r19
				DIN r19,SelectPosYk ;��������� ��� ����������� �����.
				inc r18
				DOUT NumWhilePos,r18
				cpi r19,0
				BRNE CouComCon1 ;������� ��� �������� ���������������� ���� �������
;����� ���������� ������ ���� �������
			ldi r18,0x21 ;Set Column Address
			inc r19
			DOUT SelectPosYk,r19
			DOUT TWDR,r18
			ldi r18,0b10000101 ; ���������� ��������
			DOUT TWCR,r18
			reti
;C��� ��������� ��� �������� ���������� ���� �������
CouComCon1:		DIN XL,XPosComLo ; ����������
				DIN XH,XPosComHi  ;
				LD r18,X+
				; ����� �������
				lsl r18
				lsl r18
				lsl r18 ;��������� �� 8
				cpi r18,120 ; ��������� ������. �������� �� �����.
				Brne TrComDat1 ;�� ����� ������� �����
				ldi r18,127
TrComDat1:		DOUT TWDR,r18
				DOUT XPosComLo,XL
				DOUT XPosComHi,XH
				ldi r18,0b10000101
				DOUT TWCR,r18 ; ���������� ��������
				reti
;�������� ��� ������ ����� ������� ����� ������
EndTrCom1:		ldi r18,0
				DOUT NumWhilePos,r18
				DOUT CountPosYk,r18
				DOUT SelectPosYk,r18
				DIN r18,FlagCon
				ANDI r18,0b11110111  
				DOUT FlagCon,r18
				LDI r18,0b10100101
				DOUT TWCR,r18 ;�������� ��������� ��������
				reti
;
;---------------------->> Clean <<-----------------------------
Clean: DIN r18,	CleanNow
	   DIN r19, CleanSym
	   cp r18,r19
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
			DIN r20, FlagCon
			ORI r20,0b00000001 ;b[0] - ���� �������� ��������������� ������ � TWI ����� ��������
			;������������ ���� ���� ����� ������� ����� ����
			DOUT FlagCon,r20
			ret
;���� ��������� ��� �������� ��������.
EndClean:   ldi r18,0
			DOUT CleanNow,r18
			DOUT CleanFlag,r18
			DIN r18,FlagCon
			ANDI r18,0b11101111 ;�������� ���� �������
			DOUT FlagCon,r18
			ldi r18,0b10100101
			DOUT TWCR,r18
			;�������� ��������� ��������
			reti
;
;---------------------TrData------------------------------
;��������� ����������� �� ���� ������ ���� ��� ������. 0 ������� ��������� �������.
TrData: DIN r18, TrDataCountB
		cpi r18,0 
		BRNE TrComp ;   ���� �� ����� �������(��� ���������� ����������� ����
;c��� ��������� ��� �������� ������������ �����
		ldi r18,1
		DOUT TrDataCountB,r18
		ldi r18,0x40 ;������������� ����������� ����, ��������������� � �������� ������� ����
		DOUT TWDR,r18
		ldi r18,0b10000101 ; ���������� ��������
		DOUT TWCR,r18
		reti
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
		DIN r18,FlagCon
		ANDI r18, 0b10111111
		DOUT FlagCon,r18
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
			DIN r18,FlagCon
			ORI r18, 0b00000001 ;b[0] - ������������ ���� �������� ����� ����� ���� �����
			DOUT FlagCon,r18
			ret
;
;--------------------->>PosColRowSt<<-------------------------
; ��������� ������������ �������� ������� ������������ ������ ��� ���������� �����
PosColRowSt: ldi r18,3
			 DOUT SetPagStB,r18 ;���������  ������ (0-7)
			 ldi r18,3
			 DOUT SetPagEndB,r18 ; �������� ������ (0-7)
			 ldi r18,6 ; ��������� �������
			 DOUT SetColStB,r18
			 ldi r18,15 ; �������� �������
			 DOUT SetColEndB,r18
			 LDI XL,low(SetPagStB) ;������� ������� ���� ������, � ����������� ���� X
			 LDI  XH,high(SetPagStB)	;������� ������� ���� ������, � ����������� ���� X
			 DOUT XPosYkLOB,XL ; ��������� ��������� ����� ������� ����������������
			 DOUT XPosYkHiB,XH
;
			LDI XL,low(SetColStB)  ;���������� ������ ������ ��������� �������.
			LDI XH,high(SetColStB) ;����� � ���� ������ ������ ��� ����������
			DOUT XPosComLoB, XL
			DOUT XPosComHiB, XH
			ldi r18,10
			DOUT CleanSymB,r18  ;���������� �������� ������� ���� ��������
			DIN r18,FlagCon
			ORI r18,0b10000000
			DOUT FlagCon,r18 ;��������� ��� � ������ ����� ������ � ���
			ret
;
;------------------>>BufData<<------------------------------------
;��������� ������������ �������� ������ � �������� ���������� ��� ��������� ���������� �����
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
		  BREQ StartTR  ;������� ���� �����
		  DIN r18,TrDatLowB ;��������� ��������� ����� ������� �������� �� ������ � �������� ����������
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
		  ANDI r18,0b01111111 ;=�������� ���� ��������������� � �������� ������ �������� � ������ � ������.
		  DOUT FlagCon,r18
		  reti
		  
;===================����������============================================
;������������� r18,R20, ��������� ���� �� ����������
Eve_TWI :	DIN r18,TWSR ;������� ��� �������
			DIN r20,SREG ;��������� ������ ������� � �����
			push r20
;
			cpi r18,0x08 ;��������
			BRNE P0x08 ;������� ���� �� �����
;			
			;C��� ������� ���� ������� ������������ ��������� �����
Tr_Adr:		DIN r20,AdrSSD
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
			DIN r20,FlagCon
			ORI r20,0b00000001 ; ���������� ��� ��� � ��������� 
			DOUT FlagCon,r20  ;������������� ���� ��������
			pop r20
			DOUT SREG,r20
			ret ;++++
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
			DIN r20,FlagCon
			ORI r20,0b00000001 ;
			DOUT FlagCon,r20  ;������������� ���� �������� ������
			pop r20
			DOUT SREG,r20
			ret ;++++
;
P0x28 :		cpi r18,0x30
			BRNE P0x30
; ����� ���������� ��� ���� �������
/*
			;��� ������� ����� ������ ������������� �� �������
			DIN r20,FlagCon
			ANDI r20,1 ;���������� �� ���� �������� ���������������� ����?
			cpi r18,0
			BREQ  P0x10 ;��������� ���� 0 ;�������� ��� ������ ����� �� �������� ����� ������

			;���� ���� �� ���������� �������� ������ ����
			DIN r20,NumWhile ;��������� ������� ���������� ����.
			DEC r20
			DOUT NumWhile,r20
			;Z=R31:R30 ����������� ���� � ������� �������� ����� ���� ��� ��������
			SBIW R30:R31,1 ;�������� �� ��������� ������ � ������ �������� ����
			;������� �����
			DIN r20,FlagCon
			ORI r20,1 ; ���������� ��� ��� � ��������� 
			DOUT FlagCon,r20; �������� ���-�� ������ ���� �����
			pop r20
			DOUT SREG,r20
			ret ;++++
*/
;
P0x30 :		cpi r18,0x10
			BRNE P0x10
			;���� ������������ ��������� ��������
			rjmp Tr_Adr
;			
P0x10 :		pop r20
			DOUT SREG,r20
			reti
;==================================================================================
;r18 �19
;��������� ���� �� ���������� Int0 
;							;PD4 = S2 = D4 (����� ���������, ������ ��������)
;							 PD2 = S1 = D2 = INT0
Encoder_S1: DIN r18,SREG ;��������� ������ ������� � �����
			push r18
			DIN r18,PIND
			ANDI r18,(1<<PD4)
			cpi r18,0  ;��������� ��� � ���������� 
			BRNE One
			;���� ������� ���� = 0 ������ �����  ��������� �������
			DIN r18,CountEncoder
			ldi r19,0
			cp r19,r18  ;��� �������� ��� ��������
			BRLT NotNull;������� ���� ������ 
			ldi r18,4
			DOUT CountEncoder,r18 
			RJMP FlagInst  ;�������� ���� ��� ���������
NotNull:	dec r18
			DOUT CountEncoder,r18
			RJMP FlagInst  ; �������� ���� ��� ���������
; ���� ������� ���� ������ ������ ����������� �������
One:		DIN r18,CountEncoder
			cpi r18,4
			BRLT IncCount ;��������� ���� ������ 4
			;c��� ���� ������ ��� �����
			ldi r18,0
			DOUT CountEncoder,r18
			RJMP  FlagInst ; �������� ���� ��� ���������
IncCount:	inc r18
			DOUT CountEncoder,r18
FlagInst:	call PosColRowSt
			DIN r18,CountEncoder
			cpi r18,0
			BRNE CountNeNULL  ;���� �� ����� ���������
;C��� ��� ������� ���������
			ldi r19,0x1C
			;b[2] - ���� ���������������� ��������� ������
			;b[3] -  ���� ���������������� ��������� �������
			;b[4] - ���� ������� �������
			DOUT FlagConMas,r19
			JMP EndBufFlag
; CountEncoder==1?
CountNeNULL: cpi r18,1
			 BRNE CountNOne ;���� �� ����� ���������
			 ldi r19,0x5C
			 ;b[2] - ���� ���������������� ��������� ������
			 ;b[3] -  ���� ���������������� ��������� �������
			 ;b[4] - ���� ������� �������
			 ;���� �������� ������
			 DOUT FlagConMas,r19
			 LDI ZL,low(Text*2) ; ������� ������� ����� ������ �������� ������� ����� ��������
			 LDI  ZH,high(Text*2)
			 DOUT TrDatLowB,ZL    
			 DOUT TrDatHiB,ZH ;��������� ����� ������� �������� ������� ����� �������
			 JMP EndBufFlag
CountNOne:	 cpi r18,2
			 BRNE CountNTwo ;���� �� ����� ���������
			 ldi r19,0x5C
			 DOUT FlagConMas,r19
			 LDI ZL,low(Text1*2) ; ������� ������� ����� ������ �������� ������� ����� ��������
			 LDI ZH,high(Text1*2)
			 DOUT TrDatLowB,ZL    
			 DOUT TrDatHiB,ZH ;��������� ����� ������� �������� ������� ����� �������
			 JMP EndBufFlag
CountNTwo:	 cpi r18,3
			 BRNE CountNTree ;���� �� ����� ���������
			 ldi r19,0x5C
			 DOUT FlagConMas,r19
			 LDI ZL,low(Text2*2) ; ������� ������� ����� ������ �������� ������� ����� ��������
			 LDI ZH,high(Text2*2)
			 DOUT TrDatLowB,ZL    
			 DOUT TrDatHiB,ZH ;��������� ����� ������� �������� ������� ����� ������� 
			 JMP EndBufFlag
CountNTree:	 cpi r18,4
			 BRNE EndBufFlag ;���� �� ����� ���������
			 ldi r19,0x5C
			 DOUT FlagConMas,r19
			 LDI ZL,low(Text3*2) ; ������� ������� ����� ������ �������� ������� ����� ��������
			 LDI ZH,high(Text3*2)
			 DOUT TrDatLowB,ZL    
			 DOUT TrDatHiB,ZH ;��������� ����� ������� �������� ������� ����� ������� 
EndBufFlag:	 DIN r18,FlagCon
			 ANDI r18,0b01111110
			 cpi r18,0
			 BRNE EndBufFlag1 ;������� ���� �� ���� ����������� ��������� �����
;C��� ��� ������������ ����� � �������� ������� �������������
			LDI ZL,low(InitSSD*2) ; ������� ������� ���� ������, � ����������� ���� Z
			LDI  ZH,high(InitSSD*2)	; ������� ������� ���� ������, � ����������� ���� Z
			DOUT ZInitLow,ZL ; ��������� ��������� ����� ������� �������������.
			DOUT ZInitHi,ZH ;(��������� ��������� ����� �������������
			DIN r18,FlagCon
			ORI r18,0b00000010
			DOUT FlagCon,r18 ;������������ ���� ��������� �������������
			ldi r18,0b10100101 ;��������� ��������� ����� �� ���� TWI
			DOUT TWCR,r18
EndBufFlag1:  pop r18
			  DOUT SREG,r18
			  reti
;===========================================================	
;� PD4 = S2 = D4 (����� ���������, ������ ��������)
;  PD2 = S1 = D2 = INT0
;�������� ��������� � PD7
;==========================================================
;�������� ������� ����������
;
;EIFR � PCIFR ������� ������ ������� ����������
;PCIFR ��� ��������� ���������� �� ��������� ��������� �������	
;EIFR ��� ��������� ������� ������� ����������
;EIMSK ��� ����������/���������� "������� ������� ����������"
;PCICR ��� ����������/���������� �� ��������� ��������� �������
;
;EIMSK
;��� ���������� �������� ���������� Int0/Int1 � ���� Int0/Int1
;������������ 1. ������� ��������� ������������ ���������� �����
;ISC1 � ISC0 �������� EICRA
;EICRA
;ISCn1		ISCn0		�������
;	 0			0		�� ������� ������
;	 0			1		��������������� 
;	 1			0		�� ���������� ������ �� ������ INTn
;	 1			1		�� ������������ ������ 
;
;���� INTF0 ��������������� � 1 � ���������� ������� 
;�� ������ INT0 
;���� INTF0 c������ ��������� ���� ��������� ������ �����������
;�� ������� ������ �������
;
;PCIF0 ���� ���������� �� ��������� ��������� ������� 0-������
;���� � ���������� ������� �� ����� �� ������� PCINT0..7 �������������
;������ �� ���������� �� ���� ��� ��������������� � 1.
;====================================================================
;Call-used registers (r18-r27, r30-r31). ��������, ������������ ��� ������� �������.
; ����� ���� ������ ������������ gcc ��� ��������� ������ (����������). 
;�� �������� ������ �� ������������ � ������������� �� ����������, ��� ������������� 
;���������� � �������������� (�� ����� �� ��������� � ���� �������� push � ��������� 
;�� ����� �������� pop).
;=======================================================================
;������������
;����� Vin
;����� Gnd
;����� Rst
;������� D11
;���������� D12
;������ D13
;
;0x00 ��������� ������
		  S0: .db 0x03,0x0E,0x3C,0x64,0x34,0x1E,0x07,0x00			;�
		  S1:								;�
.org S1+4 S2: .db 1,2,3,4,5,6,7,8			;�
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
.org S15+4 S16:								;�
.org S16+4 S17:								;�
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
;128x32