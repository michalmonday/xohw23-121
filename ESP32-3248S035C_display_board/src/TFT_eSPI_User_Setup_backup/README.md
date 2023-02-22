
This folder contains the User_Setup.h file that is specific to ESP32-3248S035C ("C" at the end stands for capacitive touch, as opposed to "R" for resistive touch) display/board like this:
https://www.aliexpress.com/item/1005004632953455.html

After installing TFT_eSPI library in Arduino IDE, copy the User_Setup.h file from this folder to the TFT_eSPI library folder (usually C:/Users/username/Documents/Arduino/libraries/TFT_eSPI/).

If using Platformio, after adding TFT_eSPI library to the project, the destination folder is `pynq_wrapper/ESP32-3248S035C_display_board/.pio/libdeps/esp32dev/TFT_eSPI`.

The file was obtained from this link:
http://www.jczn1688.com/zlxz?spm=a2g0o.detail.1000023.1.12b728fa1SVmBu