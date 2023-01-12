# PYNQ wrapper for Flute processor
This repository contains source files and documentation for a PYNQ design that collects metrics from RISC-V processor implemented in programmable logic (PL) of the ZC706 board.

# Documentation
Documentation files are in the [docs](./docs) directory and include:
* [setup_guide.md](./docs/setup_guide.md)
* [data_extraction.md](./docs/data_extraction.md)
* [console_io.md](./docs/console_io.md)
* [continuous_monitoring_system_configuration.md](./docs/continuous_monitoring_system_configuration.md)
* [loading_and_running_programs.md](./docs/loading_and_running_programs.md)

# Purpose
The main purpose of this wrapper is to help with development and testing of a [continuous monitoring system](https://github.com/michalmonday/continuous_monitoring_system) that will compare program behaviour with its previously recorded profile. Aiming to detect any deviation from original behaviour (e.g. due to malicious interference, or accidental failure due to faulty sensor or other factors). In similar way to previously published work like:  

| Year | Title |  
| ---- | ----- |
| 2001 | “A fast automaton-based method for detecting anomalous program behaviors.” by R. Sekar et al.  |  
| 2003 | “Anomaly detection using call stack information“ by H. Feng et al. |   
| 2006 | “Hardware-assisted run-time monitoring for secure program execution on embedded processors” by D. Arora et al.  |  
| 2012 | “A high-performance, low-overhead microarchitecture for secure program execution” by A.K. Kanuparthi et al.  |  
| 2015 | “A method for detecting abnormal program behavior on embedded devices” by X. Zhai et al.  |  
| 2017 | “Learning execution contexts from system call distribution for anomaly detection in smart embedded system” by M. Yoon et  al. |
| 2017 | “Hardware performance counters based runtime anomaly detection using svm” by M. F. B. Abbas et al.  |  
| 2017 | “Time and sequence integrated runtime anomaly detection for embedded system“ by S. Lu and R. Lysecky  |  
| 2019 | “Data-driven anomaly detection with timing features for embedded systems” by S. Lu and R. Lysecky  |  
| 2019 | “Fdnn: Feature-based deep neural network model for anomaly detection of kpis” by Z. Lan et al.  |  
| 2019 | “Anomaly detection in real-time multi-threaded processes using hardware performance counters” by P. Krishnamurthy  |  
| 2020 | “An m-cache-based security monitoring and fault recovery architecture for embedded processor” by X. Wang et al.  |  

Furthermore, the documentation may serve as a reference for anyone who would like to create similar custom interface/modifications to an open source processor.


# Block design

Click to view a high resolution PDF.

[<img src="./images/block_design.png" />](./images/block_design.pdf)
