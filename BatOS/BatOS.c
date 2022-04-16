/*
 *
 * Created: 15.01.2022 12:48:30
 *  Author: dima
 Обработчик прерываний для TWI режима ведущий передатчик
 */ 
#include "BatOS.h"
#include "BatIO.h"
#include "BatTime.h"
#include "SSD1306.h"
#include "SetupBatOS.h"
#include <avr/interrupt.h> // Подключаю обработчик прерывания
//#include "F:\AVR\7.0\toolchain\avr8\avr8-gnu-toolchain\avr\include\util\atomic.h"

static char StatusTransit=0; // используется для вывода меню


#ifdef SSD1306M
#define AdrSSD1306 0x78  //Адрес устройства
//Внешняя переменная массив задач
extern char QueueProc[100]; // Очередь процедур BatIO.c
extern char PoinProcRed; // указатель на массив текущей процедуры для чтения BatIO.c
extern unsigned char DataQueue[200]; // данные процедур
extern unsigned char PoinQueRed; // Указатель на массив данных процедур для чтения
extern char PoinProc; //Номер массива процедур для записи
extern unsigned char PoinQue; //указатель на массив данных для записи
extern char CountMasPos; // Номер текущего элемента для чтения из массива 

extern char CountMasWr; //Текущая позиция для записи в массив позиционирования
#endif
//=====================================================
extern unsigned char Wait;  // используется для отслеживания состояния.
extern unsigned char sec; // используется для отсчета времени.
//=====================================================================
//SPI и AD9833
#ifdef BatSPIM
extern unsigned char SPIQue[100]; // Очередь с процедурами и данными для передачи и выполнения SPI
extern unsigned char ReadQueSPI; // Переменная хранит номер элемента для чтения из массива процедур
extern unsigned char WriteQueSPI;
char (*PtrTask[SPILenTaskMas])(); // Этот массив служит для хранения адресов функций используемых в обработчике
// Заполняется при настройке модуля SPI на работу
static unsigned char SPICondition=0; //переменная указывающая на состояние передачи
#endif

#ifdef SSD1306M
//====================================================================
/*
//Порядок передачи 
0. Передача не идет
1. адрес не передан
2. сигнал старт или повстарт сформирован
3. Данные отправлены но подтверждение не получено
4. Передача команд позиционирования
5. Данные переданы.
6. адрес на запись передан или байт передан
7. потеря приоритета при передачи
После отправки всегда отправляется адрес

*/
// Процедура обработки очереди задач TWI и очистки очереди после передачи
void Processing(){
	unsigned char Proc,c;
	char *MasSymOUT=0; // Адрес массива символы которого нужно вывести
	Proc = QueueProc[PoinProcRed]; // Читаю задачу из очереди
	if(Proc!=0xFF){ // Если имеются задачи
		switch(StatusTransit){// посмотреть состояние выполнения	
			case 0:  //если передача не идет. 
				SSisTWI(); // Отправляем сигнал старт
			break;
			
			case 2: // был отправлен сигнал старт
				TrAdr(AdrSSD1306); //Отправляем адрес
			break;
			
			case 6: // Адрес передан или байт передан
			{
				switch(Proc){
					case 0: // Передача массива байт TrMasByte
					MasSymOUT = DataQueue[PoinQueRed] << 8;
					MasSymOUT =  ((int)MasSymOUT) | (((int)DataQueue[PoinQueRed+1]) & 0b0000000011111111); 
					
					c = SSDTrMasByte(MasSymOUT);  // передаю массив байт на которые указывает указатель MasSymOUT
					if(c == 0){ // передача завершена
						PoinQueRed++; //сдвигаю массив данных
						PoinQueRed++;
						PoinProcRed++; //сдвигаю указатель в массиве задач
						StatusTransit = 0; // данные переданы
						TWCR = (1<<TWINT);
						QueControl();
					} //ПОСЛЕ ПЕРЕДАЧИ ОБНУЛЯЕТСЯ МАССИВ MasPosYk 0xFF почему??
					break;
					
					case 1: // установка строки SetLine
					c = SetLine();// сама формирует повстарт и передает адрес
					if(c == 0){
						PoinProcRed++; // сдвигаю указатель в массиве задач
						StatusTransit = 0; //Данные переданы
						TWCR = (1<<TWINT); // Сброс флага прерывания от TWI. Запуск только по таймеру.
						QueControl();
					}
					break;
					
					case 2:  // установка столбца SetColomn
					c = SetColomn();
					if(c == 0){
						PoinProcRed++;
						StatusTransit = 0; // Данные переданы
						TWCR = (1<<TWINT); // Сброс флага прерывания от TWI. Запуск только по таймеру.
						QueControl();
					}
					break;
					// Дописать вывод одного символа.
					case 3: //вывод одного символа PrintChar
					c = PrintChar();
					if(c == 0){
						PoinProcRed++;
						StatusTransit = 0; // Данные переданы
						TWCR = (1<<TWINT); // Сброс флага прерывания от TWI. Запуск только по таймеру.
						QueControl();
					}
					break;
					case 4: //Отправка массива инициализации
					c = SSDInit(); 
					if(c == 0){ // еще не передалось а переходит сюда и выполнятеся код раньше времени
						PoinProcRed++;
						StatusTransit = 0;
						TWCR = (1<<TWINT);
						QueControl();
					}
					break;
					case 5: //Процедура очистки дисплея
					c = CleanSSD(DataQueue[PoinQueRed]); // в массиве количество очищаемых символов
					if(c==0){ // передача закончена
						PoinProcRed++;
						PoinQueRed++;
						StatusTransit = 0;
						TWCR = (1<<TWINT);
						QueControl();
					}
					break;
					case 6: //процедура вывода одного символа из памяти программ
					c = OutPMem();
					if(c==0){
						PoinProcRed++;
						StatusTransit = 0;
						TWCR = (1<<TWINT);
						QueControl();
					}
					break;
					case 7: //процедура вывода 5ти значного числа.
					c = PrintNum();
					if(c==0){ //вывели все цифры
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


//Процедура обработки очереди TWI. Пока задачи есть запускает обработку
void QueControl(){
	unsigned char Proc;
		__asm__ volatile("cli" ::: "memory");
		if(StatusTransit==0){ // если передача не идет.
			Proc = QueueProc[PoinProcRed];
			if(Proc!=0xFF){ // Пуста ли очередь?
			Processing(); // если не пуста запускаю по новой
			}
			else{ 	// сюда если очередь пустая.
				PoinProcRed = 0; // указатель для чтения из очереди обнуляем.
				QueueProc[PoinProcRed]=0xFF; // записываем что нет в очереди задач элементов
				StatusTransit = 0;
				PoinQueRed = 0; // номер читаемего элемента массива данных
				CountMasWr = 0; // Обнуляем номер элемента массива записи позиционирования каретки.
				PoinProc = 0; // Элемента массива для записи задач
				PoinQue=0;    // Элемент массива для записи данных
				CountMasPos = 0; // Элемент массива позиционирования для чтения
		}
		}
	__asm__ volatile("sei" ::: "memory");
}

ISR(TWI_vect){ // Прерывание от модуля TWI (Это для режима ведущий передатчик)
	//Нужно ли сохранять статус регистр и востанавливать потом? Посмотереть как это выполняется в
	//Дизасемблером
	switch(TWSR){
		case 0x08 :
		StatusTransit = 2; // был передан сигнал старт. Устанавливаю статус что передали старт
		Processing();
		break;
		
		case 0x10 : // повстарт тоже что и старт. После него передается адрес
		StatusTransit = 2;
		Processing();
		break;
		
		case 0x18 :
		StatusTransit = 6; // Устанавливаю флаг что адрес + бит (W) записи переданы.
		Processing();
		break;
		
		case 0x28 : // передан пакет данных и принято подтверждение
		StatusTransit = 6; //5 здесь изменил после передачи данных
		Processing();
		break;
		
		case 0x20 : // передан пакет а подтверждение не принято
		StatusTransit = 1 ;				// Что делаем в таком случае?
		Processing();					// 1. Можно посчитать повторные отправки адреса
		break;							// 2. Можно Отправить сигнал стоп и старт снова или повстарт или не обращать внимания
		
		case  0x30 : // передан пакет данных а подтверждение не принято
		StatusTransit = 3;
		Processing();
		break;
		
		case 0x38 : // потеря приоритета при передачи ЧТО БУДЕМ ДЕЛАТЬ?
		StatusTransit = 7;
		Processing();
		break;
	}
}


#endif
//=======================================================================
//SPI
#ifdef BatSPIM
//Процедура обработки очереди SPI
//Сюда переходим только из контроллера очереди SPIQueContrl()
void ProcSPI(){
	unsigned char Proc;
	char (*TaskSPI)(); // указатель на процедуру?
	char c;
	Proc=SPIQue[ReadQueSPI]; // Беру задачу из массива.
	if(Proc!=0xFF){ //задачи еще есть
		TaskSPI=PtrTask[Proc]; // получаю адрес процедуры
		c=TaskSPI(); // запускаю процедуру
		if(c==0){ // передача окночена в зависимости от того какая задача юзалась сдвигаю массив
			if(Proc==0){ // Отправка команды завершилась SendMod();
				ReadQueSPI +=2;
			}
			else { // Отправка байт частоты завершилась SendFreq();
				ReadQueSPI +=5;
			}
			SPICondition=0; //передача не идет
			SPIQueContrl();
			return;
		}
		else { // продолжаю передачу
			SPICondition =1 ; // Указываю что идет передача
			return;
		}
	} //if Proc
	else { // cюда перешли значит очередь пустая
		SPICondition=2;
		SPIQueContrl();
	}
	return;
}

//Контроллер  очереди. Очищает очередь если завершили передачу. Либо вызывает обработчик очреди
void SPIQueContrl(){
	if(SPICondition==0){// Передача не идет
		ProcSPI();
	}
	else{
		if(SPICondition==2){ // Очередь пуста очистка очереди
			SPICondition=0; // Передача не идет
			ReadQueSPI=0;
			WriteQueSPI=0;
			SPIQue[WriteQueSPI]=0xFF;
		}
		//Передача идет
	}
	return;
}
//Прерывание
ISR(SPI_STC_vect){ //Выполнена передача по SPI
	SPICondition=0; // Указываю что передача завершилась
	SPIQueContrl();
}
#endif

//По прерыванию от переполнения таймера счетчика запускаем обработчик очереди
//Либо проводим отсчеты наших переменных
//Отключать эту фигню после того как отсчитали время нажатия на кнопочку.

#ifdef EncoderM
ISR(TIMER0_OVF_vect){ 
		sec--;
		if(sec==0){ // закончили отсчет 
			EncoderPres();
		}
}
ISR(INT0_vect){ //Прерывание при повороте энкодера
	EncoderRet();
}
ISR(INT1_vect){ //Прерывание при нажатии на энкодер
	EncoderPres();
}
#endif
