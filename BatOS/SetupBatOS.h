/*
 * SetupBatOS.h
 *
 * Created: 12.04.2022 12:25:16
 *  Author: dima
 * ����������� �������� ���������� ���������� ������.
 * �� ������������ ��� �� ���������� � �������� ��������� ��� �������� ����� �� Flash ������
 */ 


#ifndef SETUPBATOS_H_
#define SETUPBATOS_H_
// AD9833
#define BatSPIM // �������� ��� �������������� ������� SPI
#define AD9833M // ��� ������������� ���������� ���������� �������
#define SPILenTaskMas 2 // ������ ������� � �������� �������� �� �������� �� SPI

#define Sin		0	//�������������� ������
#define Trian	2	//�����������
#define DAC		40	//������ � ����� ��� �������� �� 2
#define DAC2    32	//������ � ����� ���

//TWI
//#define BatTWIM // ��� ������������� ������� TWI
//#define SSD1306M  //��� ��������� ������

//ENCODER & TIME
//#define EncoderM // ����������� ��������
//#define BatTimeM // ��� ������������� �������
#endif /* SETUPBATOS_H_ */