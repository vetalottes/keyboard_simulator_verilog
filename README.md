# keyboard_simulator_verilog - Клавиатурный тренажер на языке описания аппаратуры Verilog с выводом на VGA

В основе модуля клавиатурного тренажера FIB лежит сравнение двух символов: эталонного символа тренажера, который должен отображаться на дисплее, и
нажатого пользователем символа клавиатуры. В результате эталонный элемент или остается прежним при неверном нажатии, либо иначе меняется на новое.

Для работы клавиатуры по протоколу PS/2 нужно два модуля - ресивер (RECIEVER_pc2) и дешифратор (DC_pc2). Они связаны между собой тем, что модуль ресивер считывает входные
сигналы с клавиатуры и объединяет их в пакет данных PS/2 recieved_data, который впоследствии будет расшифрован дешифратором, в зависимости от входного значения pc2-data
(из предыдущего модуля ps2_reciever) при помощи оператора множественного выбора case, где описаны коды клавиш.

Для отображения информации на мониторе необходим интерфейс VGA. Сигнал формата VGA представляет собой компонентный сигнал RGBHV (сигнал RGB + синхронизация «по
горизонтали» + синхронизация «по вертикали»). Потребуется 4 модуля: модуль горизонтальной и вертикальной синхронизации vga, модуль делителя частоты CLK_DIV, модуль формирования изображения\символов chars с помощью 1 и 0 и управляющий тремя вышеперечисленными модуль top_vga. 

Для совместной работы модулей создан модуль верхнего уровня DEVICE.
Для организации связи портов модуля верхнего уровня с контактами ПЛИС добавлен файл проектных ограничений

Подробности в файле pdf.
