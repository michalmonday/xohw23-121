#include "gui_state_main.h"
#include "display_config.h"
#include "gui.h"
#include "gui_button.h"
#include "communication_queues.h"
#include "rpc.h"
#include <cJSON.h>

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



GUI_State_Main::GUI_State_Main(TFT_eSPI *tft, GUI *gui, Touch *touch) : 
    GUI_State(tft, gui, touch) {

    // ------------------------------
    // -------- Graph elements ------
    ecg_graph = new GUI_Graph(tft, 
        RESOLUTION_X*0.1, RESOLUTION_Y*0.08,  // x, y
        RESOLUTION_X*0.2, RESOLUTION_Y*0.3,   // width, height
        1, 4,       // grid x, y segments
        2,          // decimal precision of tick labels
        0, 100,     // xlo, xhi (how many data points to show at once)
        0, 1,       // ylo, yhi (range of values)
        "ECG (CHERI-RISC-V)", "", "", // title, xlabel, ylabel
        BLUE, RED, WHITE, BLACK // grid color, axis color, text color, background color
        );
    pynq_graph = new GUI_Graph(tft, 
        RESOLUTION_X*0.1, RESOLUTION_Y*0.52,  // x, y
        RESOLUTION_X*0.2, RESOLUTION_Y*0.3,   // width, height
        1, 4,       // grid x, y segments
        2,          // decimal precision of tick labels
        0, 100,     // xlo, xhi (how many data points to show at once)
        0, 1,       // ylo, yhi (range of values)
        "Metrics (CMS)", "", "", // title, xlabel, ylabel
        BLUE, RED, WHITE, BLACK // grid, axis, text, background (colors)
        );
    label_ap_conn_status = new GUI_Label(tft, "", RESOLUTION_X*0.02, RESOLUTION_Y*0.9, 1, TL_DATUM, WHITE, BLACK);
    label_tcp_conn_status = new GUI_Label(tft, "", RESOLUTION_X*0.02, RESOLUTION_Y*0.9 + 15, 1, TL_DATUM, WHITE, BLACK);

    add_element(ecg_graph);
    add_element(pynq_graph);
    add_element(label_ap_conn_status);
    add_element(label_tcp_conn_status);

    // ---------------------------------
    // ------------ Buttons  -----------
    const int button_width = RESOLUTION_X * 0.16;
    const int button_height = RESOLUTION_Y * 0.15;
    const int button_x = RESOLUTION_X*0.48;
    const int button_y_start = RESOLUTION_Y*0.05;
    const int button_font_size = 2;
    const int button_offset = button_height * 1.3;
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
            rpc_no_args("rpc_list_programs");
            gui->push_state(GUI_STATE_SELECT_PROGRAM);
        }
    );
    button_y += button_offset;

    btn_run_status = new GUI_Button(tft, "Run", button_x, button_y, button_width, button_height, button_font_size, WHITE,  BLACK); 
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
    add_element(btn_load_program);
    add_element(btn_run_status);
    add_element(btn_train);
    add_element(btn_test);


    const int label_x = button_x + button_width + RESOLUTION_X*0.04;
    const int label_y_start = button_y_start + button_height/2;
    const int label_font_size = 2;
    int label_y = label_y_start;
    // ---------------------------------
    // -------- Status labels ----------
    label_loaded_program = new GUI_Label(tft, "-", label_x, label_y, label_font_size, ML_DATUM, WHITE, BLACK); label_y += button_offset;
    label_run_status = new GUI_Label(tft, "-", label_x, label_y, label_font_size, ML_DATUM, WHITE, BLACK);        label_y += button_offset;
    label_training_status = new GUI_Label(tft, "-", label_x, label_y, label_font_size, ML_DATUM, WHITE, BLACK);   label_y += button_offset;
    label_testing_status = new GUI_Label(tft, "-", label_x, label_y, label_font_size, ML_DATUM, WHITE, BLACK);    label_y += button_offset;
    add_element(label_loaded_program);
    add_element(label_run_status);
    add_element(label_training_status);
    add_element(label_testing_status);
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
}

void GUI_State_Main::set_testing_status(String text) {
    label_testing_status->set_text(text);
}

void GUI_State_Main::on_state_enter() {
    GUI_State::on_state_enter();
    Serial.println("Main state entered");
}

void GUI_State_Main::on_state_exit() {
    GUI_State::on_state_exit();
    Serial.println("Main state exited");
}
