#include <gui_element.h>

// -------------------------------
// ---------- GUI_Element ----------
GUI_Element::GUI_Element(TFT_eSPI *tft, int x, int y, int w, int h, unsigned int background_colour,std::function<void()> on_press_callback, std::function<void()> on_release_callback) : 
    tft(tft), x(x), y(y), w(w), h(h), background_colour(background_colour), needs_redraw(true), on_release_callback(on_release_callback), on_press_callback(on_press_callback), background_enabled(true)
{
}

GUI_Element::~GUI_Element() {
    for (auto child_element : child_elements) {
        delete child_element;
    }
}

void GUI_Element::draw() {
    if (background_enabled)
        tft->fillRect(x, y, w, h, background_colour);
    // tft->drawRect(x, y, w, h, TFT_WHITE); 
    needs_redraw = false;

    for (auto child_element : child_elements) {
        child_element->draw();
    }
}

void GUI_Element::undraw() {
    needs_redraw = true;
    for (auto child_element : child_elements) {
        child_element->undraw();
    }
}

void GUI_Element::on_press() {
    on_press_callback();
}

void GUI_Element::on_release() {
    on_release_callback();
}

void GUI_Element::add_child_element(GUI_Element *child_element) {
    if (child_element == nullptr) {
        Serial.println("ERROR: GUI_Element::add_child_element() - child_element is nullptr");
        return;
    }
    // add element if it doesn't already exist
    if (std::find(child_elements.begin(), child_elements.end(), child_element) == child_elements.end()) {
        child_elements.push_back(child_element);
    }
}

GUI_Element* GUI_Element::get_child_element_containing_point(int point_x, int point_y) {
    for (auto child_element : child_elements)
        if (child_element->contains_point(point_x, point_y))
            return child_element;
    return nullptr;
}