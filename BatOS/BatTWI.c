/*
 * BatTWI.c
 *
 * Created: 15.01.2022 19:29:44
 *  Author: dima
 */ 
#include "BatTWI.h"
#include "SetupBatOS.h"
#include <avr/io.h> //�������� ���� ��������� � ������ �����������

#ifdef BatTWIM
char CountTrMasByte = 0; // ���������� �������� ���������� ��� ���������� ����

//�������� ��������� ��������� �������� 
//��������� ������
void SSisTWI(){
	TWCR = 0b10100101; //��������� ��������� �����
}

//������ ��������� ��������
void StopSigTWI(){
	TWCR = 0b10010101; //������������ ��������� ���� �� ���� TWI
}

//�������� ������ ����������
void TrAdr(char Adr){
	TWDR = Adr;
	TWCR = 0b10000101; //����� �������� ��������� ������
}

//��������� ��� �� �������� � ����� �� TWI
void ConTWIPort(){
		DDRC |= 0b00110000; //����������� �������� ������ 1 �����
		PORTC |=0b00110000; //��������� ���� � 1.
}
//�������� �����
void TrByte(char Data){
	TWDR = Data;
	TWCR = 0b10000101; //���������� ��������
}

//�������� ������� ���� (���������� ��������)
// MasData ������ ����
// NumberSym ���������� ������������ ����
// ���������� 1 ����� �������� ����������, 0 ����� ���.
// �� ����� ������ �.�. �� ������������ �����������
char TrMasByte(char *MasData){
	char Sym = MasData[CountTrMasByte];
	if(Sym ==0)
	{
		CountTrMasByte=0;
		return 1;	
	}
	else{
		TrByte(Sym);
		CountTrMasByte++;
		return 0;
	}
}
#endif