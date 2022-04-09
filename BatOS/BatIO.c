/*
 * BatIO.C
 * Модуль ввода вывода

 * Реализует процедуры используемые осью для ввода вывода.
 * Процедуры являются многоразовыми и портируемы.
 * Изменяются только файлы драйверов, и платформозависимые процедуры.

 * Драйвера пишутся с условием использования именно этой системы
 * Т.Е. с учетом использования очереди
 * Created: 15.01.2022 13:32:53
 *  Author: dima
 */ 
#include "BatIO.h"
#include "BatSPI.h"
#include "BatTWI.h"	
//#include "BatAD9833.h"
#include <avr/io.h> //Описание всех регистров и портов контроллера


// Номера процедур которые выполняются в поредке очереди SPI
#define SendModK  0 //отправка байт режима
#define SendFreqK 1 //отправка байт частоты

// Номера процедур которые будут выполнены в порядке очереди TWI
#define TrMasByte 0 //[0]   передача массива байт
#define SetLine	  1 //[1]   позиционирование строки
#define SetColomn 2 //[2]   позиционирование столбца
#define PrintChar 3 //[3]   вывод одного символа
#define SSDInit   4 //[4]   процедура постановки в очередь отправки массива байт инициализации экрана
#define CleanSSD  5 //[5]   процедура очистки экрана
#define OutPMem   6 //[6]	процедура вывода байта из памяти программ
#define PrintNum  7 //[7]   процедура вывода числа



char QueueProc[100]; // максимальная длина очереди 100
unsigned char DataQueue[200]; // максимальная длина массива с данными для процедур.

unsigned char MasPosYk[40];  //Выделил 40 байт в ОЗУ для хранения
//Данных позиционирования указателя

unsigned char CountMasWr=0; //Текущая позиция для записи в массив позиционирования
//миссив с номерами процедур
char PoinProc=0; //Указатель на массив текущей ПРОЦЕДУРЫ для записи
char PoinProcRed=0; // указатель на массив текущей процедуры для чтения
unsigned char PoinQue=0;  //Указатель на МАССИВ ДАННЫХ процедур для записи
unsigned char PoinQueRed=0; //Указатель на массив данных для чтения

static char OldStr=0; //Предыдущее положение указателя. для перерисовки в новом месте
static char OldCol=0; // необходимо стереть старое положение



extern const char Point[]; // этот массив определен в другом файле в PROGMEM

extern unsigned char SPIQue[100]; // Массив для хранения процедур и их данных для передачи по SPI
extern unsigned char WriteQueSPI; // позицию для записи в массив SPIQue;

extern char (*PtrTask[2])(); // массив с данными процедур
extern unsigned char SendMod();
extern unsigned char SendFreq();

//Процедура использует переменное число параметров(ВНИМАНИЕ не проверяет их корректность)
//сюда передается  СТРОКА ИЛИ СИМВОЛ или ЦИФРА дальше все само.
//Процедура форматированного выводы
//Вывод символа, Вывод цифры, вывод строки
char BPrintf(char Mod,char *MasOut , char Str, char Col){  // char *MasOut 
		 // Процедура постановки в очередь вывода массива.
	if(Mod=='s'){ 
		QueuingLine(Str);//в очередь позиционирование строки
		QueuingColon(Col);// поставить в очередь позиционирование столбца
		QueuingStr(MasOut); // вывод строки 
		return 1; //1 значит успешно
	}
	if(Mod=='c'){//Вывод символа. В случае вывода одного символа сохраняет код символа в массиве данных процедур
		//DataQueue
		QueuingLine(Str);//в очередь позиционирование строки
		QueuingColon(Col);// поставить в очередь позиционирование столбца
		QueuingSym((char)MasOut); 
		return 1; //1 значит успешно
	}
	if(Mod=='p'){//вывод указателя
		QueuingOutPM(Point,Str,Col); // адрес массива также запоминает старое положение указателя для очистки
		return 1;
	}
	if(Mod=='d'){ //вывод числа максимальное число 5знаков.
		QueuingLine(Str);//в очередь позиционирование строки
		QueuingColon(Col);// поставить в очередь позиционирование столбца
		QueuingPrintNum(MasOut);
		return 1;
	}
	// Добавить вывод одного символа из памяти программ
	return 0; // что то пошло не так
}

//Процедура постановки в очередь вывода строки
//Попробовать сохранить адрес передаваемый в процедуру в массиве данных.
//Очистится ли строка передаваемая в процедуру??
void QueuingStr(char *MasOut){
	//добавить процедуру монитора очереди( нужно ли отправлять старт стоп и т.д)
	//Нужна ли здесь эта процедура?
	QueueProc[PoinProc++] = TrMasByte; //Запись процедуры в очередь
	QueueProc[PoinProc] = 0xFF;        //Признак конца очереди
	//Запись адреса массива символов в массив данных
	DataQueue[PoinQue++] =(char)((int)MasOut >> 8); //Запись старших байт адреса
	DataQueue[PoinQue++] =(char)MasOut; // запись младших байт
}
//Процедура постановки в очередь вывода одного символа
void QueuingSym(char ChaQ){
	QueueProc[PoinProc++]=PrintChar; // Вывод символа
	QueueProc[PoinProc] = 0xFF;        //Признак конца очереди
	DataQueue[PoinQue++]=ChaQ ;      // Сохранение кода символа в массиве данных процедур
}

//Процедура постановки в очередь вывода позиционирования строки
void QueuingLine(char Nstr){
       QueueProc[PoinProc++]= SetLine; //Запись процедуры в очередь
	   QueueProc[PoinProc] = 0xFF;      
	   MasPosYk[CountMasWr++] = Nstr;    // начальная строка для записи
	   MasPosYk[CountMasWr++] = 7;       // Конечная строка может быть 7 вместо 0??
}

//Процедура постановки в очередь вывода позиционирования столбца
void QueuingColon(char Ncol){
	 QueueProc[PoinProc++]= SetColomn; // запись процедуры в очередь
	 QueueProc[PoinProc] = 0xFF;        //Признак конца очереди
	 MasPosYk[CountMasWr++] = Ncol;    // начальный столбец для записи
	 MasPosYk[CountMasWr++] = 15;      // Конечная строка может быть 7 вместо 0??
}

//Процедура постановки в очередь отправки инициализационных байт дисплея
void  QueuingSSDInit(){
	QueueProc[PoinProc++]= SSDInit; // запись процедуры в очередь
	QueueProc[PoinProc] = 0xFF;     // признак конца очереди
}

//Процедура постановки в очередь очистки экрана
void QueuingCleanSSD(unsigned char CountSymb){
	//QueuingLine(0);//перед очисткой ставлю указатель в начало
	//QueuingStr(0);
	QueueProc[PoinProc++]= CleanSSD; // Номер процедуры в очередь
	QueueProc[PoinProc]= 0xFF;		// признак конца очереди
	DataQueue[PoinQue++] = CountSymb; // количество очищаемых символов в массив данных
}

//Процедура постановки вывода байта из памяти программ очищает положение старого байта. Добавить вывод одного
//символа
void QueuingOutPM(char *ProgMemor, char Str, char Col){
	QueuingLine(OldStr); // Постановка в очередь очистки 
	QueuingColon(OldCol);
	QueuingCleanSSD(1); 
	QueuingLine(Str); // Постановка в очередь вывода
	QueuingColon(Col);
	OldStr = Str;
	OldCol = Col;
	QueueProc[PoinProc++]= OutPMem; // // Номер процедуры в очередь
	QueueProc[PoinProc]= 0xFF;		// признак конца очереди
	DataQueue[PoinQue++] =(char)((int)ProgMemor >> 8); //Запись старших байт адреса
	DataQueue[PoinQue++] =(char)ProgMemor; // запись младших байт
}
//Процедура постановки в очередь вывода числа
void QueuingPrintNum(char *MasOut){// MasOut это число unsignet int.
// т.е. от 0 до 65535 запишем туда 12345 (и получим цифры в отдельности)
//В порядке возрастания(от младшего разряда к старшему)
	 unsigned int Num = MasOut; // Запоминаем число
	 unsigned char i=0;
	 QueueProc[PoinProc++] = PrintNum;
	 QueueProc[PoinProc] = 0xFF;
	 for(i=0; i<5; i++){ // получаем сисволы числа
		  DataQueue[PoinQue++] = (char)(Num%10);
		  Num = Num/10;
	 }
}

// Процедура стартовой настройки модуля TWI для работы с экраном SSD1306
void StartTWISSD1306(){
//скорости I2C 400кГц SSD1306 должен поддерживать. 
//210kHz TWBR=30. TWPS=0;
	ConTWIPort(); //Настройка ног на вывод сигнала TWI
	//ConfTime0(); // запускаю таймер на работу по переполнению таймера счетчика
	TWBR = 30;//10=444кГц //30= 210kHz 
	QueuingSSDInit(); // постановка в очередь отправки байт инициализации
	StartLC();
	QueuingCleanSSD(128); // Постановка в очередь полной очистки экрана //128 изменил на 2 для отладки
	__asm__ volatile("sei" ::: "memory"); //разрешение прерываний
}


//Процедура установки указателя в начало
void StartLC(){
	QueuingLine(0); // Постановка в очередь вывода
	QueuingColon(0);
}

//Процедура стартовой настройки модуля SPI на работу
//Возможно перевести неиспользуемую ногу SPI в режим вывод? Для того чтобы
//Не переводить модуль spi в режим ведомый от случайной наводки??)
// Может перенести в другой файл?
void StartSPIAD9833(){
	SPIConfigPort();  // Настройка ног на работу
	SPIConfig(((1<<SPIE)|(1<<SPE)|(1<<MSTR)|(1<<CPOL)|(1<<SPR0)),0); //Мастер скорость 1мгц
	PtrTask[0]=&SendMod; // Запись адреса процедуры в массив
	PtrTask[1]=&SendFreq;
	__asm__ volatile("sei" ::: "memory"); //разрешение прерываний
}

// процедура постановки в очередь отправку частоты на AD9833
//Это надо все проверить внимательно
void SendFreqAD9833(unsigned long int Dec){
	//запись номера задачи в массив для последующего вызова
	unsigned long int *MasSPI = 0;
	SPIQue[WriteQueSPI++] = SendFreqK; // Записываю номер задачи в массив
	MasSPI = (unsigned long int *)(&SPIQue[WriteQueSPI]);
	*MasSPI = Dec; // Записываю 4байта в массив SPIQue
	WriteQueSPI +=4;
	SPIQue[WriteQueSPI]=0xFF; // признак конца записи
}

// отправка режима на микросхему AD9833
void SendModAD9833(unsigned char Mod){
	SPIQue[WriteQueSPI++]=SendModK; // Режим
	SPIQue[WriteQueSPI++]=Mod;	 // Данные режима
	SPIQue[WriteQueSPI]=0xFF; // Признак конца записи
}