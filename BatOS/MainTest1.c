/*
 * MainTest1.c
 *
 * Created: 12.04.2022 14:05:40
 *  Author: dima
 */ 

#include "SetupBatOS.h"
#include "BatOS.h"

int main(){
	StartSPIAD9833();			//настраиваю spi на работу с AD9833
	
	SendFreqAD9833(500000); 	//передам на микросхему частоту в герцах 500000гц 500КГц

	SendModAD9833(Trian);		//Отправка режима
	/*
	Sin		0	//Синусоидальный сигнал
	Trian	2	//Треугольный
	DAC		32	//Сигнал с входа ЦАП
	DAC2    40	//Сигнал с входа ЦАП деленный на 2
	*/
	SPIQueContrl(); //Запуск обработчика очереди
	
	int i;
	while(1){
	i++;
	}
}
/*
;Программатор
;Белый Vin
;Серый Gnd
;Синий Rst
;Зеленый D11
;Фиолетовый D12
;Черный D13

;AD9833
;D11=DAT
;D9 =FNC
;D13=CLK
;VCC=2.3-5V
;
;
;SPI
;MOSI=	D11=PB3
;SCK=	D13=PB5
;SS     PB1 --> D9  (16bit)
;PC0-5 = A0-A5 Диоды; PC0младший
*/