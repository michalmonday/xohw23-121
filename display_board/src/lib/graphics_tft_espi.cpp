#include <graphics_tft_espi.h>

TFT_eSPI tft_ = TFT_eSPI();

Graphics_TFT_ESPI::Graphics_TFT_ESPI() {
    tft = &tft_;
}

Graphics_TFT_ESPI::~Graphics_TFT_ESPI() {
    delete tft;
}

void set_display_brightness(float brightness) {
    ledcWrite(ST7796_PWM_CHANNEL_BL, ST7796_PWM_MAX_BL * brightness);
    // ledcWrite(ST7796_PWM_CHANNEL_BL, (1<<31)-1);
}

void Graphics_TFT_ESPI::init() { 
    // brightness is a value between 0 and 1
    // tft = new TFT_eSPI();
    tft->begin();
    tft->fillScreen(TFT_BLACK);
    // tft.setRotation(1); // landscape
    tft->setRotation(3); // landscape, upside downh

    pinMode(ST7796_PIN_BL, OUTPUT); // Backlight
    ledcSetup(ST7796_PWM_CHANNEL_BL, ST7796_PWM_FREQ_BL, ST7796_PWM_BITS_BL);
    ledcAttachPin(ST7796_PIN_BL, ST7796_PWM_CHANNEL_BL);

    set_display_brightness(1.0f);
}

void Graphics_TFT_ESPI::fillScreen(int color) { tft->fillScreen(color); }
void Graphics_TFT_ESPI::drawString(String text, int x, int y) {
    // Serial.printf("drawString: %s, %d, %d\n", text.c_str(), x, y);
    // tft->drawString(text, x, y); 
    Serial.printf("drawString: %s, %d, %d\n", text.c_str(), x, y);
    tft->drawString(text, x, y);
}
void Graphics_TFT_ESPI::drawLine(int x0, int y0, int x1, int y1, int color) { 
    Serial.printf("drawLine: %d, %d, %d, %d, %d\n", x0, y0, x1, y1, color);
    tft->drawLine(x0, y0, x1, y1, color); 
}
void Graphics_TFT_ESPI::fillRect(int x, int y, int w, int h, int color) { tft->fillRect(x, y, w, h, color); }
void Graphics_TFT_ESPI::drawRect(int x, int y, int w, int h, int color) { tft->drawRect(x, y, w, h, color); }
void Graphics_TFT_ESPI::drawFloat(float floatNumber, int decimal, int x, int y, int font) { tft->drawFloat(floatNumber, decimal, x, y, font); }
void Graphics_TFT_ESPI::drawTriangle(int x0, int y0, int x1, int y1, int x2, int y2, int color) { tft->drawTriangle(x0, y0, x1, y1, x2, y2, color); }
void Graphics_TFT_ESPI::fillTriangle(int x0, int y0, int x1, int y1, int x2, int y2, int color) { tft->fillTriangle(x0, y0, x1, y1, x2, y2, color); }
int Graphics_TFT_ESPI::fontHeight() { return tft->fontHeight(); }
int Graphics_TFT_ESPI::textWidth(String text) { return tft->textWidth(text); }
void Graphics_TFT_ESPI::setTextSize(int size) { tft->setTextSize(size); }
void Graphics_TFT_ESPI::setTextDatum(int datum) { tft->setTextDatum(datum); }
void Graphics_TFT_ESPI::setTextColor(int color, int background_colour) { tft->setTextColor(color, background_colour); }
int Graphics_TFT_ESPI::getTextSize() { return tft->textsize; }
int Graphics_TFT_ESPI::getTextColor() { return tft->textcolor; }
int Graphics_TFT_ESPI::getTextDatum() { return tft->getTextDatum(); }