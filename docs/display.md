# Table of contents
- [Overview](#overview)
- [Library dependencies](#library-dependencies)
- [Displays documentation](#displays-documentation)
- [Graphics library](#graphics-library)
- [What programs were created for the display board](#what-programs-were-created-for-the-display-board)
  - [CMS](#cms)
  - [ECG](#ecg)
- [What displays look like](#what-displays-look-like)


# Overview
This project needed a display support for 2 main purposes:
* control and view the state of the Continouos Monitoring System (CMS)
* display ECG heart activity data (because ECG application is used for demonstration purposes, while CMS monitors it and detects anomalous behaviour)

Initially we integrated the ESP32-3248S035C display (3.5 inch), then we added support for the bigger ESP32-8048S070 display (7 inch).

The TCP server running on PYNQ can communicate with any TCP client to receive commands and send data for monitoring purposes. Both display boards that we used contain an Esp32 microcontroller with WiFi connectivity (acting as TCP client).

# Library dependencies
* **TFT_eSPI** (used version 2.4.79) - low level graphics library (used for the 3.5 display)
* **GFX Library for Arduino** (used version 1.2.8)  - low level graphics library (used for the 7 inch display)
* **TAMC_GT911** (used version 1.0.2) - touch screen library (used for both displays)

These should be put in the Arduino libraries folder (e.g. C:\Users\user\Documents\Arduino\libraries) or added by using PlatformIO VScode plugin.

# Displays documentation
Links to full documentation can be found in Aliexpress ESP32-3248S035C and ESP32-8048S070 listings descriptions. It seems Aliexpress is the only place where these displays can be purchased. 

# Graphics library
We created a simple [GUI library](../display_board/src/lib/) to support changing graphical scenes (states) and implement interactive GUI elements (buttons, checkboxes, labels, graphs), resembling to some extent QT design convention (of QGraphicsItem and QGraphicsScene classes). The library is not very sophisticated, but it is enough for our purposes, and most importantly it can nicely draw multiple moving line plots in real time. It is reused in both programs we created: [CMS](../display_board/src/CMS/) and [ECG](../display_board/src/ECG/). Choice of which to compile is done by modifying the [platformio.ini](../display_board/platformio.ini) file. It was developed using PlatformIO plugin for VScode.

# What programs were created for the display board
## [CMS](../display_board/src/CMS/)

The CMS program is used to control and view the state of the CMS. It is used to configure CMS, load programs into memory, run, halt and resume them, and view collected metrics. It is also used to reset anomaly detection model/dataset. 

Esp32 microcontroller contains 2 cores, in the CMS program one core is used for TCP communication with the PYNQ wrapper, and the other one is used to handle the GUI. 

[tcp_server_protocol.md](../docs/tcp_server_protocol.md) contains a description of the protocol used to communicate with the PYNQ wrapper.  

CMS program uses the 7 inch display board.   

## [ECG](../display_board/src/ECG/) 
The ECG program is used to display ECG heart activity data. It receives the data through UART pins connected to the ZC706 board.
ECG program is using the 3.5 inch display.

# What displays look like
[use_case.md](../docs/use_case.md) presents both display programs (CMS and ECG) in action.