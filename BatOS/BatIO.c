/*
 * BatIO.C
 * ������ ����� ������

 * ��������� ��������� ������������ ���� ��� ����� ������.
 * ��������� �������� ������������� � ����������.
 * ���������� ������ ����� ���������, � ������������������ ���������.

 * �������� ������� � �������� ������������� ������ ���� �������
 * �.�. � ������ ������������� �������
 * Created: 15.01.2022 13:32:53
 *  Author: dima
 */ 
#include "BatIO.h"
#include "BatSPI.h"
#include "BatTWI.h"	
//#include "BatAD9833.h"
#include <avr/io.h> //�������� ���� ��������� � ������ �����������


// ������ �������� ������� ����������� � ������� ������� SPI
#define SendModK  0 //�������� ���� ������
#define SendFreqK 1 //�������� ���� �������

// ������ �������� ������� ����� ��������� � ������� ������� TWI
#define TrMasByte 0 //[0]   �������� ������� ����
#define SetLine	  1 //[1]   ���������������� ������
#define SetColomn 2 //[2]   ���������������� �������
#define PrintChar 3 //[3]   ����� ������ �������
#define SSDInit   4 //[4]   ��������� ���������� � ������� �������� ������� ���� ������������� ������
#define CleanSSD  5 //[5]   ��������� ������� ������
#define OutPMem   6 //[6]	��������� ������ ����� �� ������ ��������
#define PrintNum  7 //[7]   ��������� ������ �����



char QueueProc[100]; // ������������ ����� ������� 100
unsigned char DataQueue[200]; // ������������ ����� ������� � ������� ��� ��������.

unsigned char MasPosYk[40];  //������� 40 ���� � ��� ��� ��������
//������ ���������������� ���������

unsigned char CountMasWr=0; //������� ������� ��� ������ � ������ ����������������
//������ � �������� ��������
char PoinProc=0; //��������� �� ������ ������� ��������� ��� ������
char PoinProcRed=0; // ��������� �� ������ ������� ��������� ��� ������
unsigned char PoinQue=0;  //��������� �� ������ ������ �������� ��� ������
unsigned char PoinQueRed=0; //��������� �� ������ ������ ��� ������

static char OldStr=0; //���������� ��������� ���������. ��� ����������� � ����� �����
static char OldCol=0; // ���������� ������� ������ ���������



extern const char Point[]; // ���� ������ ��������� � ������ ����� � PROGMEM

extern unsigned char SPIQue[100]; // ������ ��� �������� �������� � �� ������ ��� �������� �� SPI
extern unsigned char WriteQueSPI; // ������� ��� ������ � ������ SPIQue;

extern char (*PtrTask[2])(); // ������ � ������� ��������
extern unsigned char SendMod();
extern unsigned char SendFreq();

//��������� ���������� ���������� ����� ����������(�������� �� ��������� �� ������������)
//���� ����������  ������ ��� ������ ��� ����� ������ ��� ����.
//��������� ���������������� ������
//����� �������, ����� �����, ����� ������
char BPrintf(char Mod,char *MasOut , char Str, char Col){  // char *MasOut 
		 // ��������� ���������� � ������� ������ �������.
	if(Mod=='s'){ 
		QueuingLine(Str);//� ������� ���������������� ������
		QueuingColon(Col);// ��������� � ������� ���������������� �������
		QueuingStr(MasOut); // ����� ������ 
		return 1; //1 ������ �������
	}
	if(Mod=='c'){//����� �������. � ������ ������ ������ ������� ��������� ��� ������� � ������� ������ ��������
		//DataQueue
		QueuingLine(Str);//� ������� ���������������� ������
		QueuingColon(Col);// ��������� � ������� ���������������� �������
		QueuingSym((char)MasOut); 
		return 1; //1 ������ �������
	}
	if(Mod=='p'){//����� ���������
		QueuingOutPM(Point,Str,Col); // ����� ������� ����� ���������� ������ ��������� ��������� ��� �������
		return 1;
	}
	if(Mod=='d'){ //����� ����� ������������ ����� 5������.
		QueuingLine(Str);//� ������� ���������������� ������
		QueuingColon(Col);// ��������� � ������� ���������������� �������
		QueuingPrintNum(MasOut);
		return 1;
	}
	// �������� ����� ������ ������� �� ������ ��������
	return 0; // ��� �� ����� �� ���
}

//��������� ���������� � ������� ������ ������
//����������� ��������� ����� ������������ � ��������� � ������� ������.
//��������� �� ������ ������������ � ���������??
void QueuingStr(char *MasOut){
	//�������� ��������� �������� �������( ����� �� ���������� ����� ���� � �.�)
	//����� �� ����� ��� ���������?
	QueueProc[PoinProc++] = TrMasByte; //������ ��������� � �������
	QueueProc[PoinProc] = 0xFF;        //������� ����� �������
	//������ ������ ������� �������� � ������ ������
	DataQueue[PoinQue++] =(char)((int)MasOut >> 8); //������ ������� ���� ������
	DataQueue[PoinQue++] =(char)MasOut; // ������ ������� ����
}
//��������� ���������� � ������� ������ ������ �������
void QueuingSym(char ChaQ){
	QueueProc[PoinProc++]=PrintChar; // ����� �������
	QueueProc[PoinProc] = 0xFF;        //������� ����� �������
	DataQueue[PoinQue++]=ChaQ ;      // ���������� ���� ������� � ������� ������ ��������
}

//��������� ���������� � ������� ������ ���������������� ������
void QueuingLine(char Nstr){
       QueueProc[PoinProc++]= SetLine; //������ ��������� � �������
	   QueueProc[PoinProc] = 0xFF;      
	   MasPosYk[CountMasWr++] = Nstr;    // ��������� ������ ��� ������
	   MasPosYk[CountMasWr++] = 7;       // �������� ������ ����� ���� 7 ������ 0??
}

//��������� ���������� � ������� ������ ���������������� �������
void QueuingColon(char Ncol){
	 QueueProc[PoinProc++]= SetColomn; // ������ ��������� � �������
	 QueueProc[PoinProc] = 0xFF;        //������� ����� �������
	 MasPosYk[CountMasWr++] = Ncol;    // ��������� ������� ��� ������
	 MasPosYk[CountMasWr++] = 15;      // �������� ������ ����� ���� 7 ������ 0??
}

//��������� ���������� � ������� �������� ����������������� ���� �������
void  QueuingSSDInit(){
	QueueProc[PoinProc++]= SSDInit; // ������ ��������� � �������
	QueueProc[PoinProc] = 0xFF;     // ������� ����� �������
}

//��������� ���������� � ������� ������� ������
void QueuingCleanSSD(unsigned char CountSymb){
	//QueuingLine(0);//����� �������� ������ ��������� � ������
	//QueuingStr(0);
	QueueProc[PoinProc++]= CleanSSD; // ����� ��������� � �������
	QueueProc[PoinProc]= 0xFF;		// ������� ����� �������
	DataQueue[PoinQue++] = CountSymb; // ���������� ��������� �������� � ������ ������
}

//��������� ���������� ������ ����� �� ������ �������� ������� ��������� ������� �����. �������� ����� ������
//�������
void QueuingOutPM(char *ProgMemor, char Str, char Col){
	QueuingLine(OldStr); // ���������� � ������� ������� 
	QueuingColon(OldCol);
	QueuingCleanSSD(1); 
	QueuingLine(Str); // ���������� � ������� ������
	QueuingColon(Col);
	OldStr = Str;
	OldCol = Col;
	QueueProc[PoinProc++]= OutPMem; // // ����� ��������� � �������
	QueueProc[PoinProc]= 0xFF;		// ������� ����� �������
	DataQueue[PoinQue++] =(char)((int)ProgMemor >> 8); //������ ������� ���� ������
	DataQueue[PoinQue++] =(char)ProgMemor; // ������ ������� ����
}
//��������� ���������� � ������� ������ �����
void QueuingPrintNum(char *MasOut){// MasOut ��� ����� unsignet int.
// �.�. �� 0 �� 65535 ������� ���� 12345 (� ������� ����� � �����������)
//� ������� �����������(�� �������� ������� � ��������)
	 unsigned int Num = MasOut; // ���������� �����
	 unsigned char i=0;
	 QueueProc[PoinProc++] = PrintNum;
	 QueueProc[PoinProc] = 0xFF;
	 for(i=0; i<5; i++){ // �������� ������� �����
		  DataQueue[PoinQue++] = (char)(Num%10);
		  Num = Num/10;
	 }
}

// ��������� ��������� ��������� ������ TWI ��� ������ � ������� SSD1306
void StartTWISSD1306(){
//�������� I2C 400��� SSD1306 ������ ������������. 
//210kHz TWBR=30. TWPS=0;
	ConTWIPort(); //��������� ��� �� ����� ������� TWI
	//ConfTime0(); // �������� ������ �� ������ �� ������������ ������� ��������
	TWBR = 30;//10=444��� //30= 210kHz 
	QueuingSSDInit(); // ���������� � ������� �������� ���� �������������
	StartLC();
	QueuingCleanSSD(128); // ���������� � ������� ������ ������� ������ //128 ������� �� 2 ��� �������
	__asm__ volatile("sei" ::: "memory"); //���������� ����������
}


//��������� ��������� ��������� � ������
void StartLC(){
	QueuingLine(0); // ���������� � ������� ������
	QueuingColon(0);
}

//��������� ��������� ��������� ������ SPI �� ������
//�������� ��������� �������������� ���� SPI � ����� �����? ��� ���� �����
//�� ���������� ������ spi � ����� ������� �� ��������� �������??)
// ����� ��������� � ������ ����?
void StartSPIAD9833(){
	SPIConfigPort();  // ��������� ��� �� ������
	SPIConfig(((1<<SPIE)|(1<<SPE)|(1<<MSTR)|(1<<CPOL)|(1<<SPR0)),0); //������ �������� 1���
	PtrTask[0]=&SendMod; // ������ ������ ��������� � ������
	PtrTask[1]=&SendFreq;
	__asm__ volatile("sei" ::: "memory"); //���������� ����������
}

// ��������� ���������� � ������� �������� ������� �� AD9833
//��� ���� ��� ��������� �����������
void SendFreqAD9833(unsigned long int Dec){
	//������ ������ ������ � ������ ��� ������������ ������
	unsigned long int *MasSPI = 0;
	SPIQue[WriteQueSPI++] = SendFreqK; // ��������� ����� ������ � ������
	MasSPI = (unsigned long int *)(&SPIQue[WriteQueSPI]);
	*MasSPI = Dec; // ��������� 4����� � ������ SPIQue
	WriteQueSPI +=4;
	SPIQue[WriteQueSPI]=0xFF; // ������� ����� ������
}

// �������� ������ �� ���������� AD9833
void SendModAD9833(unsigned char Mod){
	SPIQue[WriteQueSPI++]=SendModK; // �����
	SPIQue[WriteQueSPI++]=Mod;	 // ������ ������
	SPIQue[WriteQueSPI]=0xFF; // ������� ����� ������
}