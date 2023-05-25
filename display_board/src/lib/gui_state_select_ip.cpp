#include <gui_state_select_ip.h>
#include <display_config.h>
#include <colours.h>
#include <globals.h>

GUI_State_Select_IP::GUI_State_Select_IP(Graphics *gfx, GUI *gui, Touch *touch) 
    : GUI_State(gfx, gui, touch), on_ip_selected_callback([](IPAddress ip){})
{
    // 17 parts:
    // - 1 empty
    // - 3 digits
    // - 1 dot
    // - 3 digits
    // - 1 dot
    // - 3 digits
    // - 1 dot
    // - 3 digits
    // - 1 empty

    int x_offset = RESOLUTION_X / 17;
    const int x_start = x_offset * 1.5; // first drawn item position (middle of it)
    const int y_pos = RESOLUTION_Y / 2;
    int x_pos = x_start;

    const int triangle_w = x_offset;
    const int triangle_h = triangle_w * 1.5;
    const int triangle_offset = RESOLUTION_Y * 0.1;
    const unsigned int triangle_fill_colour = BLACK;
    const unsigned int triangle_border_colour = WHITE;

    // ---------------------------------------
    // -------- each byte if IP --------------
    for (int i = 0; i < 4; i++) {
        // for each digit in byte
        for (int j = 0; j < 3; j++) {
            // digit labels
            GUI_Label *label = new GUI_Label(gfx, "-", x_pos, y_pos, font_size, MC_DATUM, WHITE, BLACK);
            labels.push_back(label);
            add_element(label);

            int digit_index = i*3 + j;

            // triangles
            GUI_Triangle *triangle_up = new GUI_Triangle(gfx, GUI_TRIANGLE_ROTATION_UP, x_pos, y_pos - triangle_offset, triangle_w, triangle_h, BC_DATUM, triangle_border_colour, triangle_fill_colour, BLACK, 
                [this, digit_index]() {
                    digit_up(digit_index);
                }
            );

            GUI_Triangle *triangle_down = new GUI_Triangle(gfx, GUI_TRIANGLE_ROTATION_DOWN, x_pos, y_pos + triangle_offset, triangle_w, triangle_h, TC_DATUM, triangle_border_colour, triangle_fill_colour, BLACK, 
                [this, digit_index]() {
                    digit_down(digit_index);
                }
            );
            if (label == NULL || triangle_up == NULL || triangle_down == NULL) {
                Serial.println("Failed to allocate memory for GUI_State_Select_IP");
            }
            add_element(triangle_up);
            add_element(triangle_down);

            x_pos += x_offset;
        }

        if (i == 3) {
            continue;
        }
        // dot label (without triangle)

        // digit labels
        GUI_Label *label_dot = new GUI_Label(gfx, ".", x_pos, y_pos, font_size, MC_DATUM, WHITE, BLACK);
        labels_dots.push_back(label_dot);
        add_element(label_dot);
        x_pos += x_offset;
    }
    // set_ip(tcp_server_ip);

    // --------------------------------
    // --------- OK button ------------
    const int btn_ok_font_size = 2;
    gfx->setTextSize(btn_ok_font_size);
    int btn_ok_font_height = gfx->fontHeight();

    int btn_ok_h = btn_ok_font_height + btn_ok_font_height * DEFAULT_BTN_PADDING_Y*2;
    const int btn_ok_w = gfx->textWidth("OK") + btn_ok_font_height * DEFAULT_BTN_PADDING_X*2;
    btn_ok = new GUI_Button(gfx, "OK", RESOLUTION_X - btn_ok_w*1.2, RESOLUTION_Y - btn_ok_h*1.2, btn_ok_w, btn_ok_h, btn_ok_font_size, WHITE, BLACK, 
        [](){},
        [gui, this]() { 
            on_ip_selected_callback(get_ip());
        }
    );
    if (btn_ok == NULL) {
        Serial.println("Failed to allocate memory for GUI_State_Select_IP");
    }
    add_element(btn_ok);
}

void GUI_State_Select_IP::update_label_colour(int index) {
    if (labels[index]->get_text()[0] == '0')
        labels[index]->set_text_colour(DKGREY);
    else
        labels[index]->set_text_colour(WHITE);
}

void GUI_State_Select_IP::update_labels_colour() {
    // for each byte in IP
    // for (int i = 0; i < 4; i++) {
    //     String byte_str = labels[i]->get_text();
        // for each digit in byte

    // }
    // bool non_zero_found = false;
    // for (int i = 0; i < 16; i++) {
    //     int digit = labels[i]->get_text()[0] - '0';
    //     if (digit != 0 && !non_zero_found)
    //         non_zero_found = true;
    //     if (non_zero_found)
    //         labels[i]->set_text_colour(WHITE); 
    //     else
    //         labels[i]->set_text_colour(DKGREY);
    // }
}

void GUI_State_Select_IP::digit_up(int index) {
    int old_digit = labels[index]->get_text()[0] - '0';
    int new_digit = (old_digit+1) % 10;
    labels[index]->set_text(String(new_digit));
    if (old_digit == 0 || new_digit == 0)
        update_labels_colour();
}

void GUI_State_Select_IP::digit_down(int index) {
    int old_digit = labels[index]->get_text()[0] - '0';
    int new_digit = (old_digit-1) % 10;
    if (new_digit < 0)
        new_digit = 9;
    labels[index]->set_text(String(new_digit));
    if (old_digit == 0 || new_digit == 0)
        update_labels_colour();
}

void GUI_State_Select_IP::reset() {
    GUI_State::reset();
}

void GUI_State_Select_IP::update() {
    GUI_State::update();
}

void GUI_State_Select_IP::draw() {
    GUI_State::draw();
}

void GUI_State_Select_IP::set_ip(IPAddress ip) {
    // for each byte in IP
    for (int i = 0; i < 4; i++) {
        // convert byte value to string with length of 3 (padded with leading 0s)
        String byte_str = String(ip[i]);
        while (byte_str.length() < 3) 
            byte_str = "0" + byte_str;
        // for each digit in byte
        for (int j = 0; j < 3; j++) {
            labels[i*3+j]->set_text(String(byte_str[j]));
        }
    }
    update_labels_colour();
}

IPAddress GUI_State_Select_IP::get_ip() {
    IPAddress ip;
    // for each byte in IP
    for (int i = 0; i < 4; i++) {
        String byte_str = "0";
        // for each digit in byte
        for (int j = 0; j < 3; j++) {
            byte_str += labels[i*3+j]->get_text();
        }
        byte byte_val = strtoul(byte_str.c_str(), NULL, 10);
        ip[i] = byte_val;
    }
    return ip; 
}

void GUI_State_Select_IP::on_state_enter() {
    GUI_State::on_state_enter();
    Serial.println("GUI_State_Select_IP on_state_enter");
}

void GUI_State_Select_IP::on_state_exit() {
    GUI_State::on_state_exit();
    Serial.println("GUI_State_Select_IP on_state_exit");
}
