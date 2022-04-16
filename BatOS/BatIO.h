/*
 *
 * Created: 15.01.2022 13:38:51
 * Author: dima
 */ 

//p - указатель     s - строка      c - один символ      d-5ти значное число< 65535
#ifndef BATIO_H_
char BPrintf(char Mod, char *MasOut  ,char Str, char Col); //Вывод массива символов char *MasOut 

void  QueuingSSDInit(); //Процедура постановки в очередь отправки инициализационных байт дисплея
void QueuingCleanSSD(unsigned char CountSymb); //Процедура постановки в очередь очистки экрана
void StartTWISSD1306(); // Процедура стартовой настройки модуля TWI для работы с экраном SSD1306
void QueuingOutPM(char *ProgMemor,char Str, char Col); //Процедура постановки вывода байта из памяти программ
void StartLC(); //Процедура установки указателя в начало
void StartSPIAD9833(); //Процедура стартовой настройки модуля SPI на работу
void SendFreqAD9833(unsigned long int Dec); // процедура постановки в очередь отправки частоты на AD9833
void SendModAD9833(unsigned char Mod);// отправка режима на микросхему AD9833
#endif
