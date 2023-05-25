#ifndef GRAPHICS_TFT_ESPI_ESP32_H
#define GRAPHICS_TFT_ESPI_ESP32_H

#include <graphics.h>
#include "colours.h"
#include <TFT_eSPI.h>

#define RESOLUTION_X 480
#define RESOLUTION_Y 320

#define ST7796_PIN_BL 27
#define ST7796_PWM_CHANNEL_BL 12
#define ST7796_PWM_FREQ_BL 5000
#define ST7796_PWM_BITS_BL 8
#define ST7796_PWM_MAX_BL ((1 << ST7796_PWM_BITS_BL) - 1)

extern void set_display_brightness(float brightness);
extern void init_display(TFT_eSPI &tft, float brightness);

class Graphics_TFT_ESPI : public Graphics {
public:
    Graphics_TFT_ESPI();
    ~Graphics_TFT_ESPI();
    void init() override;
    void fillScreen(int color) override;
    void drawString(String text, int x, int y) override;
    void drawLine(int x0, int y0, int x1, int y1, int color) override;
    void fillRect(int x, int y, int w, int h, int color) override;
    void drawRect(int x, int y, int w, int h, int color) override;
    void drawFloat(float floatNumber, int decimal, int x, int y, int font) override;
    void drawTriangle(int x0, int y0, int x1, int y1, int x2, int y2, int color) override;
    void fillTriangle(int x0, int y0, int x1, int y1, int x2, int y2, int color) override;
    int fontHeight() override;
    int textWidth(String text) override;
    void setTextSize(int size) override;
    void setTextDatum(int datum) override;
    void setTextColor(int color, int background_colour=BLACK) override;
    int getTextSize() override;
    int getTextColor() override;
    int getTextDatum() override;

private:
    TFT_eSPI *tft;
}; 

#endif