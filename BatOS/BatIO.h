/*
//BatIO.h
 *
Created: 15.01.2022 13:38:51
 Author: dima
 */ 
//s - строка
//c - один символ
//p - указатель 
char BPrintf(char Mod, char *MasOut,char Str, char Col); //Вывод массива символов

void  QueuingSSDInit(); //Процедура постановки в очередь отправки инициализационных байт дисплея
void QueuingCleanSSD(unsigned char CountSymb); //Процедура постановки в очередь очистки экрана
void StartTWISSD1306(); // Процедура стартовой настройки модуля TWI для работы с экраном SSD1306
void QueuingOutPM(char *ProgMemor); //Процедура постановки вывода байта из памяти программ