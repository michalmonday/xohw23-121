#ifndef STATUS_DISPLAY_H
#define STATUS_DISPLAY_H


class StatusDisplay {
public:
    StatusDisplay(TFT_eSPI &tft, int size_x, int size_y, int x, int y, unsigned int text_color, unsigned int background_color);
    ~StatusDisplay();
    void set_status(String name, String value);
    void draw();
private:
    TFT_eSPI &tft;
    int size_x, size_y, x, y;
    unsigned int text_color, background_color;
    std::map<String, String> status;
};



#endif 