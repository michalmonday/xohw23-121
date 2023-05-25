#ifndef GRAPHICS_ESP32_H
#define GRAPHICS_ESP32_H

#include <Arduino.h>
#include "colours.h"

#define GRAPHICS_TFT_ESPI 0
#define GRAPHICS_ARDUINO_GFX 1

// The purpose of this file is to provide a common interface for the chosen graphics library.

class Graphics {
public:
    virtual void init() = 0;
    virtual void fillScreen(int color) = 0;
    virtual void drawString(String text, int x, int y) = 0;
    virtual void drawLine(int x0, int y0, int x1, int y1, int color) = 0;
    virtual void fillRect(int x, int y, int w, int h, int color) = 0;
    virtual void drawRect(int x, int y, int w, int h, int color) = 0;
    virtual void drawFloat(float floatNumber, int decimal, int x, int y, int font) = 0;
    virtual void drawTriangle(int x0, int y0, int x1, int y1, int x2, int y2, int color) = 0;
    virtual void fillTriangle(int x0, int y0, int x1, int y1, int x2, int y2, int color) = 0;
    virtual int fontHeight() = 0;
    virtual int textWidth(String text) = 0;

    virtual void setTextSize(int size) = 0;
    virtual void setTextDatum(int datum) = 0;
    virtual void setTextColor(int color, int background_colour=BLACK) = 0;

    virtual int getTextSize() = 0;
    virtual int getTextColor() = 0;
    virtual int getTextDatum() = 0;
}; 

#endif