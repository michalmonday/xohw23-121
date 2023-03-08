#include "gui_state_main.h"
#include "display_config.h"
#include "gui.h"
#include "gui_button.h"

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
    GUI_Button *btn_load_program = new GUI_Button(tft, "Load", button_x, button_y_start, button_width, button_height, button_font_size,
        WHITE,  // text colour
        BLACK,  // background colour
        [](){}, // function on press
        [](){   // function on release
            // change GUI state into program selection here or request the list of programs from the server
            Serial.println("Load program button was released");
        }
    );
    GUI_Button *btn_run_halt = new GUI_Button(tft, "Run", button_x, button_y_start + button_height*1.3, button_width, button_height, button_font_size, WHITE,  BLACK); 
    
    btn_run_halt->set_on_release_callback(
        [btn_run_halt](){   // function on release
            // change GUI state into program selection here or request the list of programs from the server
            Serial.println("Button run/halt was released");
            if (btn_run_halt->get_text().equals("Halt")) 
                btn_run_halt->set_text("Run");
            else if (btn_run_halt->get_text().equals("Run"))
                btn_run_halt->set_text("Halt");
        }
    );
    GUI_Button *btn_train = new GUI_Button(tft, "Train", button_x, button_y_start + (button_height*1.3) * 2, button_width, button_height, button_font_size, WHITE, BLACK);  
    btn_train->set_on_release_callback(
        [btn_train](){   // function on release
            // change GUI state into program selection here or request the list of programs from the server
            Serial.println("Button train/stop was released");
            if (btn_train->get_text().equals("Train"))
                btn_train->set_text("Stop");
            else if (btn_train->get_text().equals("Stop"))
                btn_train->set_text("Train");
        }
    );
    GUI_Button *btn_test = new GUI_Button(tft, "Test", button_x, button_y_start + (button_height*1.3) * 3, button_width, button_height, button_font_size, WHITE, BLACK);  
    btn_test->set_on_release_callback(
        [btn_test](){   // function on release
            // change GUI state into program selection here or request the list of programs from the server
            Serial.println("Button test/stop was released");
            if (btn_test->get_text().equals("Test"))
                btn_test->set_text("Stop");
            else if (btn_test->get_text().equals("Stop"))
                btn_test->set_text("Test");
        }
    );
    add_element(btn_load_program);
    add_element(btn_run_halt);
    add_element(btn_train);
    add_element(btn_test);
}

void GUI_State_Main::update() {
    GUI_State::update();

}

void GUI_State_Main::set_ap_conn_status(String text) {
    label_ap_conn_status->set_text(text);
}

void GUI_State_Main::set_tcp_conn_status(String text) {
    label_tcp_conn_status->set_text(text);
}

void GUI_State_Main::on_state_enter() {
    GUI_State::on_state_enter();
    Serial.println("Main state entered");
}

void GUI_State_Main::on_state_exit() {
    GUI_State::on_state_exit();
    Serial.println("Main state exited");
}
