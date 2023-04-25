#include <graphics_arduino_gfx.h>

#define GFX_BL DF_GFX_BL // default backlight pin, you may replace DF_GFX_BL to actual backlight pin
#define TFT_BL 2

/* More data bus class: https://github.com/moononournation/Arduino_GFX/wiki/Data-Bus-Class */
//Arduino_DataBus *bus = create_default_Arduino_DataBus();

/* More display class: https://github.com/moononournation/Arduino_GFX/wiki/Display-Class */
//Arduino_GFX *gfx = new Arduino_ILI9341(bus, DF_GFX_RST, 0 /* rotation */, false /* IPS */);

Arduino_ESP32RGBPanel *bus = new Arduino_ESP32RGBPanel(
    GFX_NOT_DEFINED /* CS */, GFX_NOT_DEFINED /* SCK */, GFX_NOT_DEFINED /* SDA */,
    41 /* DE */, 40 /* VSYNC */, 39 /* HSYNC */, 42 /* PCLK */,
    14 /* R0 */, 21 /* R1 */, 47 /* R2 */, 48 /* R3 */, 45 /* R4 */,
    9 /* G0 */, 46 /* G1 */, 3 /* G2 */, 8 /* G3 */, 16 /* G4 */, 1 /* G5 */,
    15 /* B0 */, 7 /* B1 */, 6 /* B2 */, 5 /* B3 */, 4 /* B4 */
);
// option 1:
// 7寸 50PIN 800*480
static Arduino_RPi_DPI_RGBPanel *gfx = new Arduino_RPi_DPI_RGBPanel(
  bus,
//  800 /* width */, 0 /* hsync_polarity */, 8/* hsync_front_porch */, 2 /* hsync_pulse_width */, 43/* hsync_back_porch */,
//  480 /* height */, 0 /* vsync_polarity */, 8 /* vsync_front_porch */, 2/* vsync_pulse_width */, 12 /* vsync_back_porch */,
//  1 /* pclk_active_neg */, 16000000 /* prefer_speed */, true /* auto_flush */);

    800 /* width */, 0 /* hsync_polarity */, 210 /* hsync_front_porch */, 30 /* hsync_pulse_width */, 16 /* hsync_back_porch */,
    480 /* height */, 0 /* vsync_polarity */, 22 /* vsync_front_porch */, 13 /* vsync_pulse_width */, 10 /* vsync_back_porch */,
    1 /* pclk_active_neg */, 16000000 /* prefer_speed */, true /* auto_flush */);


Graphics_Arduino_GFX::Graphics_Arduino_GFX() {
}

Graphics_Arduino_GFX::~Graphics_Arduino_GFX() {
}

// void set_display_brightness(float brightness) {
//     // not implemented yet for Arduino GFX
// }

void Graphics_Arduino_GFX::init() { 
    gfx->begin();
    gfx->fillScreen(BLACK);

#ifdef TFT_BL
    pinMode(TFT_BL, OUTPUT);
    digitalWrite(TFT_BL, HIGH);
#endif

    gfx->setCursor(10, 10);
    gfx->setTextColor(RED);
    gfx->println("Hello World!");

    delay(2000); 

    // brightness is a value between 0 and 1
    // tft = new TFT_eSPI();
    // tft->begin();
    // tft->fillScreen(TFT_BLACK);
    // // tft.setRotation(1); // landscape
    // tft->setRotation(3); // landscape, upside downh
}

void Graphics_Arduino_GFX::fillScreen(int color) { gfx->fillScreen(color); }
void Graphics_Arduino_GFX::drawString(String text, int x, int y) {
    // Serial.printf("drawString: %s, %d, %d\n", text.c_str(), x, y);
    // tft->drawString(text, x, y); 
    Serial.printf("(NOT IMPLEMENTED) drawString: %s, %d, %d\n", text.c_str(), x, y);
    // gfx->drawString(text, x, y);
    gfx->setCursor(x, y);
    gfx->print(text);
}
void Graphics_Arduino_GFX::drawLine(int x0, int y0, int x1, int y1, int color) { 
    Serial.printf("drawLine: %d, %d, %d, %d, %d\n", x0, y0, x1, y1, color);
    gfx->drawLine(x0, y0, x1, y1, color); 
}
void Graphics_Arduino_GFX::fillRect(int x, int y, int w, int h, int color) { gfx->fillRect(x, y, w, h, color); }
void Graphics_Arduino_GFX::drawRect(int x, int y, int w, int h, int color) { gfx->drawRect(x, y, w, h, color); }
void Graphics_Arduino_GFX::drawFloat(float floatNumber, int decimal, int x, int y, int font) {
    // gfx->drawFloat(floatNumber, decimal, x, y, font); 
    gfx->setCursor(x, y);
    gfx->printf("%f", floatNumber);
}
void Graphics_Arduino_GFX::drawTriangle(int x0, int y0, int x1, int y1, int x2, int y2, int color) { gfx->drawTriangle(x0, y0, x1, y1, x2, y2, color); }
void Graphics_Arduino_GFX::fillTriangle(int x0, int y0, int x1, int y1, int x2, int y2, int color) { gfx->fillTriangle(x0, y0, x1, y1, x2, y2, color); }
int Graphics_Arduino_GFX::fontHeight() {
    int16_t x1, y1; uint16_t w, h;
    gfx->getTextBounds("H", (int16_t)0, (int16_t)0, &x1, &y1, &w, &h);
    return h;
    // return gfx->fontHeight(); 
}
int Graphics_Arduino_GFX::textWidth(String text) { 
    int16_t x1, y1; uint16_t w, h;
    gfx->getTextBounds(text, (int16_t)0, (int16_t)0, &x1, &y1, &w, &h);
    return w; 
}
void Graphics_Arduino_GFX::setTextSize(int size) { gfx->setTextSize(size); }
void Graphics_Arduino_GFX::setTextDatum(int datum) {
    Serial.printf("(NOT IMPLEMENTED) setTextDatum: %d\n", datum);
    // gfx->setTextDatum(datum); 
}
void Graphics_Arduino_GFX::setTextColor(int color, int background_colour) { 
    text_color = color;
    gfx->setTextColor(color, background_colour); 
}
int Graphics_Arduino_GFX::getTextSize() { 
    return fontHeight();
}
int Graphics_Arduino_GFX::getTextColor() { 
    return text_color; 
}
int Graphics_Arduino_GFX::getTextDatum() { 
    Serial.println("(NOT IMPLEMENTED) getTextDatum, returning 0");
    return 0;
}
