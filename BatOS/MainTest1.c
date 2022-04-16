/*
 * MainTest1.c
 *
 * Created: 12.04.2022 14:05:40
 *  Author: dima
 */ 

#include "SetupBatOS.h"
#include "BatOS.h"

int main(){
	StartSPIAD9833();			//���������� spi �� ������ � AD9833
	
	SendFreqAD9833(500000); 	//������� �� ���������� ������� � ������ 500000�� 500���

	SendModAD9833(Trian);		//�������� ������
	/*
	Sin		0	//�������������� ������
	Trian	2	//�����������
	DAC		32	//������ � ����� ���
	DAC2    40	//������ � ����� ��� �������� �� 2
	*/
	SPIQueContrl(); //������ ����������� �������
	
	int i;
	while(1){
	i++;
	}
}
/*
;������������
;����� Vin
;����� Gnd
;����� Rst
;������� D11
;���������� D12
;������ D13

;AD9833
;D11=DAT
;D9 =FNC
;D13=CLK
;VCC=2.3-5V
;
;
;SPI
;MOSI=	D11=PB3
;SCK=	D13=PB5
;SS     PB1 --> D9  (16bit)
;PC0-5 = A0-A5 �����; PC0�������
*/