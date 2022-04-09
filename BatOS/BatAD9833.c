/*
 * BatAD9833.c
 *
 * ��� ��� ���������� ������� AD9833
 * Created: 02.04.2022 20:51:55
 *  Author: dima
 * ����� ��������� ���������� �������������� �� BatOS. ������������ ��� �������� ���� ���������� �� ����������
 * AD9833 �� SPI
 */ 
#include "BatAD9833.h"
#include "BatSPI.h"
#include <avr/io.h>

unsigned char CountFreq=0; //���������� �������� ��������� ���������� �������� ����.
unsigned char Mod=0; // ���������� ���������� �������� ��������� ��������� ������ ������� ���� ���������� 

unsigned char SPIQue[100]; // ������� ��� ������ SPI ������������ � BatOS.
unsigned char ReadQueSPI=0; // ���������� ������ ����� �������� ��� ������ �� ������� ��������
unsigned char WriteQueSPI=0; // ���������� ������ ����� �������� ��� ������ �� ������� ��������
//� ���������� AD9833

//��������� �������� ������ ������� �� AD9833
//���������� 1 ���� �������� ��� ������
unsigned char SendFreq(){
	if(CountFreq<2){//����� �������
		if(CountFreq==0){ //�������� ������� ���� �������
			PORTB &=~(1<<PORTB1); //�������� ���� � 0 ��� ���� ����� ���������� AD9833 ������ �����
			DSPDR(0b00100001);
			CountFreq++;
			return 1;
		}
		else {//�������� ������� ���� �������
			DSPDR(0b00000000 | Mod);
			CountFreq++;
			return 1;
		}
	}
	else {
		if(CountFreq==2){//������� �������� �� ���� ��� ���� �����
			PORTB |=(1<<PORTB1); // ������ ��� ������ ����� 2 �����
			BNOP(); //�������� ���� � ���
			PORTB &= ~(1<<PORTB1);
			BNOP();
			DSPDR(SPIQue[ReadQueSPI+(4-CountFreq)]); //������ ������ ���� �������
			CountFreq++;
			return 1;
		}
		if(CountFreq<4){
			DSPDR(SPIQue[ReadQueSPI+(4-CountFreq)]); //������ ������ ���� �������
			CountFreq++;
			return 1;
		}
		if(CountFreq<6){
			DSPDR(SPIQue[ReadQueSPI+(8-CountFreq)]); //������ ������ ���� �������
			CountFreq++;
			return 1;
		}
		else {
			if(CountFreq<8){ //��� �� ��� ��������
				if(CountFreq==6){// ������ ��������, �������� ������� �� ���������
					PORTB |=(1<<PORTB1); // �������� ���� � 1 ������������ ��� ����� 
					//������� ��������
					BNOP();
					PORTB &= ~(1<<PORTB1); //�������� ���� � 0 ��� ���� ����� ���������� AD9833 ������ �����
					BNOP();
					DSPDR(0b00000000);
					CountFreq++;
					return 1;
				}
				if(CountFreq==7){ //������ ����� ���������� �����
					DSPDR(0b00000000 | Mod);
					CountFreq++;
					return 1;
				}
				else { // ������� ����� �������
					DSPDR(SPIQue[ReadQueSPI+(6-CountFreq)]);
					CountFreq++;
					return 1;
					}
				}
				// �������� ���������
				CountFreq=0;
				PORTB |=(1<<PORTB1);
				return 0;
			}
		}		
}

//��������� �������� ����� ������ �� AD9833
// ���������� 1 ���� �������� ��� ������
unsigned char SendMod(){
	if(CountFreq<2){
		if(CountFreq==0){ //1 ������� ���� �������
		  PORTB &= ~(1<<PORTB1); //�������� ���� � 0 ��� ���� ����� ���������� AD9833 ������ �����
		  Mod=SPIQue[ReadQueSPI+1];
		  DSPDR(0b00000000);
		  CountFreq++;
		  return 1;
		}
		DSPDR(Mod); // 2� ������� ���� �������
		CountFreq++;
		return 1;
	}
	CountFreq=0;// ������� ��������� ������ ��������
	PORTB |=(1<<PORTB1); // �������� ���� � 1 ������ �������� ���������
	//ReadQueSPI +=2;
	return 0;
}