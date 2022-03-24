
/*
 * BatikoOS.c
 *
 * Created: 08.01.2022 6:44:10
 * Author : dima
 //������������ ��������� �������� ��������� ��� ���������� � ������ ������ ����, ����������� �������
 //������������� ����������� ������ ���������. � ������ ����������� �������
 ��� �������� �����
 //��������� ������ ������ �������. �����( ��� �������� ������ �������)
 
 //��������� ���������� ����������� ������ ��� ������������ ��������
 // ���� �������� ������������ ������� ����� ���� ����������.
 // � ������� �� �������� ����� ���� � ����������� ���������� ������?
 // ������� ���� ����������
 // Timer 0 �� ���� �� ������ PD4 ����� ���� ���� � ����
 */ 
//#include "BatOS.h"
#include "BatIO.h"
//#include <stdatomic.h> // ��������� ���� ��� �����������. ����� ���������� �� ������ �.�. ������������ �
// ����������
//#include <iom328p.h>
//#include "F:\AVR\7.0\toolchain\avr8\avr8-gnu-toolchain\avr\include\util\atomic.h"

extern volatile signed char ConditionEncoder; // ������ �� ���������� ����������
static signed char Nesting = 0; //�����������
static signed char PointMenu = 0; // �������� ��������
static signed char OldNest =-1;   // ������ ��������� ��������� menu
static unsigned char OldPoinMenu=0;
static signed char CounFStep=0;	// ����� ��������� 9 ��������

static volatile unsigned long  FStep=0;		// �������� ���� ��������� ������� �������
static volatile unsigned int  GenFreq=0; // ������� ������� ��������� ��������� �� �����
static volatile unsigned long OutFreq=0; // ����� ������� ���������� � ���������� unsigned
static volatile unsigned long Mng=0; // ��������� ��� ���������� 
	
	char f[]="����";
	char mod[]="����";
	char step[]="���";
	char Gz[]="�� ";
	char kGz[]="���";
	char Mgz[]="���";
	char si[]="���";
	char tr[]="�����";
	
// �������� ��������� ��������� �������� TWI
int main(void)
{
	//SPIConfig(0,0b11111001);
	// ��������� ��������� ���������� ����� � �������,  ����� ������� �������.

	StartTWISSD1306(); //������������ ������ �� ��������
	GetSygEn(); //��������� ������������� ���������� �� ��������
	QueControl(); // �������� ��������� �������
 /*
	ATOMIC_BLOCK(ATOMIC_RESTORESTATE) //��������� ���� ATOMIC_RESTORESTATE ��� ������ ���������� ���� ����������
	// �� ��� ������� ��� �� ���������� ����������
	{
		BPrintf('d',12345,4,5); // ���������� � ������� ����� �����.
		BPrintf('p',0,2,1); // p ������ ����� ��������� ������� ������ ���������
		BPrintf('s',f,2,3);   // � ������� ����� ������ (������ ������ ���� � ���)
		BPrintf('c','�',3,4); // � ������� ����� �������
	}
*/
	
//�������� ��������� ��������� ������������� ������ 0xFF?? � ���� ��??

while (1)  // ������ ���� // ��� ����� �������� � ���������� �� �������
    {
		
		if(ConditionEncoder<4) {
			MainMenu();
		}

    }
}
//��������� ������� ����������� � �������
//��� ��������� ����������� ���������������� ����.
//��� �������� ���������������� ���������

//0 ����������� (�������  �����) 

//1 ����������� (���) (����� ������� �� 5, 20, 50, 200, 1000, 5000�� 
// 50���, 200��, 1���)
// ��� �������� ������� �������� ��� 2 ������. ��� ���������� ����� � 0 �����������

//2 ����������� (�����).�������� ������� ����� ������ � ������� � ����������� 1.
//���������� ������� ����� � ����������� 0

void MainMenu(){
	unsigned char Str;
//===========================================================================================
					//  ------>>>>>������<<<<<--------
	if(OldNest==-1){ // �������������� ������
		//����� ����������� 0;
		OldNest=0;
		BPrintf('s',f,3,3); // ����� ������ �������;
		BPrintf('s',mod,5,3); //����� ������ ������
		BPrintf('p',0,5,2); // ����� ���������
		PointMenu = 0;		// �������� ��� ����� ��������� � 0 �������.
		Nesting = 0;
		ConditionEncoder=4;
		QueControl();
		return 0 ;
	}
//=========================================================================================
	//				��������� ���������
	OldNest = Nesting;
	switch(ConditionEncoder){
		case 0: // �������� ������� �����
		Nesting++;
		ConditionEncoder=4;
		break;
			
		case 1: // ������ �������
		PointMenu++;
		ConditionEncoder=4;
		break;
		
		case -1: //����� �������
		PointMenu--;
		ConditionEncoder=4;
		break;
		
		case 2: // ���������� ������� ����� ������
		Nesting--;
		ConditionEncoder=4;
		break;
	}
	if(Nesting<0){
		 Nesting=0;
	}	
//===========================================================================================
	// ����������� 0
	if(Nesting==0){ //����������� 0
		if(PointMenu>1){ // ��������� �� ���������
			PointMenu=0;
		}
		else {
			if(PointMenu<0) PointMenu=1;
		}
		if(OldNest==Nesting){ //������� �� ���� ��� �������. �������������� ���� �� ���� ������ ���������
			if(PointMenu==0){
				BPrintf('p',0,5,2); // ����� ��������� ����� � ������� ������
			}
			else{
				BPrintf('p',0,3,2); // ����� ��������� ����� � ������� �������
			}
			QueControl();
			return 0;
		}
		else{ // ������� � ��� ��������
			StartLC();
			QueuingCleanSSD(128);
			BPrintf('s',f,3,3); // ����� ������ �������;
			BPrintf('s',mod,5,3); //����� ������ ������
			BPrintf('p',0,5,2); // ����� ���������
			PointMenu = 0;		// �������� ��� ����� ��������� � 0 �������.
			if(OldNest!=1) Nesting =2;
			QueControl();
		}
		return 0;
	}
	if(OldNest==0){ //������� �������� ������� � ���� ����������� 1;
		StartLC();
		QueuingCleanSSD(128);
		if(PointMenu==0){//������� � ����� ������ ������
		// ���� ����� ������� ��-������
			BPrintf('s',si,5,3); //� �.�.
			BPrintf('s',tr,4,3);
			BPrintf('p',0,5,2); //����� ��������� � ������
		}
		else{ //����� ������ ������� ��������� ��� �� ������������
			BPrintf('s',step,5,3); //����� ���
			BPrintf('d',00000,4,3); // ����� ���������� ��� � ���� �� ������ ������� ��������� ����
			BPrintf('s',f,3,3);  // �����  ����
			BPrintf('d',00000,2,3);// ��������� ��������� ������� � ���
			BPrintf('s',kGz,2,8); //������ ����� ���������
			Nesting = 2;
		}
		QueControl();
	}
	//===================================================================================
	//------>>>����������� 1<<<------ (����� ������)
	if(Nesting==1){ //������ ����� ����� ���� ��� ������(�������������� ���������)
		//� ���� ������ ������ 4 ������.
		if(OldNest==Nesting){ //������� ��������
			if(PointMenu<0){
				PointMenu=3;
			}
			if(PointMenu>3){
				PointMenu=0;
			}
			Str = 5-PointMenu;
			BPrintf('p',0,Str,2);
			QueControl();
			return 0;
		}
		if(OldNest==2){//���������� ������� � ����������� 2. //������� �������� ���� ����������� 0
			ConditionEncoder=2;
			//����� ��������?
			return 0;
		}
	}
//==================================================================================
//                    --->>>B���������� 2<<<--
	if(Nesting==2){
		if(OldNest==1){ //
			StartLC();
			QueuingCleanSSD(128);
			BPrintf('s',step,5,3); //����� ���
			BPrintf('d',00000,4,3); // ����� ���������� ��� � ���� �� ������ ������� ��������� ����
			BPrintf('s',f,3,3);  // �����  ����
			BPrintf('d',00000,2,3);// ��������� ��������� ������� � ���
			BPrintf('s',kGz,2,8);
			PointMenu = 0;
			QueControl();
			return 0;
		}
		if((OldNest==2)||(OldNest==4)){ //������� ��������
			if(PointMenu>1) PointMenu =0;
			if(PointMenu<0) PointMenu =1;
			if(PointMenu==1){ 
				BPrintf('p',0,3,1); // ����� ����
				OldPoinMenu =1;
			}
			else{
				 BPrintf('p',0,5,1); //����� ���
				 OldPoinMenu =0;
			}
			QueControl();
		}
		if(OldNest==3){//����� ������� � ��������� �������
			PointMenu = 0;
			BPrintf('p',0,5,1); //����� ���
			OldPoinMenu = 0;
			QueControl();
		}
	return 0;
	}
	// ����� ����� ������� OldNest=2; ������ �� ������. ��� ������ ���� ���������
	if(Nesting==3){//������� � ���� ������ �������(����������� 2
		if(OldNest==3){ // ������� ����� ���� ��� ������������� ���������
			//��������� �� ������������ ������
			if(PointMenu<0) PointMenu =0;
			if(PointMenu>1) PointMenu =1;
			if(OldPoinMenu==0){ // �������� ���
				if(PointMenu==0) CounFStep--;//������ �����(���������)
				if(PointMenu==1) CounFStep++; //������ ������(�����������)
				if(CounFStep<0) CounFStep=8; // � ����������� �� ����� ���� ������� ���������
				if(CounFStep>8) CounFStep=0;	
				switch(CounFStep){
					//1 ����������� (���) (����� ������� �� 5, 20, 50, 200, 1000, 5000�� 50���, 200��, 1���)
					case 0:		FStep=5;
					break;
					case 1:		FStep=20;
					break;
					case 2:		FStep=50;
					break;
					case 3:		FStep=200;
					break;
					case 4:		FStep=1000;
					break;
					case 5:		FStep=5000; // ��
					break;
					case 6:		FStep=50;
					break;
					case 7:		FStep=200;// ���
					break;
					case 8:		FStep=1;  //���  // �������� ����� �	
				}
				BPrintf('d',FStep,4,3);
				if(CounFStep<6){ // �����
					BPrintf('s',Gz,4,8);
					Mng=1;
				}
				else{
					if(CounFStep<8){
						BPrintf('s',kGz,4,8);
						Mng= 1000;
					}
					else {
						BPrintf('s',Mgz,4,8);
						Mng=1000000;
					}
				}
			}
			else{ //�������� ������� � ������������ � ��������� �����
				//Fstep ������ ���������� � �������� ����
				//OutFreq ������� ������� ������������ �� ���������� � ������
				//GenFreq ������� ������� �������� �� ������ � ����������
				// mng
				if(PointMenu==0){ //1 ������ ����� ���������
					OutFreq -=Mng*FStep;
				}
				else{  //������ ������(�����������)
					OutFreq +=Mng*FStep;
				}
				if(OutFreq<0) OutFreq=12500000; //12.5���
				if(OutFreq>12500000) OutFreq=0;
				GenFreq = (unsigned int)(OutFreq/1000); // �������� ������� � ���
				BPrintf('d',GenFreq,2,3);
			}
			QueControl();
			return 0;
		}
	}
	if(Nesting ==4){ // ��������� �� �������� 2
		//Nesting =3;
		OldNest=3;
		PointMenu++;
		ConditionEncoder=2;
		if(PointMenu>1) PointMenu =0;
		if(PointMenu<0) PointMenu =1;
		if(PointMenu==1){
			BPrintf('p',0,3,1); // ����� ����
			OldPoinMenu =1;
		}
		else{
			BPrintf('p',0,5,1); //����� ���
			OldPoinMenu =0;
		}
		QueControl();
		return 0;
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
;
;
;SPI
;MOSI=	D11=PB3
;SCK=	D13=PB5
;SS     PB1 --> D9  (16bit)
;PC0-5 = A0-A5 �����; PC0�������

;�������
;Int0=PD2=S1=D2
;Int1=PD3=Key=D3
;PD4     =S2=D4
;
;AD9833
;D11=DAT
;D9 =FSNK
;D13=CLK

;SSD1308
;PC4=SDA=A4
;PC5=SCL=A5
;������������� ���������?
3.5 ���
*/
