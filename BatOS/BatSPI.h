/*
 * BatSPI.h
 * Функции для рботы с модулем SPI микроконтроллера Atmega328P
 * Created: 15.01.2022 14:20:41
 *  Author: dima
 */ 
//Определяю макрос для вывода данных
#define DSPDR(a) (SPDR=a)
//Процедура настройки ног на передачу
void SPIConfigPort();
//Настройка скорости передачи и модуля SPI
void SPIConfig(unsigned char SPCRB, unsigned char SPI2xS );
//Процедура записи данных для передачи по SPI Заменил макросом
//void BSPDR(unsigned char DSPDR);

