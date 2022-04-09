/*
 * BatAD9833.h
 *
 * Created: 02.04.2022 21:03:03
 *  Author: dima
 */ 
//Добавлю макрос ожидания. (пустые инстукции)

#define BNOP() ( {\
	__asm__ volatile("nop\n\t" "nop\n\t" :::"memory");\
})

// возвращает 1 если передача еще длится
unsigned char SendMod(); //процедура отправки слова режима на AD9833

unsigned char SendFreq(); //Процедура отправки данных частоты на AD9833