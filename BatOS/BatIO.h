/*
//BatIO.h
 *
Created: 15.01.2022 13:38:51
 Author: dima
 */ 
//s - ������
//c - ���� ������
//p - ��������� 
char BPrintf(char Mod, char *MasOut,char Str, char Col); //����� ������� ��������

void  QueuingSSDInit(); //��������� ���������� � ������� �������� ����������������� ���� �������
void QueuingCleanSSD(unsigned char CountSymb); //��������� ���������� � ������� ������� ������
void StartTWISSD1306(); // ��������� ��������� ��������� ������ TWI ��� ������ � ������� SSD1306
void QueuingOutPM(char *ProgMemor); //��������� ���������� ������ ����� �� ������ ��������