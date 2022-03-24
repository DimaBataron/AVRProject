/*
 * Encoder.c
 *
 * Created: 16.03.2022 2:27:12
 *  Author: dima
 ���� �������� ��������� ��� ������ � ���������
 */ 
#include "Encoder.h"
#include "BatTime.h"
#include <avr/io.h> //�������� ���� ��������� � ������ �����������
//#include <stdatomic.h> // ���������� ���������� ������� ���������� �� ����������
//#include "iom328p.h"

//0 ���� ���� �������
//1 ������ �������
//-1 ����� �������
//2 ���������� �������
//4 �� ���� ���������
volatile int ConditionEncoder = -1; // ��������� ��������� ��������� ��������

unsigned char Wait=0;  // ������������ ��� ������������ ���������.
unsigned char sec = 0; // ������������ ��� ������� �������.


//��������� �������� ������ �� ��������� ��������� �������� ��� �������� ��������� �� ���������� 
void EncoderRet(){
	unsigned char c;
	c = PIND & (1<<PIND4);
	if(c==0){ //��������� �����
		ConditionEncoder =-1;
	}
	else ConditionEncoder =1; //������
}

//��������� ������������ �������.
//�� ������� �������� ������. ���� ������� ���������� 2. ���� �������� 0.
//��������� ���� ����� ���������� ������� ������ ������ ������ ���������� ������ 
//�� ��������� �������� ����� ���������� ���������
void EncoderPres(){
	unsigned char c=0;
	if(Wait==0){ // ������� �������
		Wait=1; // �������� ��������
		sec = 5;
		ConfTime0();//������� ������
		return 0; 
	}
	if(Wait==1){ // �������� �� �������� �������
		if(sec>0){//��������� �������(�������) ������ �� ������
			return 0;
		}
		else{ // �������� ���� 	Int1=PD3=Key=D3(������ ��������)
			c = PIND & (1<<PIND3);
			if(c==0){ // ������������. �������� ��� ���������� ������� ��� ��������?
				Wait = 2;
				sec = 5; // ����� ���� ���������
				return 0;
			}
			else{ // ���� �������� ������� 
				Wait = 0; // ��������� ������ �� �������
				ConditionEncoder = 0; //��������� ��� �������� �������
				TimeOff(); // �������� ������
				return 0 ;
			}
			
		}
	}
	if(Wait == 2){ 
		if(sec>0){//��������� �������(�������) ������ �� ������
			return 0;
		}
		else{ //�������  �������� ���� 	Int1=PD3=Key=D3(������ ��������)
			c = PIND & (1<<PIND3);
			if(c==0){ // ������ ���������� �������
				Wait = 0;
				ConditionEncoder=2;
			}
			else {
				Wait = 0;
				ConditionEncoder=0; // �������� �������
			}
		}
	}
	TimeOff();
	return 0; // ���� ������ �������� �� ������
}

//��������� ������������ ����� Atmega328p ��� ������ � ���������
void GetSygEn(){
	/*
	;�������
	;Int0=PD2=S1=D2
	;Int1=PD3=Key=D3 ������� ���� �������
	;PD4     =S2=D4
	*/
//��������� ��� �� ���� � ����������� ������������� ����������
	DDRD  &= ~((1<<DDD2)|(1<<DDD3)|(1<<DDD4)); /// ����������� �������� ������
	PORTD &= ~((1<<PORTD2)|(1<<PORTD3)|(1<<PORTD4)); // ������������� ��������   
	//PORTD |= (1<<PORTD4);
//��������� ��������� ���������� �� ���������� ������
	EICRA &= ~((1<<ISC10)|(1<<ISC00)|(1<<ISC11)|(1<<ISC01));		//��������� ����
	EICRA |=  (1<<ISC11)|(1<<ISC01); //�� ���������� ������ �� ������ INT0 � INT1
//���������� ���������� 
	EIMSK = (1<<INT0)|(1<<INT1); 
}