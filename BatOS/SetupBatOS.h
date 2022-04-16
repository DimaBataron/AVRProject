/*
 * SetupBatOS.h
 *
 * Created: 12.04.2022 12:25:16
 *  Author: dima
 * Директивами условной компиляции включаются модули.
 * Не используемый код не помещается в конечную программу что экономит место во Flash памяти
 */ 


#ifndef SETUPBATOS_H_
#define SETUPBATOS_H_
// AD9833
#define BatSPIM // Написать для использвования функций SPI
#define AD9833M // для использования микросхемы генератора частоты
#define SPILenTaskMas 2 // Длинна массива с адресами процедур на передачу по SPI

#define Sin		0	//Синусоидальный сигнал
#define Trian	2	//Треугольный
#define DAC		40	//Сигнал с входа ЦАП деленный на 2
#define DAC2    32	//Сигнал с входа ЦАП

//TWI
//#define BatTWIM // для использования функций TWI
//#define SSD1306M  //для включения экрана

//ENCODER & TIME
//#define EncoderM // подключения энкодера
//#define BatTimeM // для использования таймера
#endif /* SETUPBATOS_H_ */