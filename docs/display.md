
# Overview
PYNQ wrapper needed a display support for 2 main purposes:
* control and view the state of the Continouos Monitoring System (CMS)
* display ECG heart activity data (because ECG application is used for demonstration purposes, CMS monitors it and detects anomalous behaviour)

The TCP server running on PYNQ can communicate with any TCP client to receive commands and send data for monitoring purposes. The ESP32-3248S035C board we used contains a display and an Esp32 microcontroller with WiFi connectivity (acting as TCP client).

# Library dependencies:
* TFT_eSPI (used version 2.4.79)
* TAMC_GT911 (used version 1.0.2)

# Display documentation
This repository includes [most of the documentation](../ESP32-3248S035C_display_board/board_documentation_copy/) for the display (with exception of some large files), links to full documentation can be found in Aliexpress ESP32-3248S035C listings descriptions. 

# Graphics library
We created a simple [GUI library](../ESP32-3248S035C_display_board/src/lib/) to support changing graphical scenes (states) and implement interactive GUI elements (buttons, checkboxes, labels, graphs), resembling to some extent QT design convention (of QGraphicsItem and QGraphicsScene classes). The library is not very sophisticated, but it is enough for our purposes, and most importantly it can nicely draw multiple moving line plots in real time. It is reused in both programs we created: [CMS](../ESP32-3248S035C_display_board/src/CMS/) and [ECG](../ESP32-3248S035C_display_board/src/ECG/). Choice of which to compile is done by modifying the [platformio.ini](../ESP32-3248S035C_display_board/platformio.ini) file. It was developed using PlatformIO plugin for VSCode.


# About CMS display program
The CMS program is used to control and view the state of the CMS. It is used to configure CMS, load programs into memory, run, halt and resume them, and view collected metrics. It is also used to reset anomaly detection model/dataset. 

Esp32 microcontroller contains 2 cores, in the CMS program one core is used for TCP communication with the PYNQ wrapper, and the other one is used to handle the GUI. 

[tcp_server_protocol.md](../docs/tcp_server_protocol.md) contains a description of the protocol used to communicate with the PYNQ wrapper.

# What it looks like
[use_case.md](../docs/use_case.md) presents both display programs (CMS and ECG) in action.