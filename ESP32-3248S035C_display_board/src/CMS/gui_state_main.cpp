#include <gui_state_main.h>
#include <display_config.h>
#include <gui_cms.h>
#include <gui_button.h>
#include <gui_checkbox.h>
#include <communication_queues.h>
#include <rpc.h>
#include <cJSON.h>
#include "gui_cms_states.h"
#include "watchpoint.h"

// const int default_graph_x = (int)(RESOLUTION_X * 0.1);
// const int default_graph_y = (int)(RESOLUTION_Y * 0.1); 
// const int default_graph_w = (int)(RESOLUTION_X * 0.2); 
// const int default_graph_h = (int)(RESOLUTION_Y * 0.7); 
// const int default_grid_x_segments = 1;
// const int default_grid_y_segments = 4;
// const int default_decimal_precision = 2;
// const int default_xlo = 0;
// const int default_xhi = 100;
// const int default_ylo = 0;
// const int default_yhi = 1;
// const String default_title = "";
// const String default_xlabel = "";
// const String default_ylabel = "";
// const unsigned int default_grid_color = BLUE;
// const unsigned int default_axis_color = RED;
// const unsigned int default_text_color = WHITE;
// const unsigned int default_background_color = BLACK;



GUI_State_Main::GUI_State_Main(TFT_eSPI *tft, GUI_CMS *gui, Touch *touch) : 
    GUI_State(tft, gui, touch), dataset_size(0) {

    // // ------------------------------
    // // -------- Graph elements ------
    // ecg_graph = new GUI_Graph(tft, 
    //     RESOLUTION_X*0.1, RESOLUTION_Y*0.08,  // x, y
    //     RESOLUTION_X*0.32, RESOLUTION_Y*0.3,   // width, height
    //     1, 4,       // grid x, y segments
    //     2,          // decimal precision of tick labels
    //     0, 100,     // xlo, xhi (how many data points to show at once)
    //     0, 1,       // ylo, yhi (range of values)
    //     "ECG (CHERI-RISC-V)", "", "", // title, xlabel, ylabel
    //     BLUE, RED, WHITE, BLACK // grid color, axis color, text color, background color
    //     );
    // ecg_graph->hide_legend();
    // ecg_graph->hide_grid();
    
    pynq_graph = new GUI_Graph(tft, 
        // RESOLUTION_X*0.1, RESOLUTION_Y*0.52,  // x, y
        RESOLUTION_X*0.04, RESOLUTION_Y*0.58,  // x, y
        // RESOLUTION_X*0.2, RESOLUTION_Y*0.3,   // width, height
        RESOLUTION_X*0.6, RESOLUTION_Y*0.2,   // width, height
        1, 4,       // grid x, y segments
        2,          // decimal precision of tick labels
        0, 30,      // xlo, xhi (how many data points to show at once)
        0, 1,       // ylo, yhi (range of values)
        "Metrics (CMS)", "", "", // title, xlabel, ylabel
        BLUE, RED, WHITE, BLACK // grid, axis, text, background (colors)
        );
    if (pynq_graph == NULL) {
        Serial.println("pynq_graph is NULL");
    }
    pynq_graph->show_current_value_display();
    // pynq_graph->hide_axes();
    pynq_graph->hide_grid();
    pynq_graph->hide_axis_labels();


    label_ap_conn_status = new GUI_Label(tft, "", RESOLUTION_X*0.02, RESOLUTION_Y*0.9, 1, TL_DATUM, WHITE, BLACK);
    label_tcp_conn_status = new GUI_Label(tft, "", RESOLUTION_X*0.02, RESOLUTION_Y*0.9 + 15, 1, TL_DATUM, WHITE, BLACK);
    if (label_ap_conn_status == NULL) {
        Serial.println("label_ap_conn_status is NULL");
    }
    if (label_tcp_conn_status == NULL) {
        Serial.println("label_tcp_conn_status is NULL");
    }

    // add_element(ecg_graph);
    add_element(pynq_graph);
    add_element(label_ap_conn_status);
    add_element(label_tcp_conn_status);

    // ---------------------------------
    // ------------ Buttons  -----------
    int button_y = button_y_start;
    btn_load_program = new GUI_Button(tft, "Load", button_x, button_y, button_width, button_height, button_font_size,
        WHITE,  // text colour
        BLACK,  // background colour
        [](){}, // function on press
        [gui](){   // function on release
            // change GUI state into program selection here or request the list of programs from the server
            Serial.println("Load program button was released");

            // {
            //     "RPC" : {
            //         "function_name": "rpc_list_programs"
            //     }
            // }
            gui->get_state_select_option()->set_on_option_selected_callback([gui](String category, String program_name){
                cJSON *root = cJSON_CreateObject();
                cJSON *rpc_obj = cJSON_CreateObject();
                cJSON_AddItemToObject(root, "RPC", rpc_obj);
                cJSON_AddStringToObject(rpc_obj, "function_name", "rpc_load_program");
                const char *string_array[1] = {program_name.c_str()}; 
                cJSON *function_args_obj = cJSON_CreateStringArray(string_array, 1);
                cJSON_AddItemToObject(rpc_obj, "function_args", function_args_obj);
                char *json_str = cJSON_PrintUnformatted(root);
                Serial.print("Sending: '");
                Serial.println(json_str);
                String *msg = new String(json_str);
                if (msg == NULL) {
                    Serial.println("msg is NULL");
                }
                add_string_to_queue(queue_to_send, msg, true);
                free(json_str);
                cJSON_Delete(root);
                gui->pop_state();
            });
            rpc_no_args("rpc_list_programs");
            gui->push_state(GUI_STATE_SELECT_OPTION);
        }
    );
    if (btn_load_program == NULL) {
        Serial.println("btn_load_program is NULL");
    }
    button_y += button_offset;

    btn_run_status = new GUI_Button(tft, "Run", button_x, button_y, button_width, button_height, button_font_size, WHITE,  BLACK); 
    if (btn_run_status == NULL) {
        Serial.println("btn_run_status is NULL");
    }
    btn_run_status->set_on_release_callback(
        [this](){   // function on release
            // change GUI state into program selection here or request the list of programs from the server
            Serial.println("Button run/halt was released");
            if (btn_run_status->get_text().equals("Halt")) {
                // btn_run_status->set_text("Resume");

                rpc_no_args("rpc_halt");
            }
            else if (btn_run_status->get_text().equals("Run") || btn_run_status->get_text().equals("Resume")) {
                // btn_run_status->set_text("Halt");

                rpc_no_args("rpc_run");
            }
        }
    );
    button_y += button_offset;
    btn_train = new GUI_Button(tft, "Train", button_x, button_y, button_width, button_height, button_font_size, WHITE, BLACK);  
    if (btn_train == NULL) {
        Serial.println("btn_train is NULL");
    }
    btn_train->set_on_release_callback(
        [this](){   // function on release
            // change GUI state into program selection here or request the list of programs from the server
            Serial.println("Button train/stop was released");
            if (btn_train->get_text().equals("Train")) {
                btn_train->set_text("Stop");
                rpc_no_args("rpc_enable_training");
            }
            else if (btn_train->get_text().equals("Stop")) {
                btn_train->set_text("Train");
                rpc_no_args("rpc_disable_training");
            }
        }
    );
    button_y += button_offset;
    btn_test = new GUI_Button(tft, "Test", button_x, button_y, button_width, button_height, button_font_size, WHITE, BLACK);  
    if (btn_test == NULL) {
        Serial.println("btn_test is NULL");
    }
    btn_test->set_on_release_callback(
        [this](){   // function on release
            // change GUI state into program selection here or request the list of programs from the server
            Serial.println("Button test/stop was released");
            if (btn_test->get_text().equals("Test")) {
                btn_test->set_text("Stop");
                rpc_no_args("rpc_enable_testing");
            }
            else if (btn_test->get_text().equals("Stop")) {
                btn_test->set_text("Test");
                rpc_no_args("rpc_disable_testing");
            }
        }
    );
    button_y += button_offset;
    btn_reset_dataset = new GUI_Button(tft, "Reset", button_x, button_y, button_width, button_height, button_font_size, WHITE, BLACK);  
    if (btn_reset_dataset == NULL) {
        Serial.println("btn_reset_dataset is NULL");
    }
    btn_reset_dataset->set_on_release_callback(
        [](){   // function on release
            rpc_no_args("rpc_reset_dataset");
        }
    );
    button_y += button_offset;
    add_element(btn_load_program);
    add_element(btn_run_status);
    add_element(btn_train);
    add_element(btn_test);
    add_element(btn_reset_dataset);


    const int label_x = button_x + button_width + RESOLUTION_X*0.04;
    const int label_y_start = button_y_start + button_height/2;
    const int label_font_size = button_font_size;
    int label_y = label_y_start;
    // ---------------------------------
    // -------- Status labels ----------
    label_loaded_program = new GUI_Label(tft, "-", label_x, label_y, label_font_size, ML_DATUM, WHITE, BLACK);  label_y += button_offset;
    label_run_status = new GUI_Label(tft, "-", label_x, label_y, label_font_size, ML_DATUM, WHITE, BLACK);      label_y += button_offset;
    label_training_status = new GUI_Label(tft, "-", label_x, label_y, label_font_size, ML_DATUM, WHITE, BLACK); label_y += button_offset;
    label_testing_status = new GUI_Label(tft, "-", label_x, label_y, label_font_size, ML_DATUM, WHITE, BLACK);  label_y += button_offset;
    label_dataset_size = new GUI_Label(tft, "Dataset size: 0", label_x, label_y, label_font_size, ML_DATUM, WHITE, BLACK);    label_y += button_offset;
    if (label_loaded_program == NULL || label_run_status == NULL || label_training_status == NULL || label_testing_status == NULL || label_dataset_size == NULL) {
        Serial.println("one of labels is NULL");
    }
    add_element(label_loaded_program);
    add_element(label_run_status);
    add_element(label_training_status);
    add_element(label_testing_status);
    add_element(label_dataset_size);

    // label_y = label_y_start;

    // ---------------------------------
    // -------- Watchpoints section  ---------
    const int watchpoints_x = pynq_graph->get_x();
    int watchpoints_y = button_y_start;
    // label_watchpoints = new GUI_Label(tft, "Watchpoints:", watchpoints_x, watchpoints_y + button_height - 2, label_font_size, BL_DATUM, WHITE, BLACK);  
    // btn_add_new_watchpoint = new GUI_Button(tft, "Add new watchpoint", watchpoints_x + label_watchpoints->get_w()*1.2, watchpoints_y, tft->textWidth("Add new watchpoint")*1.2, button_height, button_font_size, WHITE, BLACK);  watchpoints_y += button_offset;
    btn_add_new_watchpoint = new GUI_Button(tft, "Add new watchpoint", watchpoints_x, watchpoints_y, tft->textWidth("Add new watchpoint")*1.2, button_height, button_font_size, WHITE, BLACK);  watchpoints_y += button_offset;
    if (btn_add_new_watchpoint == NULL) {
        Serial.println("btn_add_new_watchpoint is NULL");
    }
    btn_add_new_watchpoint->set_on_release_callback(
        [this, gui, tft](){   
            // push watchpoint selection state
            Serial.println("Add new watchpoint button was released");
            add_atf_watchpoint();
        }
    );
    if (btn_add_new_watchpoint == NULL) {
        Serial.println("btn_add_new_watchpoint is NULL");
    }
    // add_element(label_watchpoints);
    add_element(btn_add_new_watchpoint);



// GUI_Checkbox::GUI_Checkbox(TFT_eSPI *tft, bool initial_is_checked, int x, int y, int w, int h, unsigned int font_size, unsigned int colour, unsigned int background_colour, 
//                            std::function<void()> on_press_callback, std::function<void()> on_release_callback,
//                            std::function<void()> on_checked, std::function<void()> on_unchecked) :

    // GUI_Checkbox* checkbox = new GUI_Checkbox(tft, true, watchpoints_x, watchpoints_y, button_height, button_height, 1, GREEN, BLACK, 
    //     [](){
    //         Serial.println("Checkbox was checked");
    //     }, // on checked
    //     [](){
    //         Serial.println("Checkbox was unchecked");
    //     }  // on unchecked
    // ); 
    // watchpoints_y += button_offset;
    // add_element(checkbox);
}

Watchpoint* GUI_State_Main::add_atf_watchpoint() {
    int watchpoint_x = pynq_graph->get_x();
    int watchpoint_y = button_y_start + (1 + watchpoints.size()) * button_offset;
    Watchpoint *watchpoint = new Watchpoint(tft, watchpoints.size(), watchpoint_x, watchpoint_y, button_height, button_height, WHITE);
    GUI_CMS *gui_cms = static_cast<GUI_CMS*>(this->gui);
    watchpoint->set_on_label_released_callback(
        [gui_cms, watchpoint](){
            Serial.println("Watchpoint label was released");
            gui_cms->get_state_edit_watchpoint()->set_watchpoint_to_edit(watchpoint);
            gui_cms->push_state(GUI_STATE_EDIT_WATCHPOINT);
        }
    );
    watchpoint->set_on_checked_callback(
        [this, watchpoint](){
            Serial.println("Watchpoint checkbox was checked");
            int watchpoint_index = std::find(watchpoints.begin(), watchpoints.end(), watchpoint) - watchpoints.begin();
            rpc("rpc_atf_watchpoint_set_active", "%d%b", watchpoint_index, true);
        }
    );
    watchpoint->set_on_unchecked_callback(
        [this, watchpoint](){
            Serial.println("Watchpoint checkbox was unchecked");
            int watchpoint_index = std::find(watchpoints.begin(), watchpoints.end(), watchpoint) - watchpoints.begin();
            rpc("rpc_atf_watchpoint_set_active", "%d%b", watchpoint_index, false);
        }
    );
    add_element(watchpoint);
    watchpoints.push_back(watchpoint);

    // watchpoint->push_to_pynq();
    return watchpoint;
}

void GUI_State_Main::clear_atf_watchpoints() {
    for (Watchpoint *watchpoint : watchpoints) {
        remove_element(watchpoint);
        delete watchpoint;
    }
    watchpoints.clear();
}

void GUI_State_Main::draw() {
    GUI_State::draw();
}

void GUI_State_Main::update() {
    GUI_State::update();
}

void GUI_State_Main::reset() {
    GUI_State::reset();
    // label_ap_conn_status->set_text("-");
    // label_tcp_conn_status->set_text("-");

    label_loaded_program->set_text("-");
    label_run_status->set_text("-");
    label_training_status->set_text("-");
    label_testing_status->set_text("-");

    btn_load_program->set_text("Load");
    btn_run_status->set_text("Run");
    btn_train->set_text("Train");
    btn_test->set_text("Test");
}

void GUI_State_Main::set_ap_conn_status(String text) {
    label_ap_conn_status->set_text(text);
}

void GUI_State_Main::set_tcp_conn_status(String text) {
    label_tcp_conn_status->set_text(text);
}

void GUI_State_Main::set_loaded_program(String text) {
    label_loaded_program->set_text(text);
    set_run_status("Loaded");
}

void GUI_State_Main::set_run_status(String text) {
    label_run_status->set_text(text);
    if (text.equals("Running"))
        btn_run_status->set_text("Halt");
    else if (text.equals("Halted"))
        btn_run_status->set_text("Resume");
    else if (text.equals("Finished") || text.equals("Loaded"))
        btn_run_status->set_text("Run");
}

void GUI_State_Main::set_training_status(String text) {
    label_training_status->set_text(text);
    if (text.equals("Training"))
        btn_train->set_text("Stop");
    else if (text.equals("-"))
        btn_train->set_text("Train");
}

void GUI_State_Main::set_testing_status(String text) {
    label_testing_status->set_text(text);
    if (text.equals("Testing"))
        btn_test->set_text("Stop");
    else if (text.equals("-"))
        btn_test->set_text("Test");
}

void GUI_State_Main::set_dataset_size(int size) {
    if (size == dataset_size) return;
    dataset_size = size;
    label_dataset_size->set_text("Dataset size: " + String(size));
}

void GUI_State_Main::on_state_enter() {
    GUI_State::on_state_enter();
    Serial.println("Main state entered");
}

void GUI_State_Main::on_state_exit() {
    GUI_State::on_state_exit();
    Serial.println("Main state exited");
}
