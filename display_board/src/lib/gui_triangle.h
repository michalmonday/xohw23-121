#ifndef GUI_TRIANGLE_H
#define GUI_TRIANGLE_H
#include <gui_element.h>

#include "graphics.h"

#define GUI_TRIANGLE_ROTATION_UP 0
#define GUI_TRIANGLE_ROTATION_RIGHT 1
#define GUI_TRIANGLE_ROTATION_DOWN 2
#define GUI_TRIANGLE_ROTATION_LEFT 3


class GUI_Triangle : public GUI_Element {
public:
    GUI_Triangle(Graphics *gfx, int rotation, int x, int y, int w, int h, int datum, unsigned int border_colour, unsigned int fill_colour, unsigned int background_colour = BLACK, std::function<void()> on_release_callback = [](){});
    virtual void draw() override;
    void draw(unsigned int fill_clr_override, unsigned int border_clr_override);
    virtual void undraw() override;
    virtual bool contains_point(int x, int y) override;
    void set_rotation(int rotation);
    void set_datum(int datum);
private:
    unsigned int border_colour;
    unsigned int fill_colour;
    int rotation;
    int x1, y1, x2, y2, x3, y3;
    int datum;
    void update_location_points();
};

#endif