/*
 * BatAD9833.h
 *
 * Created: 02.04.2022 21:03:03
 *  Author: dima
 */ 
//������� ������ ��������. (������ ���������)

#define BNOP() ( {\
	__asm__ volatile("nop\n\t" "nop\n\t" :::"memory");\
})

// ���������� 1 ���� �������� ��� ������
unsigned char SendMod(); //��������� �������� ����� ������ �� AD9833

unsigned char SendFreq(); //��������� �������� ������ ������� �� AD9833