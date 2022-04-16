
/*
 * BatOS.c
 *
 * Created: 08.01.2022 6:44:10
 * Author : dima
 // В протеус не работает часть кода с атомнарными операциями почему?
 // Проверить повторное добавление в очередь SPI/
 */ 
//#include "BatIO.h"
//#include "BatSPI.h"
#include "BatOS.h"
#include "SetupBatOS.h"
//#include <stdatomic.h> // атомарная либа для компилятора. Чтобы компилятор не убирал т.к. используется в
// прерывании
//#include <iom328p.h>
//#include "F:\AVR\7.0\toolchain\avr8\avr8-gnu-toolchain\avr\include\util\atomic.h"


extern volatile signed char ConditionEncoder; // Следим за состоянием переменной
static signed char Nesting = 0; //Вложенность
static signed char PointMenu = 0; // Повороты энкодера
static signed char OldNest =-1;   // старое состояние процедуры menu
static unsigned char OldPoinMenu=0;
static signed char CounFStep=0;	// может принимать 9 значений

static volatile signed long  FStep=0;		// Величина шага изменения которую выбрали
static volatile signed long  GenFreq=0;		// Частота которую накрутили выводится на экран
static volatile	signed long  OutFreq=0;		// число которое отправляем в микросхему unsigned
static volatile signed long Mng=0;			// множитель для вычисления 
	
	char f[]="част";
	char mod[]="сигн";
	char step[]="шаг";
	char Gz[]="гц ";
	char kGz[]="кгц";
	char Mgz[]="мгц";
	char si[]="синус";
	char tr[]="треуг";
	char DAC1[]="цап";
	char DAC2[]="цап2"; // Забал выводит ли цифры?
	

int main(void)
{
	//Настраиваю TWI и энкодер
	StartTWISSD1306(); //Конфигурация экрана на передачу
	GetSygEn(); //процедура конфигурирует прерывания от энкодера
	QueControl(); // Запускаю обработку очереди
	
	//Настраиваю SPI 
	StartSPIAD9833();
	
	/*

	//Примеры испозьзования процеду
	BPrintf('d',12345,4,5); // постановка в очередь вывод числа.
	BPrintf('p',0,2,1); // p значит вывод указателя стирает старый указатель
	BPrintf('s',f,2,3);   // в очередь вывод строки (строка должна быть в озу)
	BPrintf('c','ч',3,4); // в очередь вывод символа
	SendFreqAD9833(0xFFFFFFFF);
	SendModAD9833(0xFF);
	SPIQueContrl(); //Запуск обработчика очереди
	*/

while (1)  // вывожу меню // Это можно добавить в прерывание по таймеру
    {
		
		if(ConditionEncoder<4) {
			MainMenu();
		}

    }
}
/*
//Процедура считает вложенность и поворот
//При изменении вложенности перерисовывается меню.
//При повороте перерисовывается указатель
*/
void MainMenu(){
	unsigned char Str;
	unsigned long FreqReg; // Значение отправляемое на микросхему
//===========================================================================================
					//  ------>>>>>ЗАПУСК<<<<<--------
	if(OldNest==-1){ // Первоначальный запуск
		//Вывод вложенность 0;
		OldNest=0;
		BPrintf('s',f,3,3); // Вывод строки частота;
		BPrintf('s',mod,5,3); //Вывод строки режима
		BPrintf('p',0,5,2); // Вывод указателя
		PointMenu = 0;		// Указываю что вывел указатель в 0 позиции.
		Nesting = 0;
		ConditionEncoder=4;
		QueControl();
		return 0 ;
	}
	//=========================================================================================
	//				ОБРАБОТКА СОСТОЯНИЯ
	OldNest = Nesting;
	switch(ConditionEncoder){
		case 0: // короткое нажатие выбор
		Nesting++;
		ConditionEncoder=4;
		break;
			
		case 1: // вправо поворот
		PointMenu++;
		ConditionEncoder=4;
		break;
		
		case -1: //влево поворот
		PointMenu--;
		ConditionEncoder=4;
		break;
		
		case 2: // длительное нажатие назад значит
		Nesting--;
		ConditionEncoder=4;
		break;
	}
	if(Nesting<0){
		 Nesting=0;
	}	
	//===========================================================================================
	// ВЛОЖЕННОСТЬ 0
	if(Nesting==0){ //Вложенность 0
		if(PointMenu>1){ // указатель за пределами
			PointMenu=0;
		}
		else {
			if(PointMenu<0) PointMenu=1;
		}
		if(OldNest==Nesting){ //нажатий не было был поворот. перерисовывать меню не надо только указатель
			if(PointMenu==0){
				BPrintf('p',0,5,2); // Вывод указателя рядом с выбором режима
			}
			else{
				BPrintf('p',0,3,2); // Вывод указателя рядом с выбором частоты
			}
			QueControl();
			return 0;
		}
		else{ // Перешли в это вложение
			StartLC();
			QueuingCleanSSD(128);
			BPrintf('s',f,3,3); // Вывод строки частота;
			BPrintf('s',mod,5,3); //Вывод строки режима
			BPrintf('p',0,5,2); // Вывод указателя
			PointMenu = 0;		// Указываю что вывел указатель в 0 позиции.
			if(OldNest!=1) Nesting =2;
			QueControl();
		}
		return 0;
		}
		if(OldNest==0){ //сделано короткое нажатие в меню вложенность 1;
		StartLC();
		QueuingCleanSSD(128); //очистка всего экрана. Может очищать определенную область?
		if(PointMenu==0){//переход в режим вывода режима
		// сюда зашли впервые по-любому
			BPrintf('s',si,5,3);
			BPrintf('s',tr,4,3);
			BPrintf('s',DAC2,3,3); // Проверить выводит ли цифру
			BPrintf('s',DAC1,2,3);
		
			BPrintf('p',0,5,2); //вывод указателя в начало
		}
		else{ //режим выбора частоты
			BPrintf('s',step,5,3); //слово шаг
			BPrintf('d',00000,4,3); // Здесь подставить шаг в этой же строке вывести множитель шага
			BPrintf('s',f,3,3);  // слово  част
			BPrintf('d',00000,2,3);// подсавить выводимую частоту в кгц
			BPrintf('s',kGz,2,8); //Вывожу слово килогерцы
			Nesting = 2;
		}
		QueControl();
		}
		//===================================================================================
		//------>>>ВЛОЖЕННОСТЬ 1<<<------ (ВЫБОР РЕЖИМА)
	if(Nesting==1){ //Проверить отправку байт выбора режима
		//В меню выбора режима 4 режима.
		if(OldNest==Nesting){ //поворот энкодера
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
		if(OldNest==2){//длительное нажатие в ВЛОЖЕННОСТЬ 2. //Вывести основное меню ВЛОЖЕННОСТЬ 0
			ConditionEncoder=2;
			//Может рекурсия?
			return 0;
		}
	}
	//==================================================================================
	//                    --->>>BЛОЖЕННОСТЬ 2<<<--
	if(Nesting==2){
		if(OldNest==1){ //Отправляем выбранный режим на микросхему
			switch(PointMenu){ 
				case 0: { // отправка командного слова в зависимости от режима
					SendModAD9833(0x00);
					break;
				}
				case 1: {
					SendModAD9833(0x02);
					break;
				}
				case 2: {
					SendModAD9833(0x20);
					break;
				}
				case 3: {
					SendModAD9833(0x28);
					break;
				}
			}
			SPIQueContrl();
			// вывод символов
			StartLC(); // Вывод меню настройки частоты
			QueuingCleanSSD(128);
			BPrintf('s',step,5,3); //слово шаг
			BPrintf('d',00000,4,3); // Здесь подставить шаг в этой же строке вывести множитель шага
			BPrintf('s',f,3,3);  // слово  част
			BPrintf('d',00000,2,3);// подсавить выводимую частоту в кгц
			BPrintf('s',kGz,2,8);
			PointMenu = 0;
			QueControl();
			return 0;
		}
		if((OldNest==2)||(OldNest==4)){ //поворот энкодера
			if(PointMenu>1) PointMenu =0;
			if(PointMenu<0) PointMenu =1;
			if(PointMenu==1){ 
				BPrintf('p',0,3,1); // выбор част
				OldPoinMenu =1;
			}
			else{
				 BPrintf('p',0,5,1); //выбор шаг
				 OldPoinMenu =0;
			}
			QueControl();
		}
		if(OldNest==3){//выход обратно в настройки частоты
			PointMenu = 0;
			BPrintf('p',0,5,1); //выбор шаг
			OldPoinMenu = 0;
			QueControl();
		}
		return 0;
	}
	// Сразу после нажатия OldNest=2; Ничего не делать. Все должно быть нормально
	if(Nesting==3){//нажатие в меню выбора частоты(ВЛОЖЕННОСТЬ 2
		if(OldNest==3){ // поворот после того как зафиксировали изменения
			//Проверить на правильность данные
			if(PointMenu<0) PointMenu =0;
			if(PointMenu>1) PointMenu =1;
			if(OldPoinMenu==0){ // изменяем шаг
				if(PointMenu==0) CounFStep--;//Крутим влево(уменьшаем)
				if(PointMenu==1) CounFStep++; //Крутим вправо(увеличиваем)
				if(CounFStep<0) CounFStep=8; // В зависимости от этого шага выводим множитель
				if(CounFStep>8) CounFStep=0;	
				switch(CounFStep){
					//1 вложенность (шаг) (кручу сначала по 5, 20, 50, 200, 1000, 5000гЦ 50кГц, 200кЦ, 1мГц)
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
					case 5:		FStep=5000; // гц
					break;
					case 6:		FStep=50;
					break;
					case 7:		FStep=200;// кгц
					break;
					case 8:		FStep=1;  //мгц  // Добавить букву м	
				}
				BPrintf('d',FStep,4,3);
				if(CounFStep<6){ // Герцы
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
			else{ //изменяем частоту в соответствии с выбранным шагом
				//Fstep хранит информацию о величине шага
				//OutFreq частота которая отправляется на микросхему в герцах
				//GenFreq частота которая показана на экране в килогерцах
				// mng
				if(PointMenu==0){ //1 Крутим влево уменьшаем
					OutFreq -=(signed long) Mng*FStep;
				}
				else{  //Крутим вправо(увеличиваем)
					OutFreq +=(signed long) Mng*FStep; // внимание к этой переменной правильное ли там значение
				}
				if(OutFreq<0) OutFreq=12500000; //12.5мгц
				if(OutFreq>12500000) OutFreq=0;
				GenFreq = (unsigned int)(OutFreq/1000); // Получаем частоту в кгц
				BPrintf('d',GenFreq,2,3);
				//Теперь надо отправить значение частоты в микросхему AD9833 Str 
				//Это все перенес внутрь функции SendFreqAD9833
				/*
				FreqReg =(unsigned long) OutFreq*11; // Округлил т.к. с целыми быстрее вычисления 10.7374
				FreqReg = ((FreqReg & 0xFFFF0000)<<2) | (FreqReg & 0x0000FFFF);
				FreqReg = ((FreqReg & 0x00008000) << 2) | (FreqReg & 0xFFFF7FFF);
				FreqReg = ((FreqReg & 0x00004000) << 2) | (FreqReg & 0xFFFFBFFF);
				//Указываю что использую регистр FREQ0
				FreqReg |= 0x40004000;
				*/
				SendFreqAD9833(OutFreq); // Отправляю значение частоты на микрохему
				
				SPIQueContrl(); // Запускаю на выполнение отправку байт на AD9833.
			}
			QueControl();
			return 0;
		}
	}
	if(Nesting ==4){ // переходим во вложение 2
		//Nesting =3;
		OldNest=3;
		PointMenu++;
		ConditionEncoder=2;
		if(PointMenu>1) PointMenu =0;
		if(PointMenu<0) PointMenu =1;
		if(PointMenu==1){
			BPrintf('p',0,3,1); // выбор част
			OldPoinMenu =1;
		}
		else{
			BPrintf('p',0,5,1); //выбор шаг
			OldPoinMenu =0;
		}
		QueControl();
		return 0;
	}
}

/*
;Программатор
;Белый Vin
;Серый Gnd
;Синий Rst
;Зеленый D11
;Фиолетовый D12
;Черный D13
;
;
;SPI
;MOSI=	D11=PB3
;SCK=	D13=PB5
;SS     PB1 --> D9  (16bit)
;PC0-5 = A0-A5 Диоды; PC0младший

;Энкодер
;Int0=PD2=S1=D2
;Int1=PD3=Key=D3
;PD4     =S2=D4
;
;AD9833
;D11=DAT
;D9 =FSNK
;D13=CLK
;VCC=2.3-5V


;SSD1308
;PC4=SDA=A4
;PC5=SCL=A5
;Подтягивающие резисторы?
3.5 кОм
*/
