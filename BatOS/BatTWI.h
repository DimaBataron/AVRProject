/*
 * BatTWI.h
 *
 * Created: 15.01.2022 19:30:01
 * �������� ���������� �������� ��������� ��� ���-�� ��� ����� 
 * ������ �� ����� ������������ ��������� � �� ������� ������ ��������.
 *  Author: dima
 */ 
void SSisTWI();			//�������� �����
void StopSigTWI();		//�������� ����
void TrAdr(char Adr);   //�������� ������
void ConTWIPort();      //��������� ��� �� ��������
void TrByte(char Data); // �������� �����
char TrMasByte(char *MasData); //�������� ������� ����
