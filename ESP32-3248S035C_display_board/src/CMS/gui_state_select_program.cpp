#include <gui_state_select_program.h>
#include <display_config.h>
#include <gui.h>
#include <gui_button.h>
#include <communication_queues.h>

#include <cJSON.h>

GUI_State_Select_Program::GUI_State_Select_Program(TFT_eSPI *tft, GUI *gui, Touch *touch) : 
    GUI_State(tft, gui, touch), selected_program(""), selected_category(""), categories(), columns_taken(0)
{
}

void GUI_State_Select_Program::update() {
    GUI_State::update();

}

void GUI_State_Select_Program::add_programs(String category, std::vector<String> programs) {
    if (std::find(categories.begin(), categories.end(), category) == categories.end()) {
        columns_taken += 1;
        categories.push_back(category);
    } else {
        Serial.printf("Program category '%s' already exists\n", category.c_str());
    }


    // ---------------------------------
    // ------------ Buttons  -----------
    const int button_height = RESOLUTION_Y * 0.07;
    const int button_y_start = RESOLUTION_Y*0.05;
    const int button_font_size = 1;
    const int button_offset = button_height * 1.3;
    int button_y = button_y_start;
    int i;

    // longest program name width
    int longest_program_name_width = 0;
    for (String program : programs) {
        int program_name_width = tft->textWidth(program.c_str(), button_font_size);
        if (program_name_width > longest_program_name_width) {
            longest_program_name_width = program_name_width;
        }
    }

    // const int button_width = RESOLUTION_X * 0.3;
    int button_width = longest_program_name_width * 1.27;
    int button_x = (RESOLUTION_X*0.05) + (button_width + RESOLUTION_X*0.05) * (categories.size()-1);

    for (String program : programs) {
        if (button_y + button_height > RESOLUTION_Y) {
            button_y = button_y_start;
            button_x += button_width + RESOLUTION_X*0.05;
            columns_taken += 1;
        }
        GUI_Button *btn = new GUI_Button(tft, program, button_x, button_y, button_width, button_height, button_font_size,
            WHITE,  // text colour
            BLACK,  // background colour
            [](){}, // function on press
            [this, program, category](){   // function on release
                // change GUI state into program selection here or request the list of programs from the server
                this->selected_program = program;
                this->selected_category = category;
                Serial.printf("Program %s was selected (%s category)\n", program.c_str(), category.c_str());
                // gui->revert_state();

                cJSON *root = cJSON_CreateObject();
                cJSON *rpc_obj = cJSON_CreateObject();
                cJSON_AddItemToObject(root, "RPC", rpc_obj);
                cJSON_AddStringToObject(rpc_obj, "function_name", "rpc_load_program");
                // string array 
                const char *string_array[1] = {program.c_str()}; // TODO: check if not causing memory issues
                cJSON *function_args_obj = cJSON_CreateStringArray(string_array, 1);
                cJSON_AddItemToObject(rpc_obj, "function_args", function_args_obj);
                char *json_str = cJSON_PrintUnformatted(root);
                Serial.print("Sending: '");
                Serial.println(json_str);
                add_string_to_queue(queue_to_send, new String(json_str), true);
                free(json_str);
                gui->pop_state();
            }
        );
        button_y += button_offset;
        add_element(btn);
    }
}

void GUI_State_Select_Program::on_state_enter() {
    GUI_State::on_state_enter();
    selected_program = "";
    Serial.println("Main state entered");
}

void GUI_State_Select_Program::on_state_exit() {
    GUI_State::on_state_exit();
    Serial.println("Main state exited");
    categories.clear();
    destroy_and_clear_elements();
    columns_taken = 0;
}
