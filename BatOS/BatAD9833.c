/*
 * BatAD9833.c
 *
 * код для генератора частоты AD9833
 * Created: 02.04.2022 20:51:55
 *  Author: dima
 * Здесь процедуры вызываемые подпрограммами из BatOS. используемые для передачи байт управления на микросхему
 * AD9833 по SPI
 */ 
#include "BatAD9833.h"
#include "BatSPI.h"
#include <avr/io.h>

unsigned char CountFreq=0; //Переменная хранящая состояние выполнения процедур ниже.
unsigned char Mod=0; // глобальная переменная хранящая последнее состояние режима которое было отправлено 

unsigned char SPIQue[100]; // Очередь для вывода SPI используется в BatOS.
unsigned char ReadQueSPI=0; // Переменная хранит номер элемента для чтения из массива процедур
unsigned char WriteQueSPI=0; // переменная хранит номер элемента для чтения из массива процедур
//в микросхему AD9833

//Процедура отправки данных частоты на AD9833
//Возвращает 1 если передача еще длится
unsigned char SendFreq(){
	if(CountFreq<2){//зашли впервые
		if(CountFreq==0){ //Отправка старших байт команды
			PORTB &=~(1<<PORTB1); //Перевожу ногу в 0 для того чтобы микросхема AD9833 начала прием
			DSPDR(0b00100001);
			CountFreq++;
			return 1;
		}
		else {//Отправка младших байт команды
			DSPDR(0b00000000 | Mod);
			CountFreq++;
			return 1;
		}
	}
	else {
		if(CountFreq==2){//команду передали до того как сюда вошли
			PORTB |=(1<<PORTB1); // Говорю что дальше будет 2 слова
			BNOP(); //Перевожу ногу и жду
			PORTB &= ~(1<<PORTB1);
			BNOP();
			DSPDR(SPIQue[ReadQueSPI+(4-CountFreq)]); //вывожу первый байт частоты
			CountFreq++;
			return 1;
		}
		if(CountFreq<4){
			DSPDR(SPIQue[ReadQueSPI+(4-CountFreq)]); //вывожу первый байт частоты
			CountFreq++;
			return 1;
		}
		if(CountFreq<6){
			DSPDR(SPIQue[ReadQueSPI+(8-CountFreq)]); //вывожу первый байт частоты
			CountFreq++;
			return 1;
		}
		else {
			if(CountFreq<8){ //Еще не все передали
				if(CountFreq==6){// данные передали, передаем команду на включение
					PORTB |=(1<<PORTB1); // перевожу ногу в 1 сигнализируя что байты 
					//частоты переданы
					BNOP();
					PORTB &= ~(1<<PORTB1); //Перевожу ногу в 0 для того чтобы микросхема AD9833 начала прием
					BNOP();
					DSPDR(0b00000000);
					CountFreq++;
					return 1;
				}
				if(CountFreq==7){ //Вторая часть командного слова
					DSPDR(0b00000000 | Mod);
					CountFreq++;
					return 1;
				}
				else { // передаю байты частоты
					DSPDR(SPIQue[ReadQueSPI+(6-CountFreq)]);
					CountFreq++;
					return 1;
					}
				}
				// передача закончена
				CountFreq=0;
				PORTB |=(1<<PORTB1);
				return 0;
			}
		}		
}

//Процедура отправки слова режима на AD9833
// возвращает 1 если передача еще длится
unsigned char SendMod(){
	if(CountFreq<2){
		if(CountFreq==0){ //1 старший байт команды
		  PORTB &= ~(1<<PORTB1); //Перевожу ногу в 0 для того чтобы микросхема AD9833 начала прием
		  Mod=SPIQue[ReadQueSPI+1];
		  DSPDR(0b00000000);
		  CountFreq++;
		  return 1;
		}
		DSPDR(Mod); // 2й младший байт команды
		CountFreq++;
		return 1;
	}
	CountFreq=0;// команды установки режима переданы
	PORTB |=(1<<PORTB1); // Перевожу ноги в 1 значит передача закончена
	//ReadQueSPI +=2;
	return 0;
}