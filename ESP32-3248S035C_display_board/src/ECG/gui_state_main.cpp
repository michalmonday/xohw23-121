#include "gui_state_main.h"
#include <display_config.h>
#include <gui.h>
#include <gui_button.h>
#include <gui_ecg_states.h>

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
    GUI_State(tft, gui, touch), electrodes_connected(false) 
{
    // ------------------------------
    // -------- Graph elements ------
    ecg_graph = new GUI_Graph(tft, 
        // RESOLUTION_X*0.1, RESOLUTION_Y*0.08,  // x, y
        // RESOLUTION_X*0.8, RESOLUTION_Y*0.8,   // width, height
        0, RESOLUTION_Y*0.08,           // x, y
        RESOLUTION_X, RESOLUTION_Y*0.8, // width, height
        1, 4,       // grid x, y segments
        2,          // decimal precision of tick labels
        0, 100,     // xlo, xhi (how many data points to show at once)
        0, 1,       // ylo, yhi (range of values)
        // "ECG (CHERI-RISC-V)", "", "", // title, xlabel, ylabel
        "", "", "", // title, xlabel, ylabel
        BLUE, RED, WHITE, BLACK // grid color, axis color, text color, background color
        );
    ecg_graph->hide_legend();
    ecg_graph->hide_grid();
    ecg_graph->hide_axes();
    
    label_electrodes_status = new GUI_Label(tft, "Electrodes disconnected", RESOLUTION_X*0.5, RESOLUTION_Y*0.92, 2, TC_DATUM, RED, BLACK);

    add_element(ecg_graph);
    add_element(label_electrodes_status);

    // // ---------------------------------
    // // ------------ Buttons  -----------
    // const int button_width = RESOLUTION_X * 0.16;
    // // const int button_height = RESOLUTION_Y * 0.15;
    // const int button_height = RESOLUTION_Y * 0.07;
    // const int button_x = RESOLUTION_X*0.48;
    // const int button_y_start = RESOLUTION_Y*0.05;
    // const int button_font_size = 1; //2;
    // const int button_offset = button_height * 1.3;
    // int button_y = button_y_start;

    // btn_run_status = new GUI_Button(tft, "Run", button_x, button_y, button_width, button_height, button_font_size, WHITE,  BLACK); 
    // btn_run_status->set_on_release_callback(
    //     [this](){   // function on release
    //         // change GUI state into program selection here or request the list of programs from the server
    //         Serial.println("Button run/halt was released");
    //         if (btn_run_status->get_text().equals("Halt")) {
    //             // btn_run_status->set_text("Resume");

    //             rpc_no_args("rpc_halt");
    //         }
    //         else if (btn_run_status->get_text().equals("Run") || btn_run_status->get_text().equals("Resume")) {
    //             // btn_run_status->set_text("Halt");

    //             rpc_no_args("rpc_run");
    //         }
    //     }
    // );
    // button_y += button_offset;
}

void GUI_State_Main::draw() {
    GUI_State::draw();
}

void GUI_State_Main::update() {
    GUI_State::update();
}

void GUI_State_Main::reset() {
    GUI_State::reset();
    label_electrodes_status->set_text("-");
}

void GUI_State_Main::on_state_enter() {
    GUI_State::on_state_enter();
    Serial.println("Main state entered");
}

void GUI_State_Main::on_state_exit() {
    GUI_State::on_state_exit();
    Serial.println("Main state exited");
}

void GUI_State_Main::set_electrodes_status(bool new_status) {
    if (new_status != electrodes_connected) {
        if (new_status) {
            // label_electrodes_status->set_text("Electrodes connected");
            label_electrodes_status->set_text("");
        } else {
            label_electrodes_status->set_text("Electrodes disconnected");
        }
        electrodes_connected = new_status;
    }
}