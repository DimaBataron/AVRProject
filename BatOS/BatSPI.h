/*
 * BatSPI.h
 * ������� ��� ����� � ������� SPI ���������������� Atmega328P
 * Created: 15.01.2022 14:20:41
 *  Author: dima
 */ 
//��������� ������ ��� ������ ������
#define DSPDR(a) (SPDR=a)
//��������� ��������� ��� �� ��������
void SPIConfigPort();
//��������� �������� �������� � ������ SPI
void SPIConfig(unsigned char SPCRB, unsigned char SPI2xS );
//��������� ������ ������ ��� �������� �� SPI ������� ��������
//void BSPDR(unsigned char DSPDR);

