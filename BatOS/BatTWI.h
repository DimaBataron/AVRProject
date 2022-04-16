/*
 * BatTWI.h
 *
 * Created: 15.01.2022 19:30:01
 * Возможно необходимо написать процедуры так что-бы они брали 
 * данные не через передаваемые программы а из массива данных процедур.
 *  Author: dima
 */ 
#ifndef BATTWI_H_
void SSisTWI();			//Отправка старт
void StopSigTWI();		//Отправка стоп
void TrAdr(char Adr);   //Отправка адреса
void ConTWIPort();      //Настройка ног на передачу
void TrByte(char Data); // Передача байта
char TrMasByte(char *MasData); //Передача массива байт
#endif