//Прошилась после двойного нажатия на сброс на micro.
//Программируем micro используя nano как программатор
//Arduino/hardware/arduino/avr/boards.txt именил строку pro.menu.cpu.16MHzatmega328.upload.speed=19200   
// Эти строки добавил, и не удалял но среда при прошивки пишет предостережение
//pro5v328.name=Arduino Pro or Pro Mini (5V, 16 MHz)          
//pro5v328.upload.speed=19200


// В среде настройки Инструменыт-> Плата: Arduino pro or Pro Mini
// Процессор :vAtmega328P
// Программатор: Arduino as ISP;
// Для загрузки Скетч->Загрузить через программатор
//В micro загружена прогрмма  Файл-> Примеры-> ArduinoISP

//Подключение программатора GND-GND; D10 nano к rst micro;
//D12-12; D11-11; D13-13


//ко второму Pin подключаем кнопу. Далее резистор 10к и на заемлю
// со второй сроны к кнопке Vcc;

void setup() {
  // put your setup code here, to run once:
  pinMode(2,INPUT); // установим на второй пин кнопку
  pinMode(13,OUTPUT); //13 это встроеный LED
  pinMode(0,OUTPUT);
}
int var = 0,old_state1=0,ONOF,pred=0;
void loop() {
  // put your main code here, to run repeatedly:
  var = digitalRead(2); //читаем значение с цифрогово пина 2.
  if(var == HIGH && pred==LOW ) //если var высокое и предыдущее состояние низкое 
  {// если лампочка выключена 
    if(old_state1==LOW) // если при последнем заходе в этот цикл лампочку включили
    {
      ONOF=HIGH;
    }
    if(old_state1==HIGH) // если выключили
    {
      ONOF=LOW;
    }
    old_state1=ONOF;
   }
  digitalWrite(13,ONOF);
  analogWrite(0,ONOF*244);
  delay(100);
  pred=var; // если в этом цикле лапмочку включили
  // при последующем ничего не произойдет
  // т.е. следующий пройдет в холостую
}
