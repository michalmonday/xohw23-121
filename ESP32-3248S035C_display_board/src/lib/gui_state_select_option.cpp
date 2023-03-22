#include <gui_state_select_option.h>
#include <display_config.h>
#include <gui.h>
#include <gui_button.h>
#include <communication_queues.h>

#include <cJSON.h>

GUI_State_Select_Option::GUI_State_Select_Option(TFT_eSPI *tft, GUI *gui, Touch *touch) : 
    GUI_State(tft, gui, touch), selected_option(""), selected_category(""), categories(), columns_taken(0), on_option_selected_callback([](String category, String option){})
{
}

void GUI_State_Select_Option::update() {
    GUI_State::update();

}

void GUI_State_Select_Option::add_options(String category, std::vector<String> options) {
    if (std::find(categories.begin(), categories.end(), category) == categories.end()) {
        columns_taken += 1;
        categories.push_back(category);
    } else {
        Serial.printf("Option category '%s' already exists\n", category.c_str());
    }


    // ---------------------------------
    // ------------ Buttons  -----------
    const int button_height = RESOLUTION_Y * 0.07;
    const int button_y_start = RESOLUTION_Y*0.05;
    const int button_font_size = 1;
    const int button_offset = button_height * 1.3;
    int button_y = button_y_start;
    int i;

    // longest option name width
    const int btn_width_padding = RESOLUTION_X * 0.01;
    int longest_option_name_width = 0;
    tft->setTextSize(button_font_size);
    for (String option : options) {
        int option_name_width = tft->textWidth(option.c_str(), button_font_size);
        if (option_name_width > longest_option_name_width) {
            longest_option_name_width = option_name_width;
        }
    }

    // const int button_width = RESOLUTION_X * 0.3;
    int button_width = longest_option_name_width + btn_width_padding * 2;
    int button_x = (RESOLUTION_X*0.05) + (button_width + RESOLUTION_X*0.05) * (categories.size()-1);

    for (String option : options) {
        if (button_y + button_height > RESOLUTION_Y) {
            button_y = button_y_start;
            button_x += button_width + RESOLUTION_X*0.05;
            columns_taken += 1;
        }
        GUI_Button *btn = new GUI_Button(tft, option, button_x, button_y, button_width, button_height, button_font_size,
            WHITE,  // text colour
            BLACK,  // background colour
            [](){}, // function on press
            [this, option, category](){   // function on release
                // change GUI state into option selection here or request the list of options from the server
                this->selected_option = option;
                this->selected_category = category;
                Serial.printf("Option %s was selected (%s category)\n", option.c_str(), category.c_str());
                // gui->revert_state();
                on_option_selected_callback(category, option);
            }
        );
        button_y += button_offset;
        add_element(btn);
    }
}

void GUI_State_Select_Option::on_state_enter() {
    GUI_State::on_state_enter();
    selected_option = "";
    selected_category = "";
    Serial.println("Select option state entered");
}

void GUI_State_Select_Option::on_state_exit() {
    GUI_State::on_state_exit();
    Serial.println("Select option state exited");
    categories.clear();
    destroy_and_clear_elements();
    columns_taken = 0;
}
