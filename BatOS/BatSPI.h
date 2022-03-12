/*
 * BatSPI.h
 * Функции для рботы с модулем SPI микроконтроллера Atmega328P
 * Created: 15.01.2022 14:20:41
 *  Author: dima
 */ 
//Процедура подготовки МК на передачу по SPI
//Пример
//SPIConfig(0,0b11111001);
void SPIConfig(char SPI2xS,char SPCRB);