#ifndef TOUCH_ESP32_H
#define TOUCH_ESP32_H

#include <TAMC_GT911.h>
#include <tuple>

class Touch {
    public:
        Touch();
        void init();
        void init(int sda_pin, int scl_pin, int int_pin, int rst_pin, int width, int height, int rotation);
        void update();
        bool was_released();
        bool was_pressed();
        bool is_touched();
        std::tuple<int, int> get_pos();
        int get_x();
        int get_y();
        void reset_last_release();
        void reset_last_press();

    private:
        int x, y;
        bool touched; // true if the screen is currently being touched
        bool released; // true if the screen was just released
        bool pressed; // true if the screen was just pressed
        unsigned long last_touch_time;
        TAMC_GT911 *gt911; 
};

#endif 