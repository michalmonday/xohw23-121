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

// // Pins corresponding to the ESP32-3248S035C board wiring (custom ones can be set in the "init" function)
// #define DEFAULT_TOUCH_SDA  33
// #define DEFAULT_TOUCH_SCL  32
// #define DEFAULT_TOUCH_INT 36
// #define DEFAULT_TOUCH_RST 25
// #define DEFAULT_TOUCH_WIDTH  480
// #define DEFAULT_TOUCH_HEIGHT 320

#define DEFAULT_TOUCH_SDA  19
#define DEFAULT_TOUCH_SCL  20
#define DEFAULT_TOUCH_INT -1
#define DEFAULT_TOUCH_RST 38
#define DEFAULT_TOUCH_WIDTH  800
#define DEFAULT_TOUCH_HEIGHT 480

Touch::Touch() :
    touched(false), x(0), y(0), released(false), last_touch_time(0)
{
}

// TAMC_GT911 *gt911_ = new TAMC_GT911(DEFAULT_TOUCH_SDA, DEFAULT_TOUCH_SCL, DEFAULT_TOUCH_INT, DEFAULT_TOUCH_RST, DEFAULT_TOUCH_WIDTH, DEFAULT_TOUCH_HEIGHT);

void Touch::init() { init(DEFAULT_TOUCH_SDA, DEFAULT_TOUCH_SCL, DEFAULT_TOUCH_INT, DEFAULT_TOUCH_RST, DEFAULT_TOUCH_WIDTH, DEFAULT_TOUCH_HEIGHT, ROTATION_LEFT); }
void Touch::init(int sda_pin, int scl_pin, int int_pin, int rst_pin, int width, int height, int rotation) {
    Serial.println("Touch::init()");
    // return;
    // gt911 = new TAMC_GT911(DEFAULT_TOUCH_SDA, DEFAULT_TOUCH_SCL, DEFAULT_TOUCH_INT, DEFAULT_TOUCH_RST, DEFAULT_TOUCH_WIDTH, DEFAULT_TOUCH_HEIGHT);
    gt911 = new TAMC_GT911(sda_pin, scl_pin, int_pin, rst_pin, width, height);
    // gt911->reset();
    gt911->begin();

    // gt911->begin(GT911_ADDR1);

    // // Need to solve floating INT pin so on reset changes between the 2 addresses
    // Wire.beginTransmission(GT911_ADDR1);
    // Wire.write(highByte(GT911_PRODUCT_ID));
    // Wire.write(lowByte(GT911_PRODUCT_ID));
    // Wire.endTransmission();
    // //returns rxLength - if 0 we have a problem
    // uint8_t returnSize = Wire.requestFrom(GT911_ADDR1, (uint8_t)1); 
    // if (returnSize == 0) {
    //     Serial.println("Setting address to ADDR2");
    //     // restart with other address
    //     gt911->begin(GT911_ADDR2);
    // }

    gt911->setRotation(rotation);
}

void Touch::update() {
    Serial.println("Touch::update()");
    // return;
    gt911->read();
    if (gt911->isTouched){
        x = gt911->points[0].x;
        y = gt911->points[0].y;
        Serial.printf("gt911: x=%d, y=%d\n", gt911->points[0].x, gt911->points[0].y);

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