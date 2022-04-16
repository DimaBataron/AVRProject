/*
 * SSD1306.c
 *
 * Created: 15.01.2022 20:37:19
 *  Author: dima
 * ��� ���-�� ����� �������� �� ���������� SSD1306
 ���� BatIO �� ������ �������������(�������� �����������).
 �������������� ��� ������������ ���� ��������.
 */
#include "SSD1306.h" 
#include "BatTWI.h"       // ��������� ������ ������ � TWI(I2P)
#include "SetupBatOS.h"
#include "avr\pgmspace.h" //���������� ��� ������ � ������� ��������

#ifdef SSD1306M
#define AdrSSD1306 0x78
/*
;SSD1306 �������� �����������.
;PC4=SDA=A4
;PC5=SCL=A5
;������������� ���������?
*/
//���������� ������� ������ � ���� �����
static char CountTWISym=0; //������������ ��� �������� ���������� ���������� ���� �������
static char CountSet=0;
unsigned char CountMasPos=0; // ����� �������� �������� ��� ������ �� ������� 
static char CountMasInit=0; //���������� �������� ����� �������� ������� �������������
static unsigned char CountClean=0; //��������� ������ � ������� ������
static char Flag=0; // ������������ ������ ��������� ��� �������� ���� �������������
//���������������� ���������.

extern unsigned char DataQueue[200];
extern unsigned char PoinQueRed;

extern unsigned char MasPosYk[40];  //������� 40 ���� � ��������� ��� ��������
//������ ���������������� ���������
extern unsigned char CountMasWr; //������� ������� ��� ������ � ������ ����������������

const char Num[][8] PROGMEM = { //����� ����� ��������.
	{0x1C,0x36,0x63,0x41,0x63,0x36,0x1C,0x00}, //0
	{0x00,0x10,0x31,0x7F,0x7F,0x01,0x00,0x00}, //1
	{0x00,0x63,0x67,0x4F,0x79,0x33,0x00,0x00}, //2
	{0x00,0x41,0x49,0x49,0x36,0x00,0x00,0x00}, //3
	{0x0C,0x1C,0x34,0x64,0x7F,0x04,0x00,0x00}, //4
	{0x00,0x73,0x71,0x5B,0x5F,0x4E,0x00,0x00}, //5
	{0x00,0x3E,0x7F,0x49,0x6F,0x66,0x00,0x00}, //6
	{0x00,0x60,0x67,0x4F,0x58,0x70,0x00,0x00}, //7
	{0x00,0x36,0x7F,0x49,0x49,0x7F,0x36,0x00}, //8
	{0x00,0x30,0x79,0x49,0x4B,0x7E,0x3E,0x00}  //9
	};
const char Symbol[][8] PROGMEM = { //����� ����� ��������
	{0x03,0x0E,0x3C,0x64,0x34,0x1E,0x07,0x00}, //�
	{0x41,0x7F,0x49,0x49,0x49,0x66,0x00,0x00}, //�
	{0x41,0x7F,0x49,0x49,0x49,0x36,0x00,0x00}, //�
	{0x41,0x7F,0x41,0x40,0x40,0x60,0x00,0x00}, //�
	{0,0,0,0,0,0,0,0},//�
	{0x41,0x7F,0x49,0x49,0x41,0x41,0x00,0x00}, //�
	{0,0,0,0,0,0,0,0},//�
	{0,0,0,0,0,0,0,0},//�
	{0x7F,0x03,0x07,0x18,0x30,0x7F,0x00,0x00}, //�
	{0x7F,0x03,0x8E,0x98,0x30,0x7F,0x00,0x00}, //�
	{0x41,0x7F,0x1C,0x36,0x63,0x41,0x00,0x00}, //�
	{0x01,0x41,0x7E,0x40,0x40,0x7F,0x40,0x00}, //�
	{0x7F,0x40,0x20,0x10,0x20,0x40,0x7F,0x00},//�
	{0x41,0x7F,0x49,0x08,0x49,0x7F,0x41,0x00},//�
	{0x1C,0x22,0x41,0x41,0x41,0x22,0x1C,0x00},//�
	{0x41,0x7F,0x41,0x40,0x41,0x7F,0x41,0x00},//�
	{0x41,0x7F,0x49,0x48,0x48,0x30,0x00,0x00},//�
	{0x1C,0x22,0x43,0x81,0x81,0x22,0x00,0x00},//�
	{0x40,0x40,0x40,0x7F,0x40,0x40,0x40,0x00},//�
	{0x40,0x61,0x33,0x1E,0x0C,0x78,0x60,0x00},//y
	{0,0,0,0,0,0,0,0},//�
	{0,0,0,0,0,0,0,0},//�
	{0x40,0x7E,0x02,0x02,0x02,0x7E,0x43,0x00},//�
	{0x40,0x78,0x08,0x08,0x08,0x7F,0x41,0x00},//�
	{0x7F,0x01,0x01,0x7F,0x01,0x01,0x7F,0x00},//�
	{0,0,0,0,0,0,0,0},//�
	{0,0,0,0,0,0,0,0},//�
	{0x7F,0x11,0x11,0x1F,0x00,0x7F,0x00,0x00},//�
	{0x00,0x7F,0x1B,0x11,0x1B,0x0E,0x00,0x00},//�
	{0,0,0,0,0,0,0,0},//�
	{0,0,0,0,0,0,0,0},//�
	{0x00,0x01,0x71,0x4E,0x48,0x7F,0x41,0x00},//�	
	};

/*
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
*/
const char InitSSD[] PROGMEM = {0xA8,0x00,0xD3,0x00,0x40,0xA1,0xC0,
	0xDA,0x12,0x81,0xFF,0xA4,0xA6,0xD5,0x80,0x8D,0x14,0x20,0x00,0xAF}; //20 ����
	
const char Point[] PROGMEM = {0x00,0x7F,0x7F,0x7F,0x3E,0x1C,0x08,0x00}; // ����� ��������� (���������)

/*��������� ������ �������
(���������� ��������)
//�������� ��� ������� � �������� ��������.
//�������� ������ � ����� ��������� ���������	
//��������� ������� ������. �� ����� ��� �������.
//���������� 1 ���� ��� �� ��� ��������
//			 0 ��� ��������
*/
char PrintSym(unsigned char CharCode){ 
    char symbol=0; //� ��� ���������� ������� ����� ������� �����
	if (CountTWISym==8) //������ ��������
	{
		CountTWISym=0;
		return 0; 
	}
	else{ //�������� �������������� ���� ������ ��� �������� ��������.
		if(CharCode==' '){ // ������
			TrByte(0); // ������� 8 ��� ������
		}
		else{
			if( CharCode < (unsigned char)0x3A){ //�������� ��� �����
			symbol = (CharCode-'0');
			TrByte(pgm_read_byte(&Num[symbol][CountTWISym])); // ���������� ���� ���� �������
			}
			else{//����� ��� ��� �������
			symbol = (CharCode-'�');
			TrByte(pgm_read_byte(&Symbol[symbol][CountTWISym]));//�������� ��� � �������� ��������
			}
		}
		CountTWISym++;
		return 1;
	}
}

/*
�������� ��������� ��������� ������, �������
*/
/*
��������� ��������� ������ 
1.��������� ��������� �������
2.���������� ����������� ���� 
3.�������� ����� ������ 
4.�������� ����� �����.
5.���������� 1 ���� �������� ��� �� ��������. 0 ���� ���.
*/
//����� ������� �������� � ������ ��������� � ������� ������ �� 0-7
//�������� ��� ������ ����� ���� ��� �������� ������
char SetLine(){
	 if(CountSet==0){
			TrByte(0x00);
		}
		else{
			if(CountSet==1){ //����������� ���� ��������
				//������ ���� �������
				TrByte(0x22);// �������� �������� ������ ���� ���� �������?
			}
			else {
				if(CountSet<4){//�������� 2 ����� ��������� � �������� ������ ��� ������
					TrByte(MasPosYk[CountMasPos++]);					
				}
				else { //��� �������� �������
					CountSet=0;
					return 0;
				}
			}
		}
		CountSet++;
		return 1;
}

/*
��������� ��������� ������� ��� ������ (���������� �����, ��� ������ �� ������ 8 ����)
16 ��������
��������� �� ���� ����� �� 0 �� 16.
5.���������� 1 ���� �������� ��� �� ��������. 0 ���� ���.
*/
char SetColomn(){
	unsigned char OutColom;
	if(CountSet==0){
			TrByte(0x00);
		}
		else{ 
		if(CountSet==1){ //����������� ���� ��������
				//������ ���� �������
				TrByte(0x21);// ;Set Column Address
				}
			else { 
				if(CountSet<4){//�������� 2 ����� ��������� � �������� ������ ��� ������
				OutColom = MasPosYk[CountMasPos++];
				OutColom = OutColom<<3; // ����� �� 3 ������� ���������� ��������� �� 8
				if(OutColom==120){ OutColom=127 ;}
				TrByte(OutColom);
				}
				else { //��� �������� �������
					CountSet=0;
					return 0;
				}
			}
		}
		CountSet++;
		return 1;	
}


//��������� ���������� ����� �������� SSD1306(��������)
//������������ ����� ������� ������ � ������� 
//���������� �������� �� ������� �����. ���������� ����� �������������
//� ������� ������
//��������� 1 ���� ����������� ��� �� ��������
char SSDInit(){
	if(CountMasInit==20)
		{
			CountMasInit=0 ; // ����� ������??
			return 0 ;
		}
	if(Flag == 0){ // �������� ��������
		Flag++;
		SSisTWI(); // ����� �������� ��������� ������� ���� ���������� �����
	}
	else{
		if(Flag == 1){ // ���������� ����������� ���� 0x00. ������� ��� ����� ����� �������
			Flag++;
			TrByte(0x00);
		}
		else {
			Flag = 0;
			TrByte(pgm_read_byte(&InitSSD[CountMasInit++])) ; //�������� ���� �������������
			return 1 ;
		}
	}
	
}


//��������� ������� ������
//(������� ������� 128 ��� ��� ������� ����� �������)
//CountSymb ���������� ��������� ��������
char CleanSSD(unsigned char CountSymb){
	char c;
	if(CountClean == 0){
		TrByte(0x40); // �������� ������� ������� ��������� ��� ������ �������� ������ ������
		CountClean++;
		return 1;
	}
	if(CountClean<(CountSymb+1)){
		c = PrintSym(' ');
		if(c==1){
			return 1; //�������� �� ���������, ���������
		}
		else CountClean++;
		return 1;
	}
	else {
		CountClean=0;
		return 0;    //�������� ��������.
	}
}


//��������� �������� ������� �������� �� �����
//�������� �� ���� ����� ������� �������� ���������� ������.
//���������� 1 ���� �������� �� ���������
char SSDTrMasByte(char *MasData){
	if(CountMasInit==0){ //��� ���������� ����� 0 ���� ����������� ���� ��� �� ��������
		TrByte(0x40);// ����������� ���� ��������� ���������� SSD1306 ��� ������ �������� ������ ����.
		CountMasInit++;
		return 1; //�������� ��� �� ���������
	}
	else{ //����������� ���� �������
		if(CountMasInit==1){
			char CharCode;
			char c;
			CharCode= MasData[CountSet]; // �������� ������
			if(CharCode!=0){ // �� ����� �������
				c = PrintSym(CharCode); //��������� �� ����� �������� ������� ���� �������
				if(c==0){//�������� ����� ������� ���������.
				CountSet++; // ��� ��������� ������ ������� ��������� ������.
				return 1;
				}
			}
			else{ //����� ������� ���� ������� ������ ��������
				CountSet = 0;
				CountMasInit = 0;
				return 0;
			}
			
		}
	}
}

// ��������� ������� ���� ������. ���������� 1 ���� �������� �� ���������
char PrintChar(){
	if(CountMasInit==0){ //��� ���������� ����� 0 ���� ����������� ���� ��� �� ��������
		TrByte(0x40);// ����������� ���� ��������� ���������� SSD1306 ��� ������ �������� ������ ����.
		CountMasInit++;
		return 1; //�������� ��� �� ���������
	}
	else{ //����������� ���� �������
		if(CountMasInit==1){
			char CharCode;
			char c;
			CharCode= DataQueue[PoinQueRed]; // �������� ������
			c = PrintSym(CharCode); //��������� �� ����� �������� ������� ���� �������
			if(c==0){//�������� ����� ������� ���������.
					PoinQueRed++; // ��� ��������� ������ ������� ��������� ������.
					CountMasInit = 0;
					return 0;
			}
		}
	}
}

//����� ������ ������� �� ������ �������� �� ����� (8����)
//1 ���� �������� �� ���������
char OutPMem(){
	unsigned char *Adr;
	if(CountMasInit==8){
		Flag = 0;
		PoinQueRed++;
		PoinQueRed++;
		CountMasInit=0;
		return 0; // �������� ���������
	}
	if(Flag==0){
		TrByte(0x40);// ����������� ���� ��������� ���������� SSD1306 ��� ������ �������� ������ ����.
		Flag++;
		return 1;
	}
	Adr = DataQueue[PoinQueRed] << 8;
	Adr =  ((int)Adr) | (((int)DataQueue[PoinQueRed+1]) & 0b0000000011111111);
	TrByte(pgm_read_byte(&Adr[CountMasInit++])) ; //�������� ���� �������������
	return 1;
}

//����� �� ����� �����.
//1. �� ������ ������ �������� �����
//2. �� ����� ����� ������� �� ����� ������� �� ������ ��������
//1 ���� �������� �� ���������
char PrintNum(){
	unsigned char symbol;
	if(CountMasInit==0){ //��� ���������� ����� 0 ���� ����������� ���� ��� �� ��������
		TrByte(0x40);// ����������� ���� ��������� ���������� SSD1306 ��� ������ �������� ������ ����.
		CountMasInit++;
		return 1; //�������� ��� �� ���������
	}
	else{
		if(CountMasInit<6){
			if(CountTWISym<8){ //���������� ����� ������� �� �����
					symbol = DataQueue[PoinQueRed+(5-CountMasInit)];
					TrByte(pgm_read_byte(&Num[symbol][CountTWISym])); // ���������� ���� ���� �������
					CountTWISym++;
					return 1;
					}
			else{
				CountTWISym=0;
				CountMasInit++;
				return 1;
			}
		}
		else {
			CountMasInit=0;
			CountTWISym=0;
			PoinQueRed +=5;
			return 0 ;
		}
	}
}
#endif