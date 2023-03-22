#ifndef GUI_LABEL_ESP32_H
#define GUI_LABEL_ESP32_H

#include <TFT_eSPI.h>

#include <gui_element.h>

#include <functional>

class GUI_Label : public GUI_Element {
public:
    GUI_Label(TFT_eSPI *tft, String text, int x, int y, int font_size, int datum, unsigned int text_color = WHITE, unsigned int background_colour = BLACK, 
        std::function<void()> on_press_callback = [](){},
        std::function<void()> on_release = [](){},
        double padding_x = 0.0,
        double padding_y = 0.0
        );

    virtual void draw() override;
    void draw(unsigned int colour_override, unsigned int background_colour_override);
    virtual void undraw() override;
    virtual void set_y(int y) override;
    virtual void set_x(int x) override;
    virtual void set_w(int w) override;
    virtual void set_h(int h) override;
    virtual void set_text(String text); 
    virtual void on_release() override;
    virtual void on_press() override;
    virtual bool contains_point(int x, int y) override;
    virtual void set_on_release_callback(std::function<void()> on_release_callback);

    void set_font_size(int font_size);
    String get_text() { return text; }
    void set_padding_x(double padding_x);
    void set_padding_y(double padding_y);
    void set_text_colour(unsigned int text_colour) { this->text_color = text_colour; needs_redraw = true; }
private:
    // these have correction based on datum and are appropriate for "contains_point" and background drawing (unlike original x and y)
    int left_x, top_y; 
    int touch_left_x, touch_right_x, touch_top_y, touch_bottom_y;
    String text;
    int datum;
    unsigned int text_color;
    int font_size;
    double padding_x, padding_y;

    void update_touch_area();
};

#endif