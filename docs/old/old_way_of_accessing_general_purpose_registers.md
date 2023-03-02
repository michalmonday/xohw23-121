This file describes how GPR reading was initially done. As mentioned in the [Shortcomings of this modification](#shortcomings-of-this-modification) section, this was not the best way to do it and was associated with issues. Instead of using read ports to read all (or some) GPR values at once, we not monitor the write port to GPR and have a "shadow" copy of the GPR file in the CMS module. This file is left in "old" folder for reference only, to show "what would happen if" and to show how it could be done.

# Simultaneus access to general purpose registers

By default, the Flute seems to have a single write port and 3 read ports for the register file where the general purpose registers are stored (GPR file). These ports are:
* rs1 port (for reading source register 1)
* rs2 port (for reading source register 2)
* debug only port (called read_rs1_port2)

This can be seen in the [GPR_RegFile.bsv](https://github.com/michalmonday/Flute/blob/continuous_monitoring/src_Core/RegFiles/GPR_RegFile.bsv) file.

Wanting to read some register values in real time, we added 4 additional ports (cms stands for continuous monitoring system):
```verilog
   (* always_ready *) method `EXTERNAL_REG_TYPE_OUT read_cms (RegName rs);
   (* always_ready *) method `EXTERNAL_REG_TYPE_OUT read_cms2 (RegName rs);
   (* always_ready *) method `EXTERNAL_REG_TYPE_OUT read_cms3 (RegName rs);
   (* always_ready *) method `EXTERNAL_REG_TYPE_OUT read_cms4 (RegName rs);
```

The problem was that the Flute source code wouldn't compile anymore because the number of read ports in the RegFile module (that implements the general purpose registers file) is limited to max 5 read ports. Unfortunately we couldn't just simply change a RegFile definition in the Flute source code because the RegFile module seems to be a part of the bsc compiler default libraries.

We modified [RegFile.bs](https://github.com/michalmonday/bsc/blob/main/src/Libraries/Base1/RegFile.bs) by changing every occurence of number `5` to `9` in that file (to increase the number of ports by 4, although setting it to 7 should probably be sufficient). Then we recompiled the bsc compiler and used that new compiler to compile the Flute source code.

Additionally, the [RegFile.v](https://github.com/michalmonday/Flute/blob/continuous_monitoring/src_bsc_lib_RTL/RegFile.v) and [RegFileLoad.v](https://github.com/michalmonday/Flute/blob/continuous_monitoring/src_bsc_lib_RTL/RegFileLoad.v) files also were modified (to include the new ports).


### Shortcomings of this modification
Initially we increased the number of ports to collect all 32 registers, this increased the Vivado compilation time by over 2 times (it went from around 40 minutes to around 90 minutes). Changing it back to 4 additional ports reduced the compilation time back to around 40 minutes.

I am not knowledgable person on this topic but I assume that physical space utilization in hardware plays big role in terms of performance, and inclusion of additional ports in the heavily accessed register file probably does not help with that.

The problem that still remains regarding this modification is that it affects not only general purpose register file but also all the files where RegFile module is used. A better solution would be to create some kind of subclass of the RegFile only used for the general purpose registers file (or maybe add some kind of a generic argument to the RegFile module to set the number of read ports at compile time). But so far we prioritized other tasks over this one, because for our use case this shortcoming is not critical (although it's not elegant either).

### Alternative solution
A less intrusive solution would be to monitor the write address, write data and write enable of general purpose registers file and keep a "shadow" copy of it in the continuous monitoring system module.
