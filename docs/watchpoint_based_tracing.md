

Watchpoint based tracing involves collecting execution metrics (like HPC vectors or timing information) whenever the processor state matches any of the previously set conditions. To form a condition that triggers a watchpoint, multiple attributes may be optionally included. The watchpoint set in figure below will collect data whenever the "wait_ms" (PC: 0x800007ec) function is called with the first argument (A0) being equal to 5. 

<img src="../images/condition.png" alt="ERROR: IMAGE DIDNT SHOW"  width="500" />

# Purpose
Watchpoint based tracing allows to collect data at intervals long enough for real-time anomaly detection in software. That's because the data is collected only when the condition is met.

# Shortcomings
* If watchpoint condition is triggerred too often, too much data will be collected and the software (Python script running on PYNQ) will not be able to keep up with data processing and collection. 
* Setting watchpoints is manual, it requires knowledge of a program, time and effort.
* Collected data can't be used to reconstruct the execution flow of the program (it can be used for recognizing that the program is acting in unusual way, so the tracing is anomaly-detection oriented).