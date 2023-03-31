#include <touch.h>

/* USAGE:

#include "touch.h"
Touch touch; 
void setup() {
    touch.init();
}
void handle_touch() {
    touch.update();
    if (touch.was_released()) {
        Serial.printf("Touch: x=%d, y=%d\n", touch.get_x(), touch.get_y());
        touch.reset_last_touch();
    }
}

void loop() {
    handle_touch();
}

*/

// Pins corresponding to the ESP32-3248S035C board wiring (custom ones can be set in the "init" function)
#define DEFAULT_TOUCH_SDA  33
#define DEFAULT_TOUCH_SCL  32
#define DEFAULT_TOUCH_INT 36
#define DEFAULT_TOUCH_RST 25
#define DEFAULT_TOUCH_WIDTH  480
#define DEFAULT_TOUCH_HEIGHT 320

Touch::Touch() :
    touched(false), x(0), y(0), released(false), last_touch_time(0)
{
}

void Touch::init() { init(DEFAULT_TOUCH_SDA, DEFAULT_TOUCH_SCL, DEFAULT_TOUCH_INT, DEFAULT_TOUCH_RST, DEFAULT_TOUCH_WIDTH, DEFAULT_TOUCH_HEIGHT, ROTATION_LEFT); }
void Touch::init(int sda_pin, int scl_pin, int int_pin, int rst_pin, int width, int height, int rotation) {
    gt911 = new TAMC_GT911(sda_pin, scl_pin, int_pin, rst_pin, width, height);
    // gt911->reset();
    gt911->begin();
    gt911->setRotation(rotation);
}

void Touch::update() {
    gt911->read();
    if (gt911->isTouched){
        x = gt911->points[0].x;
        y = gt911->points[0].y;
        // Serial.printf("gt911: x=%d, y=%d\n", gt911->points[0].x, gt911->points[0].y);

        // for (int i=0; i<gt911->gt911es; i++){
        //     Serial.print("gt911 ");Serial.print(i+1);Serial.print(": ");;
        //     Serial.print("  x: ");Serial.print(gt911->points[i].x);
        //     Serial.print("  y: ");Serial.print(gt911->points[i].y);
        //     Serial.print("  size: ");Serial.println(gt911->points[i].size);
        //     Serial.println(' ');
        // }
        released = false; 
        touched = true;
        if (last_touch_time == 0) {
            pressed = true;
        }
        last_touch_time = millis();
    } else if (touched && millis() - last_touch_time > 50) {
        released = true;
        touched = false;
        pressed = false;
    }
}

bool Touch::was_released() {
    return released;
}

bool Touch::was_pressed() {
    return pressed;
}

bool Touch::is_touched() {
    return touched;
}

std::tuple<int, int> Touch::get_pos() {
    return std::make_tuple(x, y);
}

int Touch::get_x() {
    return x;
}

int Touch::get_y() {
    return y;
}

void Touch::reset_last_release() {
    released = false;
    last_touch_time = 0;
}

void Touch::reset_last_press() {
    pressed = false;
}