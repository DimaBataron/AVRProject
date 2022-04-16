/*
 * BatTWI.c
 *
 * Created: 15.01.2022 19:29:44
 *  Author: dima
 */ 
#include "BatTWI.h"
#include "SetupBatOS.h"
#include <avr/io.h> //Описание всех регистров и портов контроллера

#ifdef BatTWIM
char CountTrMasByte = 0; // переменная содержит количество уже переданных байт

//ДОБАВИТЬ ПРОЦЕДУРУ НАСТРОЙКИ ПЕРЕДАЧИ 
//Стартовый сигнал
void SSisTWI(){
	TWCR = 0b10100101; //формируем состояние старт
}

//Сигнал остановки передачи
void StopSigTWI(){
	TWCR = 0b10010101; //формирование состояния стоп на шине TWI
}

//Передача адреса устройства
void TrAdr(char Adr){
	TWDR = Adr;
	TWCR = 0b10000101; //старт передачи адресного пакета
}

//Настройка ног на передачу и прием по TWI
void ConTWIPort(){
		DDRC |= 0b00110000; //направление передачи данных 1 выход
		PORTC |=0b00110000; //переводим ноги в 1.
}
//Передача байта
void TrByte(char Data){
	TWDR = Data;
	TWCR = 0b10000101; //Продолжаем передачу
}

//Передача массива байт (ВЫЗЫВАЕТСЯ ПОВТОРНО)
// MasData массив байт
// NumberSym количество передаваемых байт
// Возвращает 1 когда передача завершеена, 0 когда нет.
// Не будет ошибки т.к. не используется параллельно
char TrMasByte(char *MasData){
	char Sym = MasData[CountTrMasByte];
	if(Sym ==0)
	{
		CountTrMasByte=0;
		return 1;	
	}
	else{
		TrByte(Sym);
		CountTrMasByte++;
		return 0;
	}
}
#endif