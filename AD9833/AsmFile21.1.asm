/*
 * AsmFile21.asm
 *
 *  Created: 30.06.2021 9:31:59
 *   Author: dima
 *	��������� �������� ���� �� AD9833. ������� ������������� ���������� �������
	� ����������� �� ���� ����� ����� ���� ��������.
	��������� �������� � ����:
	-��������� ������������ ������� ����������.
	-������� �������� ���� �� SPI.
	-��������� �������� � ������� �� �������.
	������������ �������� �������� SPI � ����� ���������� ����������
	�� ���������� ������ �������.
 */ 
 
.include "F:/AVR/7.0/packs/atmel/ATmega_DFP/1.6.364/avrasm/inc/m328Pdef.inc"
.include "E:/A/AssemblerApplication1/AssemblerApplication1/Macro.inc"
.def OSRG = r20		;��������� �������� ������������� ���
.def Tmp2 = r21			; ���� ������ ��������� � �����(������� ������) <<<---------
.def FisByte = r22		;����� ������������ � ������ ������
.def SecByte = r23 	    ;2
.def ThirByte= r24	;3
.def FourtByte=r25	;4
.def CountEncoder = r19  ;���� ������� ����� ������� ������ <<<<<--------------------
.def CE           = r18	 ;������ ��������� ��� �������
.def Quant=	   r17	; ������� ���� ������ � ������
.def FsMM		  = r26  ; ��� 4 �������� ������� ������  <<<<-----------------------
.def FsML		  = r27  ; � ����� ��������� ������ � ����� ��� ��������� 
.def FsLM         = r28	 ; ����������
.def FsLL         = r29
;��� ������ ������������� ������� ����� � ������� ��������. 
.equ TS_WordTr       = 0	;������ ���������. �� ����� ����
.equ TS_TwoWordTr    = 1    ;���� ������ ����� ����� ���������� � ������� 

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
.ORG   INT_VECTORS_SIZE      	; ����� ������� ���������
;
.DSEG
TaskQueue:
		.org TaskQueue+200 ; �������� � ��� ����� ��� ������� �������� � 200 ����.
MasByte: ;(������ �������)
		.org MasByte+600     ; �������� 600 ���� ��� ������ � ��� ��� ������
CurrentByteL:  .db  1   ;����� �������� ����� ������ ��� ������
CurrentByteH:  .db  1  
;������ ����� ���� ������ � ���  
ReadDatL:    .db 1 ;����� �������� ������������� �����(������) ������ �� ������� ��������
ReadDatH:	 .db 1 ;
;
;������ ��������� ������
DcomH:		.db 1
.CSEG
; ��������������� ������� ���������� ������ ��������
TaskProcs: .dw WordTr            ; [00] 
           .dw TwoWordTr         ; [01] 
;��� ������ ��������� �������� ����� ������ ������� ���� � �urrentByte
;
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
ldi FisByte,0b00111111
out DDRC,FisByte ;����������� �������� ������ � 1(�����)
ldi FisByte,0b00000000
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
;;���������
;------------------>>WordTr<<-----------------------------------------
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
			ret



;--------------------->>>ShiftQue<<<--------------------------------
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


;------------------->>>QueData<<---------------------------
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
;----------------->>>>>OpMode<<<<------------------------------------------
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
;
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
		push Tmp2
		in Tmp2,SREG ; ��������� �������� ������
		push Tmp2;
		ldi ZL,low(TaskQueue+6)
		ldi ZH,high(TaskQueue+6) 
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
;������� ��� 
;==================================================================================================
;����������
;----------------------->>>InterSPI<<<----------------------------------------
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
; ------------------>>> Encoder <<<--------------------------------------------------
Encoder:		in FisByte, PIND
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
				out PORTC,CountEncoder
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
				out PORTC,CountEncoder
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
EnC10:			ldi CE,0x04
				jmp EnC11
EnC9:			cpi CE,0x04
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
			BREQ EnC16 ;��������� ��� ���������� �� 50���
;����������� �� 500���
		ldi FisByte,0b10110100
		ldi SecByte,0b11101010
		ldi ThirByte,0b01010001 
		ldi FourtByte,0x00
		add FsLL,FisByte
		adc FsLM,SecByte
		adc FsML,ThirByte
		adc FsMM,FourtByte
		rjmp EnC15
;��� ���������� �� 50���
EnC16:	ldi FisByte,0xF2
		ldi SecByte,0x8F
		clr ThirByte        
		clr FourtByte
		add FsLL,FisByte
		adc FsLM,SecByte
		adc FsML,ThirByte
		adc FsMM,FourtByte
;��������� �� ����� �� ���������� ����� �� �������
EnC15:	mov CE,FsMM
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
		mov CE,CountEncoder
		andi CE,0b00000010
		cpi CE,2
		BRNE EnC21
;��������� ���� ���� ��������� �� 1 ���
	ldi FisByte,0b11110001
	ldi SecByte,0b00101001
	ldi ThirByte,0x00
	ldi FourtByte,0x00
	sub FsLL,FisByte
	sbc FsLM,SecByte
	sbc FsML,ThirByte
	sbc FsMM,FourtByte 
	jmp EnC15
;�������� �� 50���
EnC21: 		mov CE,CountEncoder
			andi CE,0b00000100
			cpi CE,4
			BREQ EnC22 ;��������� ��� ���������� �� 50���
;��������� �� 500���
		ldi FisByte,0b10000101
		ldi SecByte,0b11101011
		ldi ThirByte,0b01010001
		ldi FourtByte,0x00
		sub FsLL,FisByte
		sbc FsLM,SecByte
		sbc FsML,ThirByte
		sbc FsMM,FourtByte
		jmp EnC15
;��������� �� 50���
EnC22:	ldi FisByte,0xF2          
		ldi SecByte,0x8F
		clr ThirByte
		clr FourtByte
		sub FsLL,FisByte
		sbc FsLM,SecByte
		sbc FsML,ThirByte
		sbc FsMM,FourtByte
		jmp EnC15
;C��� ����� ���� ���� ������ �������
EnC13:  ldi CE,0
		ldi CountEncoder,0
;------->>����� ������� ��� ��� ���� <<----------------
		out PORTC,CountEncoder
		reti ;���������� ���� ������������
;=========================================================================
;���������� ������� ������
PresEn:   mov CE,CountEncoder
		  andi CE,0b01100000
		  swap CE ; ����� ������� � ������� ����� �������
		  lsr CE  ; ������� ������ ������� ����� ����� ��������
		  inc CE  ; ���������� �� �������
		  cpi CE,2
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
		andi CountEncoder,0b10011111
		OR CountEncoder,CE
		call Encoder
		reti
;C��� ��������� �� ������� �������
PE1:	swap CE
		lsl CE
		ori CE,0b00000010
		andi CountEncoder,0b10011111
		OR CountEncoder,CE
		call Encoder
		reti
;������� ������� � ���� ������ ������
PE3: call OpMode ; �������� ������� ��������������� ���������� ������
	 ldi CountEncoder,0
	 ldi CE,0
	 ;������� ����� ������������
	 call Encoder
	 reti
;==================================================================================
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
