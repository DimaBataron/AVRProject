/*
 * DefFile4.inc
 *
 *  Created: 12.07.2021 20:17:43
 *   Author: dima
 */ 
 ;================����������=======================================
 ;� ���� ���� ��������� ���� ������� ����� ������� ��������� ���������
 ;������������ ��� ������������ ���������� ����� ������������� �� AD9833
 ;� ����� ��������� ����� �����.
 .def NumFrH = r14 ;<<<<<-------��� ��� �������� �� ������� ����� � ���������
 .def NumFrL = r15 ; (�����) ���������� �� ���� �����.
 ;��� �������� �������� �������� ��� ��������
;��� �������� ��������� ��� �������� �������� �� �������� 
;������� ���� ��������
.def CountEncoder = r19  ;���� ������� ����� ������� ������ <<<<<-------
.def Tmp2 = r21			; ���� ������ ��������� � �����(������� ������) <<<---------


;=====================���������=====================================
;������������� � ���������� ���������(��� �����������). 
;����� ������ �� ���������� ���������  ����� ��������


 .def Num1 = r9 ;����� ���� �������� �����
 .def Num2 = r10 ;������������ ��� ������ �� �����
 .def Num3 = r11
 .def Num4 = r12
 .def Num5 = r13
.def FisByte = r22		;����� ������������ � ������ ������
.def SecByte = r23 	    ;2
.def ThirByte= r24	    ;3
.def FourtByte=r25	    ;4


 ;==================���������==========================================
 ;������������ ������ � ������� ���������
.def Mn1   = r1 ;��������
.def Mn2   = r2
;������ ������������ 
.def VremenPrH = r3 ;��������� �������� ������ 1 ���������� �� ���������� ���������
.def VremenPrL = r4 ;��������� ���� �������

.def TmpAsH =	 r16 ;������� ������1 �� ���� �����
;.def TmpAsL =	 r17   ;��������
.def Quant=		 r17	; ������� ���� ������ � ������
;.def kol =		 r18	;��� ����� ��������� �������� ��� ����������
.def CE  =		 r18	;������ ��������� ��� ������� ������������ � ���������� ����������
.def OSRG =		 r20	;��������� �������� ������������� ���
.def FsMM		  = r26  ; ��� 4 �������� ������� ������  <<<<-----------------------
.def FsML		  = r27  ; � ����� ��������� ������ � ����� ��� ��������� 
.def FsLM         = r28	 ; ����������
.def FsLL         = r29	 ;������������� ��� ���������� �������� 
;������� ����� �������� � ��������� �������
;���������
.def Mng1      = r5  
.def Mng2      = r6
.def Mng3      = r7
.def Mng4      = r8


;=============================================================================
;��� ������ ������������� ������� ����� � ������� ��������. 
.equ TS_WordTr       = 0	;������ ���������. �� ����� ����
.equ TS_TwoWordTr    = 1    ;���� ������ ����� ����� ���������� � ������� 
.equ TS_StartInit    = 2    ;��������� ��������� �������������
.equ TS_TrData       = 3	;��������� �������� �������� �� �����
.equ TS_Clean		 = 4    ;��������� ������� �������
.equ TS_PosYkP       = 5	;��������� ���������������� ������
.equ TS_PosYkCol	 = 6	;��������� ���������������� �������
.equ TS_TrPointSym   = 7	;��������� ������ ������ ������� �� �����(���������)





;������ SPI �����
.DSEG
TaskQueue:
		.org TaskQueue+200 ; �������� � ��� ����� ��� ������� �������� � 200 ����.
MasByte: ;(������ �������)
		.org MasByte+600     ; �������� 600 ���� ��� ������ � ��� ��� ������ ������
CurrentByteL:  .db  1   ;����� �������� ����� ������ ��� ������
CurrentByteH:  .db  1  
;������ ����� ���� ������ � ���  
ReadDatL:    .db 1 ;����� �������� ������������� �����(������) ������ �� ������� ��������
ReadDatH:	 .db 1 ;
;
;������ ��������� ������
DcomH:		.db 1

;===========================================================================================
;������ TWI ����� ��� ������ �� �����
;StartInit
InitCount:		.byte 1	;������� ��������� �������������
LenMasInit:		.byte 1	;������ ������� �������������
NumWhileInit :	.byte 1	;���������� ���������� ����� �������� ������ �����
ZInitLow:		.byte 1 ;� ���� ������� r30. ��������� ���� ������� ����� ������� ������������� ��� ������ ��.
ZInitHi:		.byte 1 ;� ���� ������� r31. C������� ���� ������� ����� ������� ��� �������������.
AdrSSD:			.byte 1	;����� ��������

;TrData				������
;TrDataCountB		���� ���� ��� ����� �������� ����������� ���� (��� ������������� �������� ������� ��������)
;TrDataCount		���������� ���� ������ ������� ������� ��� ��������
;TrDatF				��� ������ ����� ���� ������ ������� ��� ������ �� ������ ���������.
;3 ������ ������� ��� ��������� ������������� ���������
TrDatLow:     .byte 1  ;r30. ��������� ���� ������� ����� ������� �������� ������� ���������
TrDatHi:      .byte 1  ;� ���� ������� r31. C������ ���� ������ ������� ��������
TrDataCount:  .byte 1  ;���������� ���� ������ ������� ������� ��� ��������
TrDataCountB: .byte 1  ;���� ���� ��� ����� �������� ����������� ���� (��� ������������� �������� ������� ��������)
TrSymByteL:   .byte 1  ;��������� �� ������ ������������� ����� ������ �������
TrSymByteH:   .byte 1  ;��������� �� ������ 
TrDatF:       .byte 1 

;Clean ������� �������
;r18 r19 r20
;CleanNow:              ��������� � ������ ������ ������
;CleanSym:              ���������� �������� ������� ���� ��������
;CleanWhile:  			��������� ���� � ������� ������
;CleanByte:				���� ������� ��������� ��� ������������.
;CleanFlag:				���� ����������� � ��� ��� ��� ������� � ��������� � ��� ���������� ���� x40 �� ����. �� ������ �������� ��� ������!!!
CleanNow:		.byte 1
CleanSym:       .byte 1
CleanWhile:     .byte 1
CleanByte:		.byte 1
CleanFlag:		.byte 1

;PosYkP	� PosYkCol			��������� ���������������� ������
;NumWhilePos		���������� ���������� ���� ����������������
;CountPosYk	        ������� ��������� ����������������.
;SelectPosYk		��������� ��� ����������� �����.
NumWhilePos:    .byte 1
CountPosYk:		.byte 1
SelectPosYk:	.byte 1 