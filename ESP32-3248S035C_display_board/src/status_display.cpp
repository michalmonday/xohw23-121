
#include <Arduino.h>
#include <TFT_eSPI.h>
#include <SPI.h>
#include <map>

#include "status_display.h"

StatusDisplay::StatusDisplay(TFT_eSPI &tft, int size_x, int size_y, int x, int y, unsigned int text_color, unsigned int background_color) 
  : tft(tft), size_x(size_x), size_y(size_y), x(x), y(y), text_color(text_color), background_color(background_color) 
{

}
StatusDisplay::~StatusDisplay() {

}
void StatusDisplay::set_status(String key, String value) {
    status[key] = value;
    draw();
}
void StatusDisplay::draw() {
    tft.fillRect(x, y, size_x, size_y, background_color);
    if (status.size() == 0) 
        return;

    // peserve old settings
    unsigned int old_text_color = tft.textcolor;
    int old_text_size = tft.textsize;
    uint8_t old_datum = tft.getTextDatum();

    tft.setTextSize(1);
    tft.setTextDatum(TL_DATUM);

    int y_pos = y + 5;
    // draw text
    for (auto it = status.begin(); it != status.end(); ++it) {
        tft.setTextColor(text_color);
        tft.drawString(it->second, x + 5, y_pos);
        y_pos += 15;
    }

    // restore old settings
    tft.setTextColor(old_text_color);
    tft.setTextSize(old_text_size);
    tft.setTextDatum(old_datum);
}
