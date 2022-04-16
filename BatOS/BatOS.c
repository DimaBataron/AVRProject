/*
 *
 * Created: 15.01.2022 12:48:30
 *  Author: dima
 ���������� ���������� ��� TWI ������ ������� ����������
 */ 
#include "BatOS.h"
#include "BatIO.h"
#include "BatTime.h"
#include "SSD1306.h"
#include "SetupBatOS.h"
#include <avr/interrupt.h> // ��������� ���������� ����������
//#include "F:\AVR\7.0\toolchain\avr8\avr8-gnu-toolchain\avr\include\util\atomic.h"

static char StatusTransit=0; // ������������ ��� ������ ����


#ifdef SSD1306M
#define AdrSSD1306 0x78  //����� ����������
//������� ���������� ������ �����
extern char QueueProc[100]; // ������� �������� BatIO.c
extern char PoinProcRed; // ��������� �� ������ ������� ��������� ��� ������ BatIO.c
extern unsigned char DataQueue[200]; // ������ ��������
extern unsigned char PoinQueRed; // ��������� �� ������ ������ �������� ��� ������
extern char PoinProc; //����� ������� �������� ��� ������
extern unsigned char PoinQue; //��������� �� ������ ������ ��� ������
extern char CountMasPos; // ����� �������� �������� ��� ������ �� ������� 

extern char CountMasWr; //������� ������� ��� ������ � ������ ����������������
#endif
//=====================================================
extern unsigned char Wait;  // ������������ ��� ������������ ���������.
extern unsigned char sec; // ������������ ��� ������� �������.
//=====================================================================
//SPI � AD9833
#ifdef BatSPIM
extern unsigned char SPIQue[100]; // ������� � ����������� � ������� ��� �������� � ���������� SPI
extern unsigned char ReadQueSPI; // ���������� ������ ����� �������� ��� ������ �� ������� ��������
extern unsigned char WriteQueSPI;
char (*PtrTask[SPILenTaskMas])(); // ���� ������ ������ ��� �������� ������� ������� ������������ � �����������
// ����������� ��� ��������� ������ SPI �� ������
static unsigned char SPICondition=0; //���������� ����������� �� ��������� ��������
#endif

#ifdef SSD1306M
//====================================================================
/*
//������� �������� 
0. �������� �� ����
1. ����� �� �������
2. ������ ����� ��� �������� �����������
3. ������ ���������� �� ������������� �� ��������
4. �������� ������ ����������������
5. ������ ��������.
6. ����� �� ������ ������� ��� ���� �������
7. ������ ���������� ��� ��������
����� �������� ������ ������������ �����

*/
// ��������� ��������� ������� ����� TWI � ������� ������� ����� ��������
void Processing(){
	unsigned char Proc,c;
	char *MasSymOUT=0; // ����� ������� ������� �������� ����� �������
	Proc = QueueProc[PoinProcRed]; // ����� ������ �� �������
	if(Proc!=0xFF){ // ���� ������� ������
		switch(StatusTransit){// ���������� ��������� ����������	
			case 0:  //���� �������� �� ����. 
				SSisTWI(); // ���������� ������ �����
			break;
			
			case 2: // ��� ��������� ������ �����
				TrAdr(AdrSSD1306); //���������� �����
			break;
			
			case 6: // ����� ������� ��� ���� �������
			{
				switch(Proc){
					case 0: // �������� ������� ���� TrMasByte
					MasSymOUT = DataQueue[PoinQueRed] << 8;
					MasSymOUT =  ((int)MasSymOUT) | (((int)DataQueue[PoinQueRed+1]) & 0b0000000011111111); 
					
					c = SSDTrMasByte(MasSymOUT);  // ������� ������ ���� �� ������� ��������� ��������� MasSymOUT
					if(c == 0){ // �������� ���������
						PoinQueRed++; //������� ������ ������
						PoinQueRed++;
						PoinProcRed++; //������� ��������� � ������� �����
						StatusTransit = 0; // ������ ��������
						TWCR = (1<<TWINT);
						QueControl();
					} //����� �������� ���������� ������ MasPosYk 0xFF ������??
					break;
					
					case 1: // ��������� ������ SetLine
					c = SetLine();// ���� ��������� �������� � �������� �����
					if(c == 0){
						PoinProcRed++; // ������� ��������� � ������� �����
						StatusTransit = 0; //������ ��������
						TWCR = (1<<TWINT); // ����� ����� ���������� �� TWI. ������ ������ �� �������.
						QueControl();
					}
					break;
					
					case 2:  // ��������� ������� SetColomn
					c = SetColomn();
					if(c == 0){
						PoinProcRed++;
						StatusTransit = 0; // ������ ��������
						TWCR = (1<<TWINT); // ����� ����� ���������� �� TWI. ������ ������ �� �������.
						QueControl();
					}
					break;
					// �������� ����� ������ �������.
					case 3: //����� ������ ������� PrintChar
					c = PrintChar();
					if(c == 0){
						PoinProcRed++;
						StatusTransit = 0; // ������ ��������
						TWCR = (1<<TWINT); // ����� ����� ���������� �� TWI. ������ ������ �� �������.
						QueControl();
					}
					break;
					case 4: //�������� ������� �������������
					c = SSDInit(); 
					if(c == 0){ // ��� �� ���������� � ��������� ���� � ����������� ��� ������ �������
						PoinProcRed++;
						StatusTransit = 0;
						TWCR = (1<<TWINT);
						QueControl();
					}
					break;
					case 5: //��������� ������� �������
					c = CleanSSD(DataQueue[PoinQueRed]); // � ������� ���������� ��������� ��������
					if(c==0){ // �������� ���������
						PoinProcRed++;
						PoinQueRed++;
						StatusTransit = 0;
						TWCR = (1<<TWINT);
						QueControl();
					}
					break;
					case 6: //��������� ������ ������ ������� �� ������ ��������
					c = OutPMem();
					if(c==0){
						PoinProcRed++;
						StatusTransit = 0;
						TWCR = (1<<TWINT);
						QueControl();
					}
					break;
					case 7: //��������� ������ 5�� �������� �����.
					c = PrintNum();
					if(c==0){ //������ ��� �����
						PoinProcRed++;
						StatusTransit = 0;
						TWCR = (1<<TWINT);
						QueControl();
					}
					break;
				}
			}
			break; //case 6
		} //switch
	}//if
}


//��������� ��������� ������� TWI. ���� ������ ���� ��������� ���������
void QueControl(){
	unsigned char Proc;
		__asm__ volatile("cli" ::: "memory");
		if(StatusTransit==0){ // ���� �������� �� ����.
			Proc = QueueProc[PoinProcRed];
			if(Proc!=0xFF){ // ����� �� �������?
			Processing(); // ���� �� ����� �������� �� �����
			}
			else{ 	// ���� ���� ������� ������.
				PoinProcRed = 0; // ��������� ��� ������ �� ������� ��������.
				QueueProc[PoinProcRed]=0xFF; // ���������� ��� ��� � ������� ����� ���������
				StatusTransit = 0;
				PoinQueRed = 0; // ����� ��������� �������� ������� ������
				CountMasWr = 0; // �������� ����� �������� ������� ������ ���������������� �������.
				PoinProc = 0; // �������� ������� ��� ������ �����
				PoinQue=0;    // ������� ������� ��� ������ ������
				CountMasPos = 0; // ������� ������� ���������������� ��� ������
		}
		}
	__asm__ volatile("sei" ::: "memory");
}

ISR(TWI_vect){ // ���������� �� ������ TWI (��� ��� ������ ������� ����������)
	//����� �� ��������� ������ ������� � �������������� �����? ����������� ��� ��� ����������� �
	//�������������
	switch(TWSR){
		case 0x08 :
		StatusTransit = 2; // ��� ������� ������ �����. ������������ ������ ��� �������� �����
		Processing();
		break;
		
		case 0x10 : // �������� ���� ��� � �����. ����� ���� ���������� �����
		StatusTransit = 2;
		Processing();
		break;
		
		case 0x18 :
		StatusTransit = 6; // ������������ ���� ��� ����� + ��� (W) ������ ��������.
		Processing();
		break;
		
		case 0x28 : // ������� ����� ������ � ������� �������������
		StatusTransit = 6; //5 ����� ������� ����� �������� ������
		Processing();
		break;
		
		case 0x20 : // ������� ����� � ������������� �� �������
		StatusTransit = 1 ;				// ��� ������ � ����� ������?
		Processing();					// 1. ����� ��������� ��������� �������� ������
		break;							// 2. ����� ��������� ������ ���� � ����� ����� ��� �������� ��� �� �������� ��������
		
		case  0x30 : // ������� ����� ������ � ������������� �� �������
		StatusTransit = 3;
		Processing();
		break;
		
		case 0x38 : // ������ ���������� ��� �������� ��� ����� ������?
		StatusTransit = 7;
		Processing();
		break;
	}
}


#endif
//=======================================================================
//SPI
#ifdef BatSPIM
//��������� ��������� ������� SPI
//���� ��������� ������ �� ����������� ������� SPIQueContrl()
void ProcSPI(){
	unsigned char Proc;
	char (*TaskSPI)(); // ��������� �� ���������?
	char c;
	Proc=SPIQue[ReadQueSPI]; // ���� ������ �� �������.
	if(Proc!=0xFF){ //������ ��� ����
		TaskSPI=PtrTask[Proc]; // ������� ����� ���������
		c=TaskSPI(); // �������� ���������
		if(c==0){ // �������� �������� � ����������� �� ���� ����� ������ ������� ������� ������
			if(Proc==0){ // �������� ������� ����������� SendMod();
				ReadQueSPI +=2;
			}
			else { // �������� ���� ������� ����������� SendFreq();
				ReadQueSPI +=5;
			}
			SPICondition=0; //�������� �� ����
			SPIQueContrl();
			return;
		}
		else { // ��������� ��������
			SPICondition =1 ; // �������� ��� ���� ��������
			return;
		}
	} //if Proc
	else { // c��� ������� ������ ������� ������
		SPICondition=2;
		SPIQueContrl();
	}
	return;
}

//����������  �������. ������� ������� ���� ��������� ��������. ���� �������� ���������� ������
void SPIQueContrl(){
	if(SPICondition==0){// �������� �� ����
		ProcSPI();
	}
	else{
		if(SPICondition==2){ // ������� ����� ������� �������
			SPICondition=0; // �������� �� ����
			ReadQueSPI=0;
			WriteQueSPI=0;
			SPIQue[WriteQueSPI]=0xFF;
		}
		//�������� ����
	}
	return;
}
//����������
ISR(SPI_STC_vect){ //��������� �������� �� SPI
	SPICondition=0; // �������� ��� �������� �����������
	SPIQueContrl();
}
#endif

//�� ���������� �� ������������ ������� �������� ��������� ���������� �������
//���� �������� ������� ����� ����������
//��������� ��� ����� ����� ���� ��� ��������� ����� ������� �� ��������.

#ifdef EncoderM
ISR(TIMER0_OVF_vect){ 
		sec--;
		if(sec==0){ // ��������� ������ 
			EncoderPres();
		}
}
ISR(INT0_vect){ //���������� ��� �������� ��������
	EncoderRet();
}
ISR(INT1_vect){ //���������� ��� ������� �� �������
	EncoderPres();
}
#endif
