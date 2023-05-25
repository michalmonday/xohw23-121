#include "display_config.h"
#include <Arduino.h>

// void init_display(TFT_eSPI &tft, float brightness) {
//     // brightness is a value between 0 and 1
//     tft.begin();
//     tft.fillScreen(TFT_BLACK);
//     // tft.setRotation(1); // landscape
//     tft.setRotation(3); // landscape, upside downh
// 
//     pinMode(ST7796_PIN_BL, OUTPUT); // Backlight
//     ledcSetup(ST7796_PWM_CHANNEL_BL, ST7796_PWM_FREQ_BL, ST7796_PWM_BITS_BL);
//     ledcAttachPin(ST7796_PIN_BL, ST7796_PWM_CHANNEL_BL);
// 
//     set_display_brightness(brightness);
// }
// 
// void set_display_brightness(float brightness) {
//     ledcWrite(ST7796_PWM_CHANNEL_BL, ST7796_PWM_MAX_BL * brightness);
//     // ledcWrite(ST7796_PWM_CHANNEL_BL, (1<<31)-1);
// }