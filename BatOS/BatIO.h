/*
 *
 * Created: 15.01.2022 13:38:51
 * Author: dima
 */ 

//p - ���������     s - ������      c - ���� ������      d-5�� ������� �����< 65535
#ifndef BATIO_H_
char BPrintf(char Mod, char *MasOut  ,char Str, char Col); //����� ������� �������� char *MasOut 

void  QueuingSSDInit(); //��������� ���������� � ������� �������� ����������������� ���� �������
void QueuingCleanSSD(unsigned char CountSymb); //��������� ���������� � ������� ������� ������
void StartTWISSD1306(); // ��������� ��������� ��������� ������ TWI ��� ������ � ������� SSD1306
void QueuingOutPM(char *ProgMemor,char Str, char Col); //��������� ���������� ������ ����� �� ������ ��������
void StartLC(); //��������� ��������� ��������� � ������
void StartSPIAD9833(); //��������� ��������� ��������� ������ SPI �� ������
void SendFreqAD9833(unsigned long int Dec); // ��������� ���������� � ������� �������� ������� �� AD9833
void SendModAD9833(unsigned char Mod);// �������� ������ �� ���������� AD9833
#endif
