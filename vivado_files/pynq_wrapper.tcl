
################################################################
# This is a generated script based on design: imported_design
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2020.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source imported_design_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# mkSoC_Top, axi_dma_receive_transfer_tap, console_io_dma, console_io, mux_select_to_gpio, shift_register, delayer, cms_ip_wrapper, shift_register_generic

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z045ffg900-2
   set_property BOARD_PART xilinx.com:zc706:part0:1.4 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name imported_design

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:processing_system7:5.5\
xilinx.com:ip:axi_dma:7.1\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:system_ila:1.1\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:ip:xlslice:1.0\
xilinx.com:ip:axi_bram_ctrl:4.1\
xilinx.com:ip:blk_mem_gen:8.4\
xilinx.com:ip:c_addsub:12.0\
xilinx.com:ip:xadc_wiz:3.3\
xilinx.com:ip:util_vector_logic:2.0\
xilinx.com:ip:axis_data_fifo:2.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
mkSoC_Top\
axi_dma_receive_transfer_tap\
console_io_dma\
console_io\
mux_select_to_gpio\
shift_register\
delayer\
cms_ip_wrapper\
shift_register_generic\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: axi_gpio_to_cms_ctrl_interface
proc create_hier_cell_axi_gpio_to_cms_ctrl_interface { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_axi_gpio_to_cms_ctrl_interface() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI


  # Create pins
  create_bd_pin -dir O -from 63 -to 0 Dout
  create_bd_pin -dir O -from 7 -to 0 Dout1
  create_bd_pin -dir O -from 0 -to 0 Dout2
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn

  # Create instance: axi_gpio_cms_ctrl, and set properties
  set axi_gpio_cms_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_cms_ctrl ]
  set_property -dict [ list \
   CONFIG.C_ALL_OUTPUTS {1} \
 ] $axi_gpio_cms_ctrl

  # Create instance: shift_register_gener_0, and set properties
  set block_name shift_register_generic
  set block_cell_name shift_register_gener_0
  if { [catch {set shift_register_gener_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $shift_register_gener_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
   CONFIG.DATA_INPUT_WIDTH {16} \
   CONFIG.DATA_OUTPUT_WIDTH {64} \
 ] $shift_register_gener_0

  # Create instance: xlslice_0_15_sr_data_in, and set properties
  set xlslice_0_15_sr_data_in [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0_15_sr_data_in ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {15} \
   CONFIG.DIN_TO {0} \
   CONFIG.DOUT_WIDTH {16} \
 ] $xlslice_0_15_sr_data_in

  # Create instance: xlslice_16_16_sr_shift, and set properties
  set xlslice_16_16_sr_shift [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_16_16_sr_shift ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {16} \
   CONFIG.DIN_TO {16} \
   CONFIG.DOUT_WIDTH {1} \
 ] $xlslice_16_16_sr_shift

  # Create instance: xlslice_17_24_cms_ctrl_addr, and set properties
  set xlslice_17_24_cms_ctrl_addr [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_17_24_cms_ctrl_addr ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {24} \
   CONFIG.DIN_TO {17} \
   CONFIG.DOUT_WIDTH {8} \
 ] $xlslice_17_24_cms_ctrl_addr

  # Create instance: xlslice_25_25_cms_ctrl_write_enable, and set properties
  set xlslice_25_25_cms_ctrl_write_enable [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_25_25_cms_ctrl_write_enable ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {25} \
   CONFIG.DIN_TO {25} \
   CONFIG.DOUT_WIDTH {1} \
 ] $xlslice_25_25_cms_ctrl_write_enable

  # Create interface connections
  connect_bd_intf_net -intf_net axi_smc_M06_AXI [get_bd_intf_pins S_AXI] [get_bd_intf_pins axi_gpio_cms_ctrl/S_AXI]

  # Create port connections
  connect_bd_net -net axi_gpio_cms_gpio_io_o [get_bd_pins axi_gpio_cms_ctrl/gpio_io_o] [get_bd_pins xlslice_0_15_sr_data_in/Din] [get_bd_pins xlslice_16_16_sr_shift/Din] [get_bd_pins xlslice_17_24_cms_ctrl_addr/Din] [get_bd_pins xlslice_25_25_cms_ctrl_write_enable/Din]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins s_axi_aresetn] [get_bd_pins axi_gpio_cms_ctrl/s_axi_aresetn]
  connect_bd_net -net shift_register_gener_0_data_out [get_bd_pins Dout] [get_bd_pins shift_register_gener_0/data_out]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins shift_register_gener_0/data_in] [get_bd_pins xlslice_0_15_sr_data_in/Dout]
  connect_bd_net -net xlslice_17_24_cms_ctrl_addr_Dout [get_bd_pins Dout1] [get_bd_pins xlslice_17_24_cms_ctrl_addr/Dout]
  connect_bd_net -net xlslice_1_Dout [get_bd_pins shift_register_gener_0/shift] [get_bd_pins xlslice_16_16_sr_shift/Dout]
  connect_bd_net -net xlslice_25_25_cms_ctrl_write_enable_Dout [get_bd_pins Dout2] [get_bd_pins xlslice_25_25_cms_ctrl_write_enable/Dout]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins s_axi_aclk] [get_bd_pins axi_gpio_cms_ctrl/s_axi_aclk]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: continuous_monitoring_system_blocks
proc create_hier_cell_continuous_monitoring_system_blocks { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_continuous_monitoring_system_blocks() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI

  create_bd_intf_pin -mode Monitor -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S01_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S02_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_LITE


  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir O -from 31 -to 0 axis_wr_data_count
  create_bd_pin -dir I en
  create_bd_pin -dir I -from 511 -to 0 general_purpose_registers
  create_bd_pin -dir O halt_cpu
  create_bd_pin -dir I -from 31 -to 0 instr
  create_bd_pin -dir O -from 63 -to 0 item_counter_probe1
  create_bd_pin -dir I -from 63 -to 0 pc
  create_bd_pin -dir I -from 38 -to 0 performance_events

  # Create instance: axi_dma_0, and set properties
  set axi_dma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0 ]
  set_property -dict [ list \
   CONFIG.c_include_mm2s {0} \
   CONFIG.c_include_s2mm {1} \
   CONFIG.c_include_sg {0} \
   CONFIG.c_m_axi_mm2s_data_width {32} \
   CONFIG.c_m_axis_mm2s_tdata_width {32} \
   CONFIG.c_mm2s_burst_size {16} \
   CONFIG.c_sg_include_stscntrl_strm {0} \
   CONFIG.c_sg_length_width {26} \
 ] $axi_dma_0

  # Create instance: axi_gpio_to_cms_ctrl_interface
  create_hier_cell_axi_gpio_to_cms_ctrl_interface $hier_obj axi_gpio_to_cms_ctrl_interface

  # Create instance: axis_data_fifo_0, and set properties
  set axis_data_fifo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_0 ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {2048} \
   CONFIG.HAS_PROG_FULL {1} \
   CONFIG.HAS_RD_DATA_COUNT {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_WR_DATA_COUNT {1} \
   CONFIG.PROG_FULL_THRESH {2000} \
 ] $axis_data_fifo_0

  # Create instance: cms_ip_wrapper_0, and set properties
  set block_name cms_ip_wrapper
  set block_cell_name cms_ip_wrapper_0
  if { [catch {set cms_ip_wrapper_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $cms_ip_wrapper_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: smartconnect_1, and set properties
  set smartconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_1 ]
  set_property -dict [ list \
   CONFIG.NUM_SI {3} \
 ] $smartconnect_1

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins S_AXI] [get_bd_intf_pins axi_gpio_to_cms_ctrl_interface/S_AXI]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins S02_AXI] [get_bd_intf_pins smartconnect_1/S02_AXI]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins S01_AXI] [get_bd_intf_pins smartconnect_1/S01_AXI]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_S2MM [get_bd_intf_pins axi_dma_0/M_AXI_S2MM] [get_bd_intf_pins smartconnect_1/S00_AXI]
  connect_bd_intf_net -intf_net axi_smc_M04_AXI [get_bd_intf_pins S_AXI_LITE] [get_bd_intf_pins axi_dma_0/S_AXI_LITE]
  connect_bd_intf_net -intf_net axis_data_fifo_0_M_AXIS [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM] [get_bd_intf_pins axis_data_fifo_0/M_AXIS]
  connect_bd_intf_net -intf_net pc_stream_0_M_AXIS [get_bd_intf_pins axis_data_fifo_0/S_AXIS] [get_bd_intf_pins cms_ip_wrapper_0/M_AXIS]
  connect_bd_intf_net -intf_net [get_bd_intf_nets pc_stream_0_M_AXIS] [get_bd_intf_pins M_AXIS] [get_bd_intf_pins cms_ip_wrapper_0/M_AXIS]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_intf_nets pc_stream_0_M_AXIS]
  connect_bd_intf_net -intf_net smartconnect_1_M00_AXI [get_bd_intf_pins M00_AXI] [get_bd_intf_pins smartconnect_1/M00_AXI]

  # Create port connections
  connect_bd_net -net axi_gpio_to_cms_control_interface_Dout [get_bd_pins axi_gpio_to_cms_ctrl_interface/Dout] [get_bd_pins cms_ip_wrapper_0/ctrl_wdata]
  connect_bd_net -net axi_gpio_to_cms_control_interface_Dout1 [get_bd_pins axi_gpio_to_cms_ctrl_interface/Dout1] [get_bd_pins cms_ip_wrapper_0/ctrl_addr]
  connect_bd_net -net axi_gpio_to_cms_control_interface_Dout2 [get_bd_pins axi_gpio_to_cms_ctrl_interface/Dout2] [get_bd_pins cms_ip_wrapper_0/ctrl_write_enable]
  connect_bd_net -net axis_data_fifo_0_axis_wr_data_count [get_bd_pins axis_wr_data_count] [get_bd_pins axis_data_fifo_0/axis_wr_data_count]
  connect_bd_net -net axis_data_fifo_0_prog_full [get_bd_pins axis_data_fifo_0/prog_full] [get_bd_pins cms_ip_wrapper_0/fifo_full]
  connect_bd_net -net cms_ip_wrapper_0_halt_cpu [get_bd_pins halt_cpu] [get_bd_pins cms_ip_wrapper_0/halt_cpu]
  connect_bd_net -net en_1 [get_bd_pins en] [get_bd_pins cms_ip_wrapper_0/cpu_rst_n] [get_bd_pins cms_ip_wrapper_0/en]
  connect_bd_net -net general_purpose_registers_1 [get_bd_pins general_purpose_registers] [get_bd_pins cms_ip_wrapper_0/general_purpose_registers]
  connect_bd_net -net item_counter_probe [get_bd_pins item_counter_probe1] [get_bd_pins cms_ip_wrapper_0/item_counter_probe]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets item_counter_probe]
  connect_bd_net -net mkCore_Synth_0_instr [get_bd_pins instr] [get_bd_pins cms_ip_wrapper_0/instr]
  connect_bd_net -net mkCore_Synth_0_pc [get_bd_pins pc] [get_bd_pins cms_ip_wrapper_0/pc]
  connect_bd_net -net performance_events_1 [get_bd_pins performance_events] [get_bd_pins cms_ip_wrapper_0/performance_events]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins aresetn] [get_bd_pins axi_dma_0/axi_resetn] [get_bd_pins axi_gpio_to_cms_ctrl_interface/s_axi_aresetn] [get_bd_pins axis_data_fifo_0/s_axis_aresetn] [get_bd_pins cms_ip_wrapper_0/rst_n] [get_bd_pins smartconnect_1/aresetn]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins aclk] [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] [get_bd_pins axi_dma_0/s_axi_lite_aclk] [get_bd_pins axi_gpio_to_cms_ctrl_interface/s_axi_aclk] [get_bd_pins axis_data_fifo_0/s_axis_aclk] [get_bd_pins cms_ip_wrapper_0/clk] [get_bd_pins smartconnect_1/aclk]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: bram_logic
proc create_hier_cell_bram_logic { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_bram_logic() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I -from 352 -to 0 Din
  create_bd_pin -dir O -from 0 -to 0 Dout
  create_bd_pin -dir I -from 0 -to 0 Op1
  create_bd_pin -dir O -from 31 -to 0 addra
  create_bd_pin -dir I -from 31 -to 0 addrb
  create_bd_pin -dir I -type clk clka
  create_bd_pin -dir O delayed_sig
  create_bd_pin -dir O -from 255 -to 0 dina
  create_bd_pin -dir I -from 255 -to 0 dinb
  create_bd_pin -dir O -from 255 -to 0 douta
  create_bd_pin -dir I -type rst rst_n
  create_bd_pin -dir I -from 0 -to 0 web

  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0 ]
  set_property -dict [ list \
   CONFIG.Assume_Synchronous_Clk {true} \
   CONFIG.Byte_Size {9} \
   CONFIG.EN_SAFETY_CKT {false} \
   CONFIG.Enable_32bit_Address {false} \
   CONFIG.Enable_A {Use_ENA_Pin} \
   CONFIG.Enable_B {Always_Enabled} \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {50} \
   CONFIG.Read_Width_A {256} \
   CONFIG.Read_Width_B {256} \
   CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
   CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
   CONFIG.Use_Byte_Write_Enable {false} \
   CONFIG.Use_RSTA_Pin {false} \
   CONFIG.Use_RSTB_Pin {false} \
   CONFIG.Write_Width_A {256} \
   CONFIG.Write_Width_B {256} \
   CONFIG.use_bram_block {Stand_Alone} \
 ] $blk_mem_gen_0

  # Create instance: memory_read_ready_delayer, and set properties
  set block_name delayer
  set block_cell_name memory_read_ready_delayer
  if { [catch {set memory_read_ready_delayer [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $memory_read_ready_delayer eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property USER_COMMENTS.comment_16 "Data from ram is ready after one clock cycle, the purpose of delayer is to let the SoC know the data is ready at the right time" [get_bd_cells /PYNQ_wrapper_blocks/bram_logic/memory_read_ready_delayer]
  set_property USER_COMMENTS.comment_1 "Data from ram is ready after one clock cycle, the purpose of delayer is to let the SoC know the data is ready at the right time" [get_bd_cells /PYNQ_wrapper_blocks/bram_logic/memory_read_ready_delayer]
  set_property USER_COMMENTS.comment_18 "13 bits implemented by this design (2**13 = 8192)" [get_bd_cells /PYNQ_wrapper_blocks/bram_logic/memory_read_ready_delayer]

  # Create instance: not_write_enable, and set properties
  set not_write_enable [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 not_write_enable ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $not_write_enable

  # Create instance: read_address, and set properties
  set read_address [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 read_address ]
  set_property USER_COMMENTS.comment_12 "Full length the SoC assumes is available (64 bits)" [get_bd_cells /PYNQ_wrapper_blocks/bram_logic/read_address]
  set_property -dict [ list \
   CONFIG.DIN_FROM {319} \
   CONFIG.DIN_TO {256} \
   CONFIG.DIN_WIDTH {353} \
   CONFIG.DOUT_WIDTH {64} \
 ] $read_address

  # Create instance: read_address1, and set properties
  set read_address1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 read_address1 ]
  set_property USER_COMMENTS.comment_13 "13 bits implemented by this design (2**13 = 8192)" [get_bd_cells /PYNQ_wrapper_blocks/bram_logic/read_address1]
  set_property -dict [ list \
   CONFIG.DIN_FROM {31} \
   CONFIG.DIN_TO {0} \
   CONFIG.DIN_WIDTH {64} \
   CONFIG.DOUT_WIDTH {32} \
 ] $read_address1

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [ list \
   CONFIG.C_SIZE {1} \
 ] $util_vector_logic_0

  # Create instance: util_vector_logic_3, and set properties
  set util_vector_logic_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_3 ]
  set_property -dict [ list \
   CONFIG.C_SIZE {1} \
 ] $util_vector_logic_3

  # Create instance: write_data, and set properties
  set write_data [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 write_data ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {255} \
   CONFIG.DIN_WIDTH {353} \
   CONFIG.DOUT_WIDTH {256} \
 ] $write_data

  # Create instance: write_enable, and set properties
  set write_enable [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 write_enable ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {352} \
   CONFIG.DIN_TO {352} \
   CONFIG.DIN_WIDTH {353} \
   CONFIG.DOUT_WIDTH {1} \
 ] $write_enable

  # Create port connections
  connect_bd_net -net Net [get_bd_pins blk_mem_gen_0/wea] [get_bd_pins util_vector_logic_0/Res]
  connect_bd_net -net blk_mem_gen_0_douta [get_bd_pins douta] [get_bd_pins blk_mem_gen_0/douta]
  connect_bd_net -net delayer_0_delayed_sig [get_bd_pins delayed_sig] [get_bd_pins memory_read_ready_delayer/delayed_sig]
  connect_bd_net -net gpio_0_Dout [get_bd_pins rst_n] [get_bd_pins memory_read_ready_delayer/rst_n]
  connect_bd_net -net mkSoC_Top_0_RDY_to_raw_mem_request_get [get_bd_pins Op1] [get_bd_pins blk_mem_gen_0/ena] [get_bd_pins util_vector_logic_0/Op2] [get_bd_pins util_vector_logic_3/Op1]
  connect_bd_net -net mkSoC_Top_0_to_raw_mem_request_get [get_bd_pins Din] [get_bd_pins read_address/Din] [get_bd_pins write_data/Din] [get_bd_pins write_enable/Din]
  connect_bd_net -net read_address1_Dout [get_bd_pins addra] [get_bd_pins blk_mem_gen_0/addra] [get_bd_pins read_address1/Dout]
  connect_bd_net -net read_address_Dout [get_bd_pins read_address/Dout] [get_bd_pins read_address1/Din]
  connect_bd_net -net shift_register_0_addr [get_bd_pins addrb] [get_bd_pins blk_mem_gen_0/addrb]
  connect_bd_net -net shift_register_0_data [get_bd_pins dinb] [get_bd_pins blk_mem_gen_0/dinb]
  connect_bd_net -net util_vector_logic_2_Res [get_bd_pins not_write_enable/Res] [get_bd_pins util_vector_logic_3/Op2]
  connect_bd_net -net util_vector_logic_3_Res [get_bd_pins memory_read_ready_delayer/sig] [get_bd_pins util_vector_logic_3/Res]
  connect_bd_net -net write_data_Dout [get_bd_pins dina] [get_bd_pins blk_mem_gen_0/dina] [get_bd_pins write_data/Dout]
  connect_bd_net -net write_enable_Dout [get_bd_pins Dout] [get_bd_pins not_write_enable/Op1] [get_bd_pins util_vector_logic_0/Op1] [get_bd_pins write_enable/Dout]
  connect_bd_net -net xlslice_3_Dout [get_bd_pins web] [get_bd_pins blk_mem_gen_0/web]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins clka] [get_bd_pins blk_mem_gen_0/clka] [get_bd_pins blk_mem_gen_0/clkb] [get_bd_pins memory_read_ready_delayer/clk]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: bram_loader
proc create_hier_cell_bram_loader { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_bram_loader() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI


  # Create pins
  create_bd_pin -dir O -from 0 -to 0 Dout
  create_bd_pin -dir O -from 31 -to 0 addr
  create_bd_pin -dir O -from 255 -to 0 data
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn

  # Create instance: axi_gpio_2, and set properties
  set axi_gpio_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_2 ]
  set_property -dict [ list \
   CONFIG.C_ALL_INPUTS_2 {0} \
   CONFIG.C_ALL_OUTPUTS {1} \
   CONFIG.C_ALL_OUTPUTS_2 {0} \
   CONFIG.C_IS_DUAL {0} \
 ] $axi_gpio_2

  # Create instance: bram_write_enable_18_18, and set properties
  set bram_write_enable_18_18 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 bram_write_enable_18_18 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {18} \
   CONFIG.DIN_TO {18} \
   CONFIG.DOUT_WIDTH {1} \
 ] $bram_write_enable_18_18

  # Create instance: data_input_0_15, and set properties
  set data_input_0_15 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 data_input_0_15 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {15} \
   CONFIG.DOUT_WIDTH {16} \
 ] $data_input_0_15

  # Create instance: select_data_17_17, and set properties
  set select_data_17_17 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 select_data_17_17 ]
  set_property USER_COMMENTS.comment_18 "select_data values meaning:
1=shifting data (16x16bits = 256)
0=shifting address (2x16bits = 32)" [get_bd_cells /PYNQ_wrapper_blocks/bram_loader/select_data_17_17]
  set_property -dict [ list \
   CONFIG.DIN_FROM {17} \
   CONFIG.DIN_TO {17} \
   CONFIG.DOUT_WIDTH {1} \
 ] $select_data_17_17

  # Create instance: shift_16_16, and set properties
  set shift_16_16 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 shift_16_16 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {16} \
   CONFIG.DIN_TO {16} \
   CONFIG.DOUT_WIDTH {1} \
 ] $shift_16_16

  # Create instance: shift_register_0, and set properties
  set block_name shift_register
  set block_cell_name shift_register_0
  if { [catch {set shift_register_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $shift_register_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create interface connections
  connect_bd_intf_net -intf_net axi_smc_M01_AXI [get_bd_intf_pins S_AXI] [get_bd_intf_pins axi_gpio_2/S_AXI]

  # Create port connections
  connect_bd_net -net axi_gpio_2_gpio_io_o [get_bd_pins axi_gpio_2/gpio_io_o] [get_bd_pins bram_write_enable_18_18/Din] [get_bd_pins data_input_0_15/Din] [get_bd_pins select_data_17_17/Din] [get_bd_pins shift_16_16/Din]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins s_axi_aresetn] [get_bd_pins axi_gpio_2/s_axi_aresetn]
  connect_bd_net -net shift_register_0_addr [get_bd_pins addr] [get_bd_pins shift_register_0/addr]
  connect_bd_net -net shift_register_0_data [get_bd_pins data] [get_bd_pins shift_register_0/data]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins data_input_0_15/Dout] [get_bd_pins shift_register_0/in]
  connect_bd_net -net xlslice_1_Dout [get_bd_pins shift_16_16/Dout] [get_bd_pins shift_register_0/shift]
  connect_bd_net -net xlslice_2_Dout [get_bd_pins select_data_17_17/Dout] [get_bd_pins shift_register_0/select_data]
  connect_bd_net -net xlslice_3_Dout [get_bd_pins Dout] [get_bd_pins bram_write_enable_18_18/Dout]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins s_axi_aclk] [get_bd_pins axi_gpio_2/s_axi_aclk]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: sensors_blocks
proc create_hier_cell_sensors_blocks { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_sensors_blocks() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Monitor -vlnv xilinx.com:interface:bram_rtl:1.0 BRAM_PORTA

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI


  # Create pins
  create_bd_pin -dir O -from 4 -to 0 -type data S
  create_bd_pin -dir O XADC_GPIO_0
  create_bd_pin -dir O XADC_GPIO_1
  create_bd_pin -dir O XADC_GPIO_2
  create_bd_pin -dir O XADC_GPIO_3
  create_bd_pin -dir I XADC_VAUX0N_R
  create_bd_pin -dir I XADC_VAUX0P_R
  create_bd_pin -dir O -from 8 -to 0 addr_out
  create_bd_pin -dir O -from 11 -to 0 bram_addr_a
  create_bd_pin -dir O -from 4 -to 0 channel_out1
  create_bd_pin -dir I -type clk clkb
  create_bd_pin -dir O -from 15 -to 0 do_out1
  create_bd_pin -dir O -from 63 -to 0 doutb
  create_bd_pin -dir O drdy_out1
  create_bd_pin -dir O eoc_out
  create_bd_pin -dir O -from 4 -to 0 muxaddr_out
  create_bd_pin -dir I -type rst reset_in
  create_bd_pin -dir I -type rst s_axi_aresetn

  # Create instance: axi_bram_ctrl_sensors, and set properties
  set axi_bram_ctrl_sensors [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_sensors ]
  set_property -dict [ list \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.ECC_TYPE {0} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $axi_bram_ctrl_sensors

  # Create instance: blk_mem_gen_sensors, and set properties
  set blk_mem_gen_sensors [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_sensors ]
  set_property -dict [ list \
   CONFIG.Byte_Size {9} \
   CONFIG.EN_SAFETY_CKT {false} \
   CONFIG.Enable_32bit_Address {false} \
   CONFIG.Enable_A {Always_Enabled} \
   CONFIG.Enable_B {Always_Enabled} \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {50} \
   CONFIG.Read_Width_A {64} \
   CONFIG.Read_Width_B {64} \
   CONFIG.Register_PortA_Output_of_Memory_Core {false} \
   CONFIG.Register_PortA_Output_of_Memory_Primitives {true} \
   CONFIG.Register_PortB_Output_of_Memory_Primitives {true} \
   CONFIG.Use_Byte_Write_Enable {false} \
   CONFIG.Use_REGCEA_Pin {false} \
   CONFIG.Use_RSTA_Pin {false} \
   CONFIG.Use_RSTB_Pin {false} \
   CONFIG.Write_Depth_A {128} \
   CONFIG.Write_Width_A {64} \
   CONFIG.Write_Width_B {64} \
   CONFIG.use_bram_block {Stand_Alone} \
 ] $blk_mem_gen_sensors

  # Create instance: c_addsub_minus_0x10, and set properties
  set c_addsub_minus_0x10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:c_addsub:12.0 c_addsub_minus_0x10 ]
  set_property -dict [ list \
   CONFIG.A_Type {Unsigned} \
   CONFIG.A_Width {5} \
   CONFIG.Add_Mode {Subtract} \
   CONFIG.B_Constant {true} \
   CONFIG.B_Type {Unsigned} \
   CONFIG.B_Value {10000} \
   CONFIG.B_Width {5} \
   CONFIG.CE {false} \
   CONFIG.Latency {0} \
   CONFIG.Out_Width {5} \
 ] $c_addsub_minus_0x10

  # Create instance: mux_select_to_gpio_0, and set properties
  set block_name mux_select_to_gpio
  set block_cell_name mux_select_to_gpio_0
  if { [catch {set mux_select_to_gpio_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $mux_select_to_gpio_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: xadc_wiz_0, and set properties
  set xadc_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xadc_wiz:3.3 xadc_wiz_0 ]
  set_property -dict [ list \
   CONFIG.ADC_CONVERSION_RATE {39} \
   CONFIG.ADC_OFFSET_AND_GAIN_CALIBRATION {false} \
   CONFIG.CHANNEL_AVERAGING {None} \
   CONFIG.CHANNEL_ENABLE_VAUXP0_VAUXN0 {true} \
   CONFIG.CHANNEL_ENABLE_VAUXP1_VAUXN1 {true} \
   CONFIG.CHANNEL_ENABLE_VAUXP2_VAUXN2 {true} \
   CONFIG.CHANNEL_ENABLE_VAUXP3_VAUXN3 {true} \
   CONFIG.CHANNEL_ENABLE_VAUXP4_VAUXN4 {true} \
   CONFIG.CHANNEL_ENABLE_VAUXP5_VAUXN5 {true} \
   CONFIG.CHANNEL_ENABLE_VAUXP6_VAUXN6 {true} \
   CONFIG.CHANNEL_ENABLE_VP_VN {false} \
   CONFIG.DCLK_FREQUENCY {50} \
   CONFIG.ENABLE_CALIBRATION_AVERAGING {false} \
   CONFIG.ENABLE_EXTERNAL_MUX {true} \
   CONFIG.ENABLE_RESET {true} \
   CONFIG.ENABLE_VCCDDRO_ALARM {false} \
   CONFIG.ENABLE_VCCPAUX_ALARM {false} \
   CONFIG.ENABLE_VCCPINT_ALARM {false} \
   CONFIG.EXTERNAL_MUX_CHANNEL {VAUXP0_VAUXN0} \
   CONFIG.INTERFACE_SELECTION {ENABLE_DRP} \
   CONFIG.OT_ALARM {false} \
   CONFIG.SENSOR_OFFSET_AND_GAIN_CALIBRATION {false} \
   CONFIG.SEQUENCER_MODE {Continuous} \
   CONFIG.SINGLE_CHANNEL_SELECTION {VAUXP0_VAUXN0} \
   CONFIG.USER_TEMP_ALARM {false} \
   CONFIG.VCCAUX_ALARM {false} \
   CONFIG.VCCINT_ALARM {false} \
   CONFIG.XADC_STARUP_SELECTION {channel_sequencer} \
 ] $xadc_wiz_0

  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {11} \
   CONFIG.DIN_TO {3} \
   CONFIG.DIN_WIDTH {12} \
   CONFIG.DOUT_WIDTH {9} \
 ] $xlslice_0

  # Create interface connections
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_sensors/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_sensors/BRAM_PORTA]
  connect_bd_intf_net -intf_net [get_bd_intf_nets axi_bram_ctrl_0_BRAM_PORTA] [get_bd_intf_pins BRAM_PORTA] [get_bd_intf_pins axi_bram_ctrl_sensors/BRAM_PORTA]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_intf_nets axi_bram_ctrl_0_BRAM_PORTA]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins S_AXI] [get_bd_intf_pins axi_bram_ctrl_sensors/S_AXI]

  # Create port connections
  connect_bd_net -net XADC_VAUX0N_R_1 [get_bd_pins XADC_VAUX0N_R] [get_bd_pins xadc_wiz_0/vauxn0]
  connect_bd_net -net XADC_VAUX0P_R_1 [get_bd_pins XADC_VAUX0P_R] [get_bd_pins xadc_wiz_0/vauxp0]
  connect_bd_net -net addr_divider_0_addr_out [get_bd_pins addr_out] [get_bd_pins blk_mem_gen_sensors/addra] [get_bd_pins xlslice_0/Dout]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets addr_divider_0_addr_out]
  connect_bd_net -net axi_bram_ctrl_sensors_bram_addr_a [get_bd_pins bram_addr_a] [get_bd_pins axi_bram_ctrl_sensors/bram_addr_a] [get_bd_pins xlslice_0/Din]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets axi_bram_ctrl_sensors_bram_addr_a]
  connect_bd_net -net c_addsub_0_S [get_bd_pins S] [get_bd_pins blk_mem_gen_sensors/addrb] [get_bd_pins c_addsub_minus_0x10/S]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets c_addsub_0_S]
  connect_bd_net -net channel_out [get_bd_pins channel_out1] [get_bd_pins c_addsub_minus_0x10/A] [get_bd_pins xadc_wiz_0/channel_out]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets channel_out]
  connect_bd_net -net do_out [get_bd_pins do_out1] [get_bd_pins blk_mem_gen_sensors/dinb] [get_bd_pins xadc_wiz_0/do_out]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets do_out]
  connect_bd_net -net doutb [get_bd_pins doutb] [get_bd_pins blk_mem_gen_sensors/doutb]
  connect_bd_net -net drdy_out [get_bd_pins drdy_out1] [get_bd_pins blk_mem_gen_sensors/web] [get_bd_pins xadc_wiz_0/drdy_out]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets drdy_out]
  connect_bd_net -net mux_select_to_gpio_0_gpio_0 [get_bd_pins XADC_GPIO_0] [get_bd_pins mux_select_to_gpio_0/gpio_0]
  connect_bd_net -net mux_select_to_gpio_0_gpio_1 [get_bd_pins XADC_GPIO_1] [get_bd_pins mux_select_to_gpio_0/gpio_1]
  connect_bd_net -net mux_select_to_gpio_0_gpio_2 [get_bd_pins XADC_GPIO_2] [get_bd_pins mux_select_to_gpio_0/gpio_2]
  connect_bd_net -net mux_select_to_gpio_0_gpio_3 [get_bd_pins XADC_GPIO_3] [get_bd_pins mux_select_to_gpio_0/gpio_3]
  connect_bd_net -net muxaddr_out [get_bd_pins muxaddr_out] [get_bd_pins mux_select_to_gpio_0/muxaddr_out] [get_bd_pins xadc_wiz_0/daddr_in] [get_bd_pins xadc_wiz_0/muxaddr_out]
  connect_bd_net -net proc_sys_reset_0_peripheral_reset [get_bd_pins reset_in] [get_bd_pins xadc_wiz_0/reset_in]
  connect_bd_net -net s_axi_aresetn_1 [get_bd_pins s_axi_aresetn] [get_bd_pins axi_bram_ctrl_sensors/s_axi_aresetn]
  connect_bd_net -net xadc_wiz_0_eoc_out [get_bd_pins eoc_out] [get_bd_pins xadc_wiz_0/den_in] [get_bd_pins xadc_wiz_0/eoc_out]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets xadc_wiz_0_eoc_out]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins clkb] [get_bd_pins axi_bram_ctrl_sensors/s_axi_aclk] [get_bd_pins blk_mem_gen_sensors/clkb] [get_bd_pins xadc_wiz_0/dclk_in]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: PYNQ_wrapper_blocks
proc create_hier_cell_PYNQ_wrapper_blocks { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_PYNQ_wrapper_blocks() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M03_AXI

  create_bd_intf_pin -mode Monitor -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S01_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S02_AXI


  # Create pins
  create_bd_pin -dir O -from 31 -to 0 AXI_GPIO_output
  create_bd_pin -dir O -from 9 -to 0 M03_AXI_awaddr1
  create_bd_pin -dir O -from 31 -to 0 M03_AXI_wdata1
  create_bd_pin -dir I M03_AXI_wready1
  create_bd_pin -dir O M03_AXI_wvalid1
  create_bd_pin -dir I -from 0 -to 0 RDY_put_from_console_put
  create_bd_pin -dir I -from 0 -to 0 RDY_to_raw_mem_request_get
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir O -from 7 -to 0 console_input_data
  create_bd_pin -dir O -from 0 -to 0 console_input_en
  create_bd_pin -dir I -from 7 -to 0 console_out_data
  create_bd_pin -dir I console_out_we
  create_bd_pin -dir I -from 0 -to 0 cpu_reset_completed
  create_bd_pin -dir I -from 511 -to 0 general_purpose_registers
  create_bd_pin -dir O halt_cpu
  create_bd_pin -dir O -from 10 -to 0 input_fifo_counter1
  create_bd_pin -dir I -from 31 -to 0 instr
  create_bd_pin -dir O -from 63 -to 0 item_counter_probe
  create_bd_pin -dir O -from 255 -to 0 memory_data
  create_bd_pin -dir O memory_we
  create_bd_pin -dir O -from 10 -to 0 output_fifo_counter1
  create_bd_pin -dir I -from 63 -to 0 pc
  create_bd_pin -dir I -from 38 -to 0 performance_events
  create_bd_pin -dir O -from 0 -to 0 -type rst rst_n
  create_bd_pin -dir I -from 352 -to 0 to_raw_mem_request_get

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [ list \
   CONFIG.C_ALL_INPUTS_2 {1} \
   CONFIG.C_ALL_OUTPUTS {1} \
   CONFIG.C_IS_DUAL {1} \
 ] $axi_gpio_0

  # Create instance: axi_gpio_3, and set properties
  set axi_gpio_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_3 ]
  set_property -dict [ list \
   CONFIG.C_ALL_INPUTS {0} \
   CONFIG.C_ALL_INPUTS_2 {1} \
   CONFIG.C_ALL_OUTPUTS {1} \
   CONFIG.C_ALL_OUTPUTS_2 {0} \
   CONFIG.C_IS_DUAL {1} \
 ] $axi_gpio_3

  # Create instance: axi_smc, and set properties
  set axi_smc [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc ]
  set_property -dict [ list \
   CONFIG.NUM_MI {8} \
   CONFIG.NUM_SI {1} \
 ] $axi_smc

  # Create instance: bram_loader
  create_hier_cell_bram_loader $hier_obj bram_loader

  # Create instance: bram_logic
  create_hier_cell_bram_logic $hier_obj bram_logic

  # Create instance: console_io_0, and set properties
  set block_name console_io
  set block_cell_name console_io_0
  if { [catch {set console_io_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $console_io_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: continuous_monitoring_system_blocks
  create_hier_cell_continuous_monitoring_system_blocks $hier_obj continuous_monitoring_system_blocks

  # Create instance: gpio_0, and set properties
  set gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 gpio_0 ]

  # Create instance: gpio_1_rst_console_input, and set properties
  set gpio_1_rst_console_input [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 gpio_1_rst_console_input ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {1} \
   CONFIG.DIN_TO {1} \
   CONFIG.DOUT_WIDTH {1} \
 ] $gpio_1_rst_console_input

  # Create instance: gpio_2_rst_console_output, and set properties
  set gpio_2_rst_console_output [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 gpio_2_rst_console_output ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {2} \
   CONFIG.DIN_TO {2} \
   CONFIG.DOUT_WIDTH {1} \
 ] $gpio_2_rst_console_output

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins M_AXIS] [get_bd_intf_pins continuous_monitoring_system_blocks/M_AXIS]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins M03_AXI] [get_bd_intf_pins axi_smc/M03_AXI]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins S02_AXI] [get_bd_intf_pins continuous_monitoring_system_blocks/S02_AXI]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins S01_AXI] [get_bd_intf_pins continuous_monitoring_system_blocks/S01_AXI]
  connect_bd_intf_net -intf_net axi_smc_M01_AXI [get_bd_intf_pins axi_smc/M01_AXI] [get_bd_intf_pins bram_loader/S_AXI]
  connect_bd_intf_net -intf_net axi_smc_M02_AXI [get_bd_intf_pins axi_gpio_0/S_AXI] [get_bd_intf_pins axi_smc/M02_AXI]
  connect_bd_intf_net -intf_net axi_smc_M04_AXI [get_bd_intf_pins axi_smc/M04_AXI] [get_bd_intf_pins continuous_monitoring_system_blocks/S_AXI_LITE]
  connect_bd_intf_net -intf_net axi_smc_M06_AXI [get_bd_intf_pins axi_smc/M06_AXI] [get_bd_intf_pins continuous_monitoring_system_blocks/S_AXI]
  connect_bd_intf_net -intf_net axi_smc_M07_AXI [get_bd_intf_pins axi_gpio_3/S_AXI] [get_bd_intf_pins axi_smc/M07_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins S00_AXI] [get_bd_intf_pins axi_smc/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_1_M00_AXI [get_bd_intf_pins M00_AXI] [get_bd_intf_pins continuous_monitoring_system_blocks/M00_AXI]

  # Create port connections
  connect_bd_net -net Din_1 [get_bd_pins to_raw_mem_request_get] [get_bd_pins bram_logic/Din]
  connect_bd_net -net In4_1 [get_bd_pins cpu_reset_completed] [get_bd_pins console_io_0/cpu_reset_completed]
  connect_bd_net -net M03_AXI_wready1_1 [get_bd_pins M03_AXI_wready1] [get_bd_pins axi_smc/M03_AXI_wready]
  connect_bd_net -net RDY_get_to_console_get [get_bd_pins console_out_we] [get_bd_pins console_io_0/RDY_get_to_console_get]
  connect_bd_net -net axi_gpio_0_gpio_io_o [get_bd_pins axi_gpio_0/gpio_io_o] [get_bd_pins gpio_0/Din] [get_bd_pins gpio_1_rst_console_input/Din] [get_bd_pins gpio_2_rst_console_output/Din]
  connect_bd_net -net axi_gpio_3_gpio_io_o [get_bd_pins axi_gpio_3/gpio_io_o] [get_bd_pins console_io_0/AXI_GPIO_input]
  connect_bd_net -net axi_smc_M03_AXI_awaddr [get_bd_pins M03_AXI_awaddr1] [get_bd_pins axi_smc/M03_AXI_awaddr]
  connect_bd_net -net axi_smc_M03_AXI_wdata [get_bd_pins M03_AXI_wdata1] [get_bd_pins axi_smc/M03_AXI_wdata]
  connect_bd_net -net axi_smc_M03_AXI_wvalid [get_bd_pins M03_AXI_wvalid1] [get_bd_pins axi_smc/M03_AXI_wvalid]
  connect_bd_net -net axis_data_fifo_0_axis_wr_data_count [get_bd_pins axi_gpio_0/gpio2_io_i] [get_bd_pins continuous_monitoring_system_blocks/axis_wr_data_count]
  connect_bd_net -net blk_mem_gen_0_douta [get_bd_pins memory_data] [get_bd_pins bram_logic/douta]
  connect_bd_net -net console_io_0_AXI_GPIO_output [get_bd_pins AXI_GPIO_output] [get_bd_pins axi_gpio_3/gpio2_io_i] [get_bd_pins console_io_0/AXI_GPIO_output]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets console_io_0_AXI_GPIO_output]
  connect_bd_net -net console_io_0_EN_put_from_console_put [get_bd_pins console_input_en] [get_bd_pins console_io_0/EN_put_from_console_put]
  connect_bd_net -net console_io_0_put_from_console_put [get_bd_pins console_input_data] [get_bd_pins console_io_0/put_from_console_put]
  connect_bd_net -net continuous_monitoring_system_blocks_halt_cpu [get_bd_pins halt_cpu] [get_bd_pins continuous_monitoring_system_blocks/halt_cpu]
  connect_bd_net -net continuous_monitoring_system_blocks_item_counter_probe1 [get_bd_pins item_counter_probe] [get_bd_pins continuous_monitoring_system_blocks/item_counter_probe1]
  connect_bd_net -net delayer_0_delayed_sig [get_bd_pins memory_we] [get_bd_pins bram_logic/delayed_sig]
  connect_bd_net -net general_purpose_registers_1 [get_bd_pins general_purpose_registers] [get_bd_pins continuous_monitoring_system_blocks/general_purpose_registers]
  connect_bd_net -net get_to_console_get [get_bd_pins console_out_data] [get_bd_pins console_io_0/get_to_console_get]
  connect_bd_net -net gpio_0_Dout [get_bd_pins rst_n] [get_bd_pins bram_logic/rst_n] [get_bd_pins console_io_0/rst_n] [get_bd_pins continuous_monitoring_system_blocks/en] [get_bd_pins gpio_0/Dout]
  connect_bd_net -net gpio_1_rst_console_input_Dout [get_bd_pins console_io_0/rst_n_input_fifo] [get_bd_pins gpio_1_rst_console_input/Dout]
  connect_bd_net -net gpio_2_rst_console_output_Dout [get_bd_pins console_io_0/rst_n_output_fifo] [get_bd_pins gpio_2_rst_console_output/Dout]
  connect_bd_net -net input_fifo_counter [get_bd_pins input_fifo_counter1] [get_bd_pins console_io_0/input_fifo_counter]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets input_fifo_counter]
  connect_bd_net -net mkCore_Synth_0_instr [get_bd_pins instr] [get_bd_pins continuous_monitoring_system_blocks/instr]
  connect_bd_net -net mkCore_Synth_0_pc [get_bd_pins pc] [get_bd_pins continuous_monitoring_system_blocks/pc]
  connect_bd_net -net mkSoC_Top_0_RDY_put_from_console_put [get_bd_pins RDY_put_from_console_put] [get_bd_pins console_io_0/RDY_put_from_console_put]
  connect_bd_net -net mkSoC_Top_0_RDY_to_raw_mem_request_get [get_bd_pins RDY_to_raw_mem_request_get] [get_bd_pins bram_logic/Op1]
  connect_bd_net -net mkSoC_Top_1_cms_ifc_performance_events [get_bd_pins performance_events] [get_bd_pins continuous_monitoring_system_blocks/performance_events]
  connect_bd_net -net output_fifo_counter [get_bd_pins output_fifo_counter1] [get_bd_pins console_io_0/output_fifo_counter]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets output_fifo_counter]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins aresetn] [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins axi_gpio_3/s_axi_aresetn] [get_bd_pins axi_smc/aresetn] [get_bd_pins bram_loader/s_axi_aresetn] [get_bd_pins continuous_monitoring_system_blocks/aresetn]
  connect_bd_net -net shift_register_0_addr [get_bd_pins bram_loader/addr] [get_bd_pins bram_logic/addrb]
  connect_bd_net -net shift_register_0_data [get_bd_pins bram_loader/data] [get_bd_pins bram_logic/dinb]
  connect_bd_net -net xlslice_3_Dout [get_bd_pins bram_loader/Dout] [get_bd_pins bram_logic/web]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins clk] [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins axi_gpio_3/s_axi_aclk] [get_bd_pins axi_smc/aclk] [get_bd_pins bram_loader/s_axi_aclk] [get_bd_pins bram_logic/clka] [get_bd_pins console_io_0/clk] [get_bd_pins continuous_monitoring_system_blocks/aclk]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]

  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]


  # Create ports
  set PMOD1_0_LS [ create_bd_port -dir O -type data PMOD1_0_LS ]
  set PMOD1_1_LS [ create_bd_port -dir O -type data PMOD1_1_LS ]
  set PMOD1_4_LS [ create_bd_port -dir O -type data PMOD1_4_LS ]
  set PMOD1_5_LS [ create_bd_port -dir O -type data PMOD1_5_LS ]
  set XADC_GPIO_0 [ create_bd_port -dir O -type data XADC_GPIO_0 ]
  set XADC_GPIO_1 [ create_bd_port -dir O -type data XADC_GPIO_1 ]
  set XADC_GPIO_2 [ create_bd_port -dir O -type data XADC_GPIO_2 ]
  set XADC_GPIO_3 [ create_bd_port -dir O -type data XADC_GPIO_3 ]
  set XADC_VAUX0N_R [ create_bd_port -dir I XADC_VAUX0N_R ]
  set XADC_VAUX0P_R [ create_bd_port -dir I XADC_VAUX0P_R ]

  # Create instance: CHERI_RISCV_Flute_mkSoC_Top, and set properties
  set block_name mkSoC_Top
  set block_cell_name CHERI_RISCV_Flute_mkSoC_Top
  if { [catch {set CHERI_RISCV_Flute_mkSoC_Top [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $CHERI_RISCV_Flute_mkSoC_Top eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: PYNQ_wrapper_blocks
  create_hier_cell_PYNQ_wrapper_blocks [current_bd_instance .] PYNQ_wrapper_blocks

  # Create instance: ZYNQ_ARM_processing_system, and set properties
  set ZYNQ_ARM_processing_system [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 ZYNQ_ARM_processing_system ]
  set_property -dict [ list \
   CONFIG.PCW_ACT_APU_PERIPHERAL_FREQMHZ {666.666687} \
   CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.158730} \
   CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {25.000000} \
   CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {50.000000} \
   CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {50.000000} \
   CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_TTC0_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC0_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC0_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC1_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC1_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC1_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {50.000000} \
   CONFIG.PCW_ACT_WDT_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {667.000000} \
   CONFIG.PCW_ARMPLL_CTRL_FBDIV {40} \
   CONFIG.PCW_CAN0_GRP_CLK_ENABLE {0} \
   CONFIG.PCW_CAN0_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_CAN_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_CAN_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_CAN_PERIPHERAL_FREQMHZ {100} \
   CONFIG.PCW_CLK0_FREQ {50000000} \
   CONFIG.PCW_CLK1_FREQ {10000000} \
   CONFIG.PCW_CLK2_FREQ {10000000} \
   CONFIG.PCW_CLK3_FREQ {10000000} \
   CONFIG.PCW_CPU_CPU_PLL_FREQMHZ {1333.333} \
   CONFIG.PCW_CPU_PERIPHERAL_DIVISOR0 {2} \
   CONFIG.PCW_DCI_PERIPHERAL_DIVISOR0 {15} \
   CONFIG.PCW_DCI_PERIPHERAL_DIVISOR1 {7} \
   CONFIG.PCW_DDRPLL_CTRL_FBDIV {32} \
   CONFIG.PCW_DDR_DDR_PLL_FREQMHZ {1066.667} \
   CONFIG.PCW_DDR_PERIPHERAL_DIVISOR0 {2} \
   CONFIG.PCW_DDR_RAM_HIGHADDR {0x3FFFFFFF} \
   CONFIG.PCW_DUAL_PARALLEL_QSPI_DATA_MODE {x8} \
   CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
   CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} \
   CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53} \
   CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR0 {8} \
   CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR1 {5} \
   CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {100 Mbps} \
   CONFIG.PCW_ENET0_RESET_ENABLE {1} \
   CONFIG.PCW_ENET0_RESET_IO {MIO 47} \
   CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_ENET1_RESET_ENABLE {0} \
   CONFIG.PCW_ENET_RESET_ENABLE {1} \
   CONFIG.PCW_ENET_RESET_SELECT {Share reset pin} \
   CONFIG.PCW_EN_EMIO_TTC0 {1} \
   CONFIG.PCW_EN_ENET0 {1} \
   CONFIG.PCW_EN_GPIO {1} \
   CONFIG.PCW_EN_I2C0 {1} \
   CONFIG.PCW_EN_QSPI {1} \
   CONFIG.PCW_EN_SDIO0 {1} \
   CONFIG.PCW_EN_TTC0 {1} \
   CONFIG.PCW_EN_UART1 {1} \
   CONFIG.PCW_EN_USB0 {1} \
   CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR0 {5} \
   CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR1 {4} \
   CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FPGA_FCLK0_ENABLE {1} \
   CONFIG.PCW_FPGA_FCLK1_ENABLE {0} \
   CONFIG.PCW_FPGA_FCLK2_ENABLE {0} \
   CONFIG.PCW_FPGA_FCLK3_ENABLE {0} \
   CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
   CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} \
   CONFIG.PCW_I2C0_GRP_INT_ENABLE {0} \
   CONFIG.PCW_I2C0_I2C0_IO {MIO 50 .. 51} \
   CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_I2C0_RESET_ENABLE {1} \
   CONFIG.PCW_I2C0_RESET_IO {MIO 46} \
   CONFIG.PCW_I2C1_RESET_ENABLE {0} \
   CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_I2C_RESET_ENABLE {1} \
   CONFIG.PCW_I2C_RESET_SELECT {Share reset pin} \
   CONFIG.PCW_IOPLL_CTRL_FBDIV {30} \
   CONFIG.PCW_IO_IO_PLL_FREQMHZ {1000.000} \
   CONFIG.PCW_IRQ_F2P_INTR {1} \
   CONFIG.PCW_MIO_0_DIRECTION {out} \
   CONFIG.PCW_MIO_0_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_0_PULLUP {enabled} \
   CONFIG.PCW_MIO_0_SLEW {slow} \
   CONFIG.PCW_MIO_10_DIRECTION {inout} \
   CONFIG.PCW_MIO_10_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_10_PULLUP {enabled} \
   CONFIG.PCW_MIO_10_SLEW {slow} \
   CONFIG.PCW_MIO_11_DIRECTION {inout} \
   CONFIG.PCW_MIO_11_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_11_PULLUP {enabled} \
   CONFIG.PCW_MIO_11_SLEW {slow} \
   CONFIG.PCW_MIO_12_DIRECTION {inout} \
   CONFIG.PCW_MIO_12_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_12_PULLUP {enabled} \
   CONFIG.PCW_MIO_12_SLEW {slow} \
   CONFIG.PCW_MIO_13_DIRECTION {inout} \
   CONFIG.PCW_MIO_13_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_13_PULLUP {enabled} \
   CONFIG.PCW_MIO_13_SLEW {slow} \
   CONFIG.PCW_MIO_14_DIRECTION {in} \
   CONFIG.PCW_MIO_14_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_14_PULLUP {enabled} \
   CONFIG.PCW_MIO_14_SLEW {slow} \
   CONFIG.PCW_MIO_15_DIRECTION {in} \
   CONFIG.PCW_MIO_15_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_15_PULLUP {enabled} \
   CONFIG.PCW_MIO_15_SLEW {slow} \
   CONFIG.PCW_MIO_16_DIRECTION {out} \
   CONFIG.PCW_MIO_16_IOTYPE {HSTL 1.8V} \
   CONFIG.PCW_MIO_16_PULLUP {disabled} \
   CONFIG.PCW_MIO_16_SLEW {slow} \
   CONFIG.PCW_MIO_17_DIRECTION {out} \
   CONFIG.PCW_MIO_17_IOTYPE {HSTL 1.8V} \
   CONFIG.PCW_MIO_17_PULLUP {disabled} \
   CONFIG.PCW_MIO_17_SLEW {slow} \
   CONFIG.PCW_MIO_18_DIRECTION {out} \
   CONFIG.PCW_MIO_18_IOTYPE {HSTL 1.8V} \
   CONFIG.PCW_MIO_18_PULLUP {disabled} \
   CONFIG.PCW_MIO_18_SLEW {slow} \
   CONFIG.PCW_MIO_19_DIRECTION {out} \
   CONFIG.PCW_MIO_19_IOTYPE {HSTL 1.8V} \
   CONFIG.PCW_MIO_19_PULLUP {disabled} \
   CONFIG.PCW_MIO_19_SLEW {slow} \
   CONFIG.PCW_MIO_1_DIRECTION {out} \
   CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_1_PULLUP {enabled} \
   CONFIG.PCW_MIO_1_SLEW {slow} \
   CONFIG.PCW_MIO_20_DIRECTION {out} \
   CONFIG.PCW_MIO_20_IOTYPE {HSTL 1.8V} \
   CONFIG.PCW_MIO_20_PULLUP {disabled} \
   CONFIG.PCW_MIO_20_SLEW {slow} \
   CONFIG.PCW_MIO_21_DIRECTION {out} \
   CONFIG.PCW_MIO_21_IOTYPE {HSTL 1.8V} \
   CONFIG.PCW_MIO_21_PULLUP {disabled} \
   CONFIG.PCW_MIO_21_SLEW {slow} \
   CONFIG.PCW_MIO_22_DIRECTION {in} \
   CONFIG.PCW_MIO_22_IOTYPE {HSTL 1.8V} \
   CONFIG.PCW_MIO_22_PULLUP {disabled} \
   CONFIG.PCW_MIO_22_SLEW {slow} \
   CONFIG.PCW_MIO_23_DIRECTION {in} \
   CONFIG.PCW_MIO_23_IOTYPE {HSTL 1.8V} \
   CONFIG.PCW_MIO_23_PULLUP {disabled} \
   CONFIG.PCW_MIO_23_SLEW {slow} \
   CONFIG.PCW_MIO_24_DIRECTION {in} \
   CONFIG.PCW_MIO_24_IOTYPE {HSTL 1.8V} \
   CONFIG.PCW_MIO_24_PULLUP {disabled} \
   CONFIG.PCW_MIO_24_SLEW {slow} \
   CONFIG.PCW_MIO_25_DIRECTION {in} \
   CONFIG.PCW_MIO_25_IOTYPE {HSTL 1.8V} \
   CONFIG.PCW_MIO_25_PULLUP {disabled} \
   CONFIG.PCW_MIO_25_SLEW {slow} \
   CONFIG.PCW_MIO_26_DIRECTION {in} \
   CONFIG.PCW_MIO_26_IOTYPE {HSTL 1.8V} \
   CONFIG.PCW_MIO_26_PULLUP {disabled} \
   CONFIG.PCW_MIO_26_SLEW {slow} \
   CONFIG.PCW_MIO_27_DIRECTION {in} \
   CONFIG.PCW_MIO_27_IOTYPE {HSTL 1.8V} \
   CONFIG.PCW_MIO_27_PULLUP {disabled} \
   CONFIG.PCW_MIO_27_SLEW {slow} \
   CONFIG.PCW_MIO_28_DIRECTION {inout} \
   CONFIG.PCW_MIO_28_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_28_PULLUP {disabled} \
   CONFIG.PCW_MIO_28_SLEW {slow} \
   CONFIG.PCW_MIO_29_DIRECTION {in} \
   CONFIG.PCW_MIO_29_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_29_PULLUP {disabled} \
   CONFIG.PCW_MIO_29_SLEW {slow} \
   CONFIG.PCW_MIO_2_DIRECTION {inout} \
   CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_2_PULLUP {disabled} \
   CONFIG.PCW_MIO_2_SLEW {slow} \
   CONFIG.PCW_MIO_30_DIRECTION {out} \
   CONFIG.PCW_MIO_30_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_30_PULLUP {disabled} \
   CONFIG.PCW_MIO_30_SLEW {slow} \
   CONFIG.PCW_MIO_31_DIRECTION {in} \
   CONFIG.PCW_MIO_31_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_31_PULLUP {disabled} \
   CONFIG.PCW_MIO_31_SLEW {slow} \
   CONFIG.PCW_MIO_32_DIRECTION {inout} \
   CONFIG.PCW_MIO_32_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_32_PULLUP {disabled} \
   CONFIG.PCW_MIO_32_SLEW {slow} \
   CONFIG.PCW_MIO_33_DIRECTION {inout} \
   CONFIG.PCW_MIO_33_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_33_PULLUP {disabled} \
   CONFIG.PCW_MIO_33_SLEW {slow} \
   CONFIG.PCW_MIO_34_DIRECTION {inout} \
   CONFIG.PCW_MIO_34_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_34_PULLUP {disabled} \
   CONFIG.PCW_MIO_34_SLEW {slow} \
   CONFIG.PCW_MIO_35_DIRECTION {inout} \
   CONFIG.PCW_MIO_35_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_35_PULLUP {disabled} \
   CONFIG.PCW_MIO_35_SLEW {slow} \
   CONFIG.PCW_MIO_36_DIRECTION {in} \
   CONFIG.PCW_MIO_36_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_36_PULLUP {disabled} \
   CONFIG.PCW_MIO_36_SLEW {slow} \
   CONFIG.PCW_MIO_37_DIRECTION {inout} \
   CONFIG.PCW_MIO_37_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_37_PULLUP {disabled} \
   CONFIG.PCW_MIO_37_SLEW {slow} \
   CONFIG.PCW_MIO_38_DIRECTION {inout} \
   CONFIG.PCW_MIO_38_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_38_PULLUP {disabled} \
   CONFIG.PCW_MIO_38_SLEW {slow} \
   CONFIG.PCW_MIO_39_DIRECTION {inout} \
   CONFIG.PCW_MIO_39_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_39_PULLUP {disabled} \
   CONFIG.PCW_MIO_39_SLEW {slow} \
   CONFIG.PCW_MIO_3_DIRECTION {inout} \
   CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_3_PULLUP {disabled} \
   CONFIG.PCW_MIO_3_SLEW {slow} \
   CONFIG.PCW_MIO_40_DIRECTION {inout} \
   CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_40_PULLUP {disabled} \
   CONFIG.PCW_MIO_40_SLEW {slow} \
   CONFIG.PCW_MIO_41_DIRECTION {inout} \
   CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_41_PULLUP {disabled} \
   CONFIG.PCW_MIO_41_SLEW {slow} \
   CONFIG.PCW_MIO_42_DIRECTION {inout} \
   CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_42_PULLUP {disabled} \
   CONFIG.PCW_MIO_42_SLEW {slow} \
   CONFIG.PCW_MIO_43_DIRECTION {inout} \
   CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_43_PULLUP {disabled} \
   CONFIG.PCW_MIO_43_SLEW {slow} \
   CONFIG.PCW_MIO_44_DIRECTION {inout} \
   CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_44_PULLUP {disabled} \
   CONFIG.PCW_MIO_44_SLEW {slow} \
   CONFIG.PCW_MIO_45_DIRECTION {inout} \
   CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_45_PULLUP {disabled} \
   CONFIG.PCW_MIO_45_SLEW {slow} \
   CONFIG.PCW_MIO_46_DIRECTION {out} \
   CONFIG.PCW_MIO_46_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_46_PULLUP {enabled} \
   CONFIG.PCW_MIO_46_SLEW {slow} \
   CONFIG.PCW_MIO_47_DIRECTION {out} \
   CONFIG.PCW_MIO_47_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_47_PULLUP {enabled} \
   CONFIG.PCW_MIO_47_SLEW {slow} \
   CONFIG.PCW_MIO_48_DIRECTION {out} \
   CONFIG.PCW_MIO_48_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_48_PULLUP {disabled} \
   CONFIG.PCW_MIO_48_SLEW {slow} \
   CONFIG.PCW_MIO_49_DIRECTION {in} \
   CONFIG.PCW_MIO_49_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_49_PULLUP {disabled} \
   CONFIG.PCW_MIO_49_SLEW {slow} \
   CONFIG.PCW_MIO_4_DIRECTION {inout} \
   CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_4_PULLUP {disabled} \
   CONFIG.PCW_MIO_4_SLEW {slow} \
   CONFIG.PCW_MIO_50_DIRECTION {inout} \
   CONFIG.PCW_MIO_50_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_50_PULLUP {enabled} \
   CONFIG.PCW_MIO_50_SLEW {slow} \
   CONFIG.PCW_MIO_51_DIRECTION {inout} \
   CONFIG.PCW_MIO_51_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_51_PULLUP {enabled} \
   CONFIG.PCW_MIO_51_SLEW {slow} \
   CONFIG.PCW_MIO_52_DIRECTION {out} \
   CONFIG.PCW_MIO_52_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_52_PULLUP {disabled} \
   CONFIG.PCW_MIO_52_SLEW {slow} \
   CONFIG.PCW_MIO_53_DIRECTION {inout} \
   CONFIG.PCW_MIO_53_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_53_PULLUP {disabled} \
   CONFIG.PCW_MIO_53_SLEW {slow} \
   CONFIG.PCW_MIO_5_DIRECTION {inout} \
   CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_5_PULLUP {disabled} \
   CONFIG.PCW_MIO_5_SLEW {slow} \
   CONFIG.PCW_MIO_6_DIRECTION {out} \
   CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_6_PULLUP {disabled} \
   CONFIG.PCW_MIO_6_SLEW {slow} \
   CONFIG.PCW_MIO_7_DIRECTION {out} \
   CONFIG.PCW_MIO_7_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_7_PULLUP {disabled} \
   CONFIG.PCW_MIO_7_SLEW {slow} \
   CONFIG.PCW_MIO_8_DIRECTION {out} \
   CONFIG.PCW_MIO_8_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_8_PULLUP {disabled} \
   CONFIG.PCW_MIO_8_SLEW {slow} \
   CONFIG.PCW_MIO_9_DIRECTION {out} \
   CONFIG.PCW_MIO_9_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_9_PULLUP {enabled} \
   CONFIG.PCW_MIO_9_SLEW {slow} \
   CONFIG.PCW_MIO_TREE_PERIPHERALS {Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#USB Reset#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#SD 0#SD 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#I2C Reset#ENET Reset#UART 1#UART 1#I2C 0#I2C 0#Enet 0#Enet 0} \
   CONFIG.PCW_MIO_TREE_SIGNALS {qspi1_ss_b#qspi0_ss_b#qspi0_io[0]#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]/HOLD_B#qspi0_sclk#reset#qspi_fbclk#qspi1_sclk#qspi1_io[0]#qspi1_io[1]#qspi1_io[2]#qspi1_io[3]#cd#wp#tx_clk#txd[0]#txd[1]#txd[2]#txd[3]#tx_ctl#rx_clk#rxd[0]#rxd[1]#rxd[2]#rxd[3]#rx_ctl#data[4]#dir#stp#nxt#data[0]#data[1]#data[2]#data[3]#clk#data[5]#data[6]#data[7]#clk#cmd#data[0]#data[1]#data[2]#data[3]#reset#reset#tx#rx#scl#sda#mdc#mdio} \
   CONFIG.PCW_NAND_GRP_D8_ENABLE {0} \
   CONFIG.PCW_NAND_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_A25_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_CS0_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_CS1_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_SRAM_CS0_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_SRAM_CS1_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_SRAM_INT_ENABLE {0} \
   CONFIG.PCW_NOR_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_PCAP_PERIPHERAL_DIVISOR0 {5} \
   CONFIG.PCW_PJTAG_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 1.8V} \
   CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} \
   CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {1} \
   CONFIG.PCW_QSPI_GRP_FBCLK_IO {MIO 8} \
   CONFIG.PCW_QSPI_GRP_IO1_ENABLE {1} \
   CONFIG.PCW_QSPI_GRP_IO1_IO {MIO 0 9 .. 13} \
   CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {0} \
   CONFIG.PCW_QSPI_GRP_SS1_ENABLE {0} \
   CONFIG.PCW_QSPI_INTERNAL_HIGHADDRESS {0xFDFFFFFF} \
   CONFIG.PCW_QSPI_PERIPHERAL_DIVISOR0 {5} \
   CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ {200} \
   CONFIG.PCW_QSPI_QSPI_IO {MIO 1 .. 6} \
   CONFIG.PCW_SD0_GRP_CD_ENABLE {1} \
   CONFIG.PCW_SD0_GRP_CD_IO {MIO 14} \
   CONFIG.PCW_SD0_GRP_POW_ENABLE {0} \
   CONFIG.PCW_SD0_GRP_WP_ENABLE {1} \
   CONFIG.PCW_SD0_GRP_WP_IO {MIO 15} \
   CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
   CONFIG.PCW_SDIO_PERIPHERAL_DIVISOR0 {20} \
   CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {50} \
   CONFIG.PCW_SDIO_PERIPHERAL_VALID {1} \
   CONFIG.PCW_SMC_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_SPI_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_TPIU_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_TTC0_CLK0_PERIPHERAL_FREQMHZ {133.333333} \
   CONFIG.PCW_TTC0_CLK1_PERIPHERAL_FREQMHZ {133.333333} \
   CONFIG.PCW_TTC0_CLK2_PERIPHERAL_FREQMHZ {133.333333} \
   CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_TTC0_TTC0_IO {EMIO} \
   CONFIG.PCW_TTC_PERIPHERAL_FREQMHZ {50} \
   CONFIG.PCW_UART1_GRP_FULL_ENABLE {0} \
   CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_UART1_UART1_IO {MIO 48 .. 49} \
   CONFIG.PCW_UART_PERIPHERAL_DIVISOR0 {20} \
   CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {50} \
   CONFIG.PCW_UART_PERIPHERAL_VALID {1} \
   CONFIG.PCW_UIPARAM_ACT_DDR_FREQ_MHZ {533.333374} \
   CONFIG.PCW_UIPARAM_DDR_BANK_ADDR_COUNT {3} \
   CONFIG.PCW_UIPARAM_DDR_BL {8} \
   CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.521} \
   CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.636} \
   CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {0.54} \
   CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.621} \
   CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {32 Bit} \
   CONFIG.PCW_UIPARAM_DDR_CL {7} \
   CONFIG.PCW_UIPARAM_DDR_COL_ADDR_COUNT {10} \
   CONFIG.PCW_UIPARAM_DDR_CWL {6} \
   CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY {2048 MBits} \
   CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {0.226} \
   CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {0.278} \
   CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2 {0.184} \
   CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3 {0.309} \
   CONFIG.PCW_UIPARAM_DDR_DRAM_WIDTH {8 Bits} \
   CONFIG.PCW_UIPARAM_DDR_ECC {Disabled} \
   CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {533.333313} \
   CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE {DDR 3} \
   CONFIG.PCW_UIPARAM_DDR_PARTNO {Custom} \
   CONFIG.PCW_UIPARAM_DDR_ROW_ADDR_COUNT {15} \
   CONFIG.PCW_UIPARAM_DDR_SPEED_BIN {DDR3_1066F} \
   CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {1} \
   CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {1} \
   CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1} \
   CONFIG.PCW_UIPARAM_DDR_T_FAW {30.0} \
   CONFIG.PCW_UIPARAM_DDR_T_RAS_MIN {36.0} \
   CONFIG.PCW_UIPARAM_DDR_T_RC {49.5} \
   CONFIG.PCW_UIPARAM_DDR_T_RCD {7} \
   CONFIG.PCW_UIPARAM_DDR_T_RP {7} \
   CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {1} \
   CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_USB0_PERIPHERAL_FREQMHZ {60} \
   CONFIG.PCW_USB0_RESET_ENABLE {1} \
   CONFIG.PCW_USB0_RESET_IO {MIO 7} \
   CONFIG.PCW_USB0_USB0_IO {MIO 28 .. 39} \
   CONFIG.PCW_USB1_RESET_ENABLE {0} \
   CONFIG.PCW_USB_RESET_ENABLE {1} \
   CONFIG.PCW_USB_RESET_SELECT {Share reset pin} \
   CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
   CONFIG.PCW_USE_S_AXI_HP0 {1} \
   CONFIG.PCW_USE_S_AXI_HP1 {0} \
   CONFIG.PCW_WDT_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_WDT_PERIPHERAL_FREQMHZ {133.333333} \
   CONFIG.preset {ZC706} \
 ] $ZYNQ_ARM_processing_system

  # Create instance: axi_dma_console_io, and set properties
  set axi_dma_console_io [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_console_io ]
  set_property -dict [ list \
   CONFIG.c_include_sg {0} \
   CONFIG.c_m_axis_mm2s_tdata_width {8} \
   CONFIG.c_s_axis_s2mm_tdata_width {8} \
   CONFIG.c_sg_include_stscntrl_strm {0} \
 ] $axi_dma_console_io

  # Create instance: axi_dma_receive_tran_0, and set properties
  set block_name axi_dma_receive_transfer_tap
  set block_cell_name axi_dma_receive_tran_0
  if { [catch {set axi_dma_receive_tran_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axi_dma_receive_tran_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: console_io_dma_0, and set properties
  set block_name console_io_dma
  set block_cell_name console_io_dma_0
  if { [catch {set console_io_dma_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $console_io_dma_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: sensors_blocks
  create_hier_cell_sensors_blocks [current_bd_instance .] sensors_blocks

  # Create instance: smartconnect_other_peripherals, and set properties
  set smartconnect_other_peripherals [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_other_peripherals ]
  set_property -dict [ list \
   CONFIG.NUM_SI {1} \
 ] $smartconnect_other_peripherals

  # Create instance: system_ila_0, and set properties
  set system_ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 system_ila_0 ]
  set_property -dict [ list \
   CONFIG.C_MON_TYPE {MIX} \
   CONFIG.C_NUM_MONITOR_SLOTS {7} \
   CONFIG.C_NUM_OF_PROBES {42} \
   CONFIG.C_PROBE0_TYPE {0} \
   CONFIG.C_PROBE10_TYPE {0} \
   CONFIG.C_PROBE11_TYPE {0} \
   CONFIG.C_PROBE12_TYPE {0} \
   CONFIG.C_PROBE13_TYPE {0} \
   CONFIG.C_PROBE14_TYPE {0} \
   CONFIG.C_PROBE15_TYPE {0} \
   CONFIG.C_PROBE16_TYPE {0} \
   CONFIG.C_PROBE17_TYPE {0} \
   CONFIG.C_PROBE18_TYPE {0} \
   CONFIG.C_PROBE19_TYPE {0} \
   CONFIG.C_PROBE1_TYPE {0} \
   CONFIG.C_PROBE20_TYPE {0} \
   CONFIG.C_PROBE21_TYPE {0} \
   CONFIG.C_PROBE22_TYPE {0} \
   CONFIG.C_PROBE23_TYPE {0} \
   CONFIG.C_PROBE24_TYPE {0} \
   CONFIG.C_PROBE25_TYPE {0} \
   CONFIG.C_PROBE26_TYPE {0} \
   CONFIG.C_PROBE27_TYPE {0} \
   CONFIG.C_PROBE28_TYPE {0} \
   CONFIG.C_PROBE29_TYPE {0} \
   CONFIG.C_PROBE2_TYPE {0} \
   CONFIG.C_PROBE30_TYPE {0} \
   CONFIG.C_PROBE31_TYPE {0} \
   CONFIG.C_PROBE32_TYPE {0} \
   CONFIG.C_PROBE33_TYPE {0} \
   CONFIG.C_PROBE34_TYPE {0} \
   CONFIG.C_PROBE35_TYPE {0} \
   CONFIG.C_PROBE36_TYPE {0} \
   CONFIG.C_PROBE37_TYPE {0} \
   CONFIG.C_PROBE38_TYPE {0} \
   CONFIG.C_PROBE39_TYPE {0} \
   CONFIG.C_PROBE3_TYPE {0} \
   CONFIG.C_PROBE40_TYPE {0} \
   CONFIG.C_PROBE41_TYPE {0} \
   CONFIG.C_PROBE4_TYPE {0} \
   CONFIG.C_PROBE5_TYPE {0} \
   CONFIG.C_PROBE6_TYPE {0} \
   CONFIG.C_PROBE7_TYPE {0} \
   CONFIG.C_PROBE8_TYPE {0} \
   CONFIG.C_PROBE9_TYPE {0} \
   CONFIG.C_SLOT_0_APC_EN {0} \
   CONFIG.C_SLOT_0_AXI_AR_SEL_DATA {1} \
   CONFIG.C_SLOT_0_AXI_AR_SEL_TRIG {1} \
   CONFIG.C_SLOT_0_AXI_AW_SEL_DATA {1} \
   CONFIG.C_SLOT_0_AXI_AW_SEL_TRIG {1} \
   CONFIG.C_SLOT_0_AXI_B_SEL_DATA {1} \
   CONFIG.C_SLOT_0_AXI_B_SEL_TRIG {1} \
   CONFIG.C_SLOT_0_AXI_R_SEL_DATA {1} \
   CONFIG.C_SLOT_0_AXI_R_SEL_TRIG {1} \
   CONFIG.C_SLOT_0_AXI_W_SEL_DATA {1} \
   CONFIG.C_SLOT_0_AXI_W_SEL_TRIG {1} \
   CONFIG.C_SLOT_0_INTF_TYPE {xilinx.com:interface:aximm_rtl:1.0} \
   CONFIG.C_SLOT_1_APC_EN {0} \
   CONFIG.C_SLOT_1_AXI_AR_SEL_DATA {1} \
   CONFIG.C_SLOT_1_AXI_AR_SEL_TRIG {1} \
   CONFIG.C_SLOT_1_AXI_AW_SEL_DATA {1} \
   CONFIG.C_SLOT_1_AXI_AW_SEL_TRIG {1} \
   CONFIG.C_SLOT_1_AXI_B_SEL_DATA {1} \
   CONFIG.C_SLOT_1_AXI_B_SEL_TRIG {1} \
   CONFIG.C_SLOT_1_AXI_R_SEL_DATA {1} \
   CONFIG.C_SLOT_1_AXI_R_SEL_TRIG {1} \
   CONFIG.C_SLOT_1_AXI_W_SEL_DATA {1} \
   CONFIG.C_SLOT_1_AXI_W_SEL_TRIG {1} \
   CONFIG.C_SLOT_1_INTF_TYPE {xilinx.com:interface:aximm_rtl:1.0} \
   CONFIG.C_SLOT_2_APC_EN {0} \
   CONFIG.C_SLOT_2_AXI_DATA_SEL {1} \
   CONFIG.C_SLOT_2_AXI_TRIG_SEL {1} \
   CONFIG.C_SLOT_2_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
   CONFIG.C_SLOT_3_INTF_TYPE {xilinx.com:interface:bram_rtl:1.0} \
   CONFIG.C_SLOT_3_TYPE {0} \
   CONFIG.C_SLOT_4_APC_EN {0} \
   CONFIG.C_SLOT_4_AXI_AR_SEL_DATA {1} \
   CONFIG.C_SLOT_4_AXI_AR_SEL_TRIG {1} \
   CONFIG.C_SLOT_4_AXI_AW_SEL_DATA {1} \
   CONFIG.C_SLOT_4_AXI_AW_SEL_TRIG {1} \
   CONFIG.C_SLOT_4_AXI_B_SEL_DATA {1} \
   CONFIG.C_SLOT_4_AXI_B_SEL_TRIG {1} \
   CONFIG.C_SLOT_4_AXI_R_SEL_DATA {1} \
   CONFIG.C_SLOT_4_AXI_R_SEL_TRIG {1} \
   CONFIG.C_SLOT_4_AXI_W_SEL_DATA {1} \
   CONFIG.C_SLOT_4_AXI_W_SEL_TRIG {1} \
   CONFIG.C_SLOT_4_INTF_TYPE {xilinx.com:interface:aximm_rtl:1.0} \
   CONFIG.C_SLOT_5_APC_EN {0} \
   CONFIG.C_SLOT_5_AXI_AR_SEL_DATA {1} \
   CONFIG.C_SLOT_5_AXI_AR_SEL_TRIG {1} \
   CONFIG.C_SLOT_5_AXI_AW_SEL_DATA {1} \
   CONFIG.C_SLOT_5_AXI_AW_SEL_TRIG {1} \
   CONFIG.C_SLOT_5_AXI_B_SEL_DATA {1} \
   CONFIG.C_SLOT_5_AXI_B_SEL_TRIG {1} \
   CONFIG.C_SLOT_5_AXI_R_SEL_DATA {1} \
   CONFIG.C_SLOT_5_AXI_R_SEL_TRIG {1} \
   CONFIG.C_SLOT_5_AXI_W_SEL_DATA {1} \
   CONFIG.C_SLOT_5_AXI_W_SEL_TRIG {1} \
   CONFIG.C_SLOT_5_INTF_TYPE {xilinx.com:interface:aximm_rtl:1.0} \
   CONFIG.C_SLOT_6_APC_EN {0} \
   CONFIG.C_SLOT_6_AXI_AR_SEL_DATA {1} \
   CONFIG.C_SLOT_6_AXI_AR_SEL_TRIG {1} \
   CONFIG.C_SLOT_6_AXI_AW_SEL_DATA {1} \
   CONFIG.C_SLOT_6_AXI_AW_SEL_TRIG {1} \
   CONFIG.C_SLOT_6_AXI_B_SEL_DATA {1} \
   CONFIG.C_SLOT_6_AXI_B_SEL_TRIG {1} \
   CONFIG.C_SLOT_6_AXI_R_SEL_DATA {1} \
   CONFIG.C_SLOT_6_AXI_R_SEL_TRIG {1} \
   CONFIG.C_SLOT_6_AXI_W_SEL_DATA {1} \
   CONFIG.C_SLOT_6_AXI_W_SEL_TRIG {1} \
   CONFIG.C_SLOT_6_INTF_TYPE {xilinx.com:interface:aximm_rtl:1.0} \
 ] $system_ila_0

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net CHERI_RISCV_Flute_mkSoC_Top_core_dmem_post_fabric [get_bd_intf_pins CHERI_RISCV_Flute_mkSoC_Top/core_dmem_post_fabric] [get_bd_intf_pins smartconnect_other_peripherals/S00_AXI]
connect_bd_intf_net -intf_net [get_bd_intf_nets CHERI_RISCV_Flute_mkSoC_Top_core_dmem_post_fabric] [get_bd_intf_pins smartconnect_other_peripherals/S00_AXI] [get_bd_intf_pins system_ila_0/SLOT_0_AXI]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_intf_nets CHERI_RISCV_Flute_mkSoC_Top_core_dmem_post_fabric]
connect_bd_intf_net -intf_net CHERI_RISCV_Flute_mkSoC_Top_core_dmem_pre_fabric [get_bd_intf_pins CHERI_RISCV_Flute_mkSoC_Top/core_dmem_pre_fabric] [get_bd_intf_pins system_ila_0/SLOT_1_AXI]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_intf_nets CHERI_RISCV_Flute_mkSoC_Top_core_dmem_pre_fabric]
connect_bd_intf_net -intf_net Conn [get_bd_intf_pins PYNQ_wrapper_blocks/M_AXIS] [get_bd_intf_pins system_ila_0/SLOT_2_AXIS]
connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins sensors_blocks/BRAM_PORTA] [get_bd_intf_pins system_ila_0/SLOT_3_BRAM]
  connect_bd_intf_net -intf_net PYNQ_wrapper_blocks_M03_AXI [get_bd_intf_pins PYNQ_wrapper_blocks/M03_AXI] [get_bd_intf_pins axi_dma_console_io/S_AXI_LITE]
connect_bd_intf_net -intf_net [get_bd_intf_nets PYNQ_wrapper_blocks_M03_AXI] [get_bd_intf_pins PYNQ_wrapper_blocks/M03_AXI] [get_bd_intf_pins system_ila_0/SLOT_5_AXI]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_intf_nets PYNQ_wrapper_blocks_M03_AXI]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_MM2S [get_bd_intf_pins PYNQ_wrapper_blocks/S02_AXI] [get_bd_intf_pins axi_dma_console_io/M_AXI_MM2S]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_S2MM [get_bd_intf_pins PYNQ_wrapper_blocks/S01_AXI] [get_bd_intf_pins axi_dma_console_io/M_AXI_S2MM]
connect_bd_intf_net -intf_net [get_bd_intf_nets axi_dma_0_M_AXI_S2MM] [get_bd_intf_pins axi_dma_console_io/M_AXI_S2MM] [get_bd_intf_pins system_ila_0/SLOT_6_AXI]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_intf_nets axi_dma_0_M_AXI_S2MM]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins ZYNQ_ARM_processing_system/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins ZYNQ_ARM_processing_system/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins PYNQ_wrapper_blocks/S00_AXI] [get_bd_intf_pins ZYNQ_ARM_processing_system/M_AXI_GP0]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins sensors_blocks/S_AXI] [get_bd_intf_pins smartconnect_other_peripherals/M00_AXI]
connect_bd_intf_net -intf_net [get_bd_intf_nets smartconnect_0_M00_AXI] [get_bd_intf_pins smartconnect_other_peripherals/M00_AXI] [get_bd_intf_pins system_ila_0/SLOT_4_AXI]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_intf_nets smartconnect_0_M00_AXI]
  connect_bd_intf_net -intf_net smartconnect_1_M00_AXI [get_bd_intf_pins PYNQ_wrapper_blocks/M00_AXI] [get_bd_intf_pins ZYNQ_ARM_processing_system/S_AXI_HP0]

  # Create port connections
  connect_bd_net -net CHERI_RISCV_Flute_mkSoC_Top_cms_ifc_registers [get_bd_pins CHERI_RISCV_Flute_mkSoC_Top/cms_ifc_registers] [get_bd_pins PYNQ_wrapper_blocks/general_purpose_registers]
  connect_bd_net -net CHERI_RISCV_Flute_mkSoC_Top_cpu_reset_completed [get_bd_pins CHERI_RISCV_Flute_mkSoC_Top/cpu_reset_completed] [get_bd_pins PYNQ_wrapper_blocks/cpu_reset_completed] [get_bd_pins console_io_dma_0/cpu_reset_completed] [get_bd_pins system_ila_0/probe10]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets CHERI_RISCV_Flute_mkSoC_Top_cpu_reset_completed]
  connect_bd_net -net Din_1 [get_bd_pins CHERI_RISCV_Flute_mkSoC_Top/to_raw_mem_request_get] [get_bd_pins PYNQ_wrapper_blocks/to_raw_mem_request_get]
  connect_bd_net -net PYNQ_wrapper_blocks_AXI_GPIO_output [get_bd_pins PYNQ_wrapper_blocks/AXI_GPIO_output] [get_bd_pins system_ila_0/probe14]
  connect_bd_net -net PYNQ_wrapper_blocks_halt_cpu [get_bd_pins CHERI_RISCV_Flute_mkSoC_Top/cms_ifc_halt_cpu_state] [get_bd_pins PYNQ_wrapper_blocks/halt_cpu]
  connect_bd_net -net PYNQ_wrapper_blocks_input_fifo_counter1 [get_bd_pins PYNQ_wrapper_blocks/input_fifo_counter1] [get_bd_pins system_ila_0/probe12]
  connect_bd_net -net PYNQ_wrapper_blocks_item_counter_probe [get_bd_pins PYNQ_wrapper_blocks/item_counter_probe] [get_bd_pins system_ila_0/probe11]
  connect_bd_net -net PYNQ_wrapper_blocks_output_fifo_counter1 [get_bd_pins PYNQ_wrapper_blocks/output_fifo_counter1] [get_bd_pins system_ila_0/probe13]
  connect_bd_net -net RDY_get_to_console_get [get_bd_pins CHERI_RISCV_Flute_mkSoC_Top/EN_get_to_console_get] [get_bd_pins CHERI_RISCV_Flute_mkSoC_Top/RDY_get_to_console_get] [get_bd_pins PYNQ_wrapper_blocks/console_out_we] [get_bd_pins console_io_dma_0/RDY_get_to_console_get] [get_bd_pins system_ila_0/probe7]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets RDY_get_to_console_get]
  connect_bd_net -net XADC_VAUX0N_R_1 [get_bd_ports XADC_VAUX0N_R] [get_bd_pins sensors_blocks/XADC_VAUX0N_R]
  connect_bd_net -net XADC_VAUX0P_R_1 [get_bd_ports XADC_VAUX0P_R] [get_bd_pins sensors_blocks/XADC_VAUX0P_R]
  connect_bd_net -net axi_dma_console_io_m_axis_mm2s_tdata [get_bd_pins axi_dma_console_io/m_axis_mm2s_tdata] [get_bd_pins console_io_dma_0/input_data] [get_bd_pins system_ila_0/probe24]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets axi_dma_console_io_m_axis_mm2s_tdata]
  connect_bd_net -net axi_dma_console_io_m_axis_mm2s_tvalid [get_bd_pins axi_dma_console_io/m_axis_mm2s_tvalid] [get_bd_pins console_io_dma_0/input_write_en] [get_bd_pins system_ila_0/probe25]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets axi_dma_console_io_m_axis_mm2s_tvalid]
  connect_bd_net -net axi_dma_console_io_mm2s_introut [get_bd_pins axi_dma_console_io/mm2s_introut] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net axi_dma_console_io_s2mm_introut [get_bd_pins axi_dma_console_io/s2mm_introut] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net axi_dma_console_io_s_axis_s2mm_tready [get_bd_pins axi_dma_console_io/s_axis_s2mm_tready] [get_bd_pins console_io_dma_0/output_tready] [get_bd_pins system_ila_0/probe26]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets axi_dma_console_io_s_axis_s2mm_tready]
  connect_bd_net -net axilite_tap_awaddr_net [get_bd_pins PYNQ_wrapper_blocks/M03_AXI_awaddr1] [get_bd_pins axi_dma_console_io/s_axi_lite_awaddr] [get_bd_pins axi_dma_receive_tran_0/axilite_tap_awaddr] [get_bd_pins system_ila_0/probe37]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets axilite_tap_awaddr_net]
  connect_bd_net -net axilite_tap_wdata_net [get_bd_pins PYNQ_wrapper_blocks/M03_AXI_wdata1] [get_bd_pins axi_dma_console_io/s_axi_lite_wdata] [get_bd_pins axi_dma_receive_tran_0/axilite_tap_wdata] [get_bd_pins system_ila_0/probe38]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets axilite_tap_wdata_net]
  connect_bd_net -net axilite_tap_wready_net [get_bd_pins PYNQ_wrapper_blocks/M03_AXI_wready1] [get_bd_pins axi_dma_console_io/s_axi_lite_wready] [get_bd_pins axi_dma_receive_tran_0/axilite_tap_wready] [get_bd_pins system_ila_0/probe39]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets axilite_tap_wready_net]
  connect_bd_net -net axilite_tap_wvalid_net [get_bd_pins PYNQ_wrapper_blocks/M03_AXI_wvalid1] [get_bd_pins axi_dma_console_io/s_axi_lite_wvalid] [get_bd_pins axi_dma_receive_tran_0/axilite_tap_wvalid] [get_bd_pins system_ila_0/probe40]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets axilite_tap_wvalid_net]
  connect_bd_net -net blk_mem_gen_0_douta [get_bd_pins CHERI_RISCV_Flute_mkSoC_Top/to_raw_mem_response_put] [get_bd_pins PYNQ_wrapper_blocks/memory_data] [get_bd_pins system_ila_0/probe0]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets blk_mem_gen_0_douta]
  connect_bd_net -net console_io_dma_0_EN_put_from_console_put [get_bd_pins CHERI_RISCV_Flute_mkSoC_Top/EN_put_from_console_put] [get_bd_pins console_io_dma_0/EN_put_from_console_put] [get_bd_pins system_ila_0/probe30]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets console_io_dma_0_EN_put_from_console_put]
  connect_bd_net -net console_io_dma_0_input_not_full [get_bd_pins axi_dma_console_io/m_axis_mm2s_tready] [get_bd_pins console_io_dma_0/input_not_full] [get_bd_pins system_ila_0/probe31]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets console_io_dma_0_input_not_full]
  connect_bd_net -net console_io_dma_0_output_available [get_bd_pins console_io_dma_0/output_available] [get_bd_pins system_ila_0/probe32]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets console_io_dma_0_output_available]
  connect_bd_net -net console_io_dma_0_output_available_delayed [get_bd_pins axi_dma_console_io/s_axis_s2mm_tvalid] [get_bd_pins console_io_dma_0/output_available_delayed] [get_bd_pins system_ila_0/probe41]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets console_io_dma_0_output_available_delayed]
  connect_bd_net -net console_io_dma_0_output_data [get_bd_pins axi_dma_console_io/s_axis_s2mm_tdata] [get_bd_pins console_io_dma_0/output_data_reg] [get_bd_pins system_ila_0/probe33]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets console_io_dma_0_output_data]
  connect_bd_net -net console_io_dma_0_output_tlast_reg [get_bd_pins axi_dma_console_io/s_axis_s2mm_tlast] [get_bd_pins console_io_dma_0/output_tlast_reg] [get_bd_pins system_ila_0/probe35]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets console_io_dma_0_output_tlast_reg]
  connect_bd_net -net console_io_dma_0_put_from_console_put [get_bd_pins CHERI_RISCV_Flute_mkSoC_Top/put_from_console_put] [get_bd_pins console_io_dma_0/put_from_console_put] [get_bd_pins system_ila_0/probe34]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets console_io_dma_0_put_from_console_put]
  connect_bd_net -net delayer_0_delayed_sig [get_bd_pins CHERI_RISCV_Flute_mkSoC_Top/EN_to_raw_mem_response_put] [get_bd_pins PYNQ_wrapper_blocks/memory_we] [get_bd_pins system_ila_0/probe1]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets delayer_0_delayed_sig]
  connect_bd_net -net doutb [get_bd_pins sensors_blocks/doutb] [get_bd_pins system_ila_0/probe15]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets doutb]
  connect_bd_net -net get_to_console_get [get_bd_pins CHERI_RISCV_Flute_mkSoC_Top/get_to_console_get] [get_bd_pins PYNQ_wrapper_blocks/console_out_data] [get_bd_pins console_io_dma_0/get_to_console_get] [get_bd_pins system_ila_0/probe2]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets get_to_console_get]
  connect_bd_net -net gpio_0_Dout [get_bd_pins CHERI_RISCV_Flute_mkSoC_Top/EN_cms_ifc_halt_cpu] [get_bd_pins CHERI_RISCV_Flute_mkSoC_Top/RST_N] [get_bd_pins PYNQ_wrapper_blocks/rst_n] [get_bd_pins sensors_blocks/s_axi_aresetn] [get_bd_pins smartconnect_other_peripherals/aresetn]
  connect_bd_net -net input_fifo_counter [get_bd_pins console_io_dma_0/input_fifo_counter] [get_bd_pins system_ila_0/probe27]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets input_fifo_counter]
  connect_bd_net -net mkCore_Synth_0_instr [get_bd_pins CHERI_RISCV_Flute_mkSoC_Top/cms_ifc_instr] [get_bd_pins PYNQ_wrapper_blocks/instr] [get_bd_pins system_ila_0/probe3]
  connect_bd_net -net mkCore_Synth_0_pc [get_bd_pins CHERI_RISCV_Flute_mkSoC_Top/cms_ifc_pc] [get_bd_pins PYNQ_wrapper_blocks/pc] [get_bd_pins system_ila_0/probe4]
  connect_bd_net -net mkSoC_Top_0_RDY_put_from_console_put [get_bd_pins CHERI_RISCV_Flute_mkSoC_Top/RDY_put_from_console_put] [get_bd_pins PYNQ_wrapper_blocks/RDY_put_from_console_put] [get_bd_pins console_io_dma_0/RDY_put_from_console_put] [get_bd_pins system_ila_0/probe5]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets mkSoC_Top_0_RDY_put_from_console_put]
  connect_bd_net -net mkSoC_Top_0_RDY_to_raw_mem_request_get [get_bd_pins CHERI_RISCV_Flute_mkSoC_Top/EN_to_raw_mem_request_get] [get_bd_pins CHERI_RISCV_Flute_mkSoC_Top/RDY_to_raw_mem_request_get] [get_bd_pins PYNQ_wrapper_blocks/RDY_to_raw_mem_request_get] [get_bd_pins system_ila_0/probe6]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets mkSoC_Top_0_RDY_to_raw_mem_request_get]
  connect_bd_net -net mkSoC_Top_1_cms_ifc_performance_events [get_bd_pins CHERI_RISCV_Flute_mkSoC_Top/cms_ifc_performance_events] [get_bd_pins PYNQ_wrapper_blocks/performance_events]
  connect_bd_net -net muxaddr_out [get_bd_pins sensors_blocks/muxaddr_out] [get_bd_pins system_ila_0/probe16]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets muxaddr_out]
  connect_bd_net -net output_fifo_counter [get_bd_pins console_io_dma_0/output_fifo_counter] [get_bd_pins system_ila_0/probe28]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets output_fifo_counter]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins PYNQ_wrapper_blocks/aresetn] [get_bd_pins axi_dma_console_io/axi_resetn] [get_bd_pins console_io_dma_0/rst_n] [get_bd_pins console_io_dma_0/rst_n_input_fifo] [get_bd_pins console_io_dma_0/rst_n_output_fifo] [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins system_ila_0/probe29] [get_bd_pins system_ila_0/resetn]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets proc_sys_reset_0_peripheral_aresetn]
  connect_bd_net -net proc_sys_reset_0_peripheral_reset [get_bd_pins proc_sys_reset_0/peripheral_reset] [get_bd_pins sensors_blocks/reset_in]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins ZYNQ_ARM_processing_system/FCLK_RESET0_N] [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net receive_transfer_request [get_bd_pins axi_dma_receive_tran_0/receive_transfer_request] [get_bd_pins console_io_dma_0/receive_transfer_request] [get_bd_pins system_ila_0/probe36]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets receive_transfer_request]
  connect_bd_net -net sensors_blocks_S [get_bd_pins sensors_blocks/S] [get_bd_pins system_ila_0/probe17]
  connect_bd_net -net sensors_blocks_XADC_GPIO_0 [get_bd_ports PMOD1_0_LS] [get_bd_ports XADC_GPIO_0] [get_bd_pins sensors_blocks/XADC_GPIO_0]
  connect_bd_net -net sensors_blocks_XADC_GPIO_1 [get_bd_ports PMOD1_1_LS] [get_bd_ports XADC_GPIO_1] [get_bd_pins sensors_blocks/XADC_GPIO_1]
  connect_bd_net -net sensors_blocks_XADC_GPIO_2 [get_bd_ports PMOD1_4_LS] [get_bd_ports XADC_GPIO_2] [get_bd_pins sensors_blocks/XADC_GPIO_2]
  connect_bd_net -net sensors_blocks_XADC_GPIO_3 [get_bd_ports PMOD1_5_LS] [get_bd_ports XADC_GPIO_3] [get_bd_pins sensors_blocks/XADC_GPIO_3]
  connect_bd_net -net sensors_blocks_addr_out [get_bd_pins sensors_blocks/addr_out] [get_bd_pins system_ila_0/probe22]
  connect_bd_net -net sensors_blocks_bram_addr_a [get_bd_pins sensors_blocks/bram_addr_a] [get_bd_pins system_ila_0/probe23]
  connect_bd_net -net sensors_blocks_channel_out1 [get_bd_pins sensors_blocks/channel_out1] [get_bd_pins system_ila_0/probe18]
  connect_bd_net -net sensors_blocks_do_out1 [get_bd_pins sensors_blocks/do_out1] [get_bd_pins system_ila_0/probe19]
  connect_bd_net -net sensors_blocks_drdy_out1 [get_bd_pins sensors_blocks/drdy_out1] [get_bd_pins system_ila_0/probe20]
  connect_bd_net -net sensors_blocks_eoc_out [get_bd_pins sensors_blocks/eoc_out] [get_bd_pins system_ila_0/probe21]
  connect_bd_net -net sync_fifo_0_rd_data [get_bd_pins PYNQ_wrapper_blocks/console_input_data] [get_bd_pins system_ila_0/probe8]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets sync_fifo_0_rd_data]
  connect_bd_net -net util_vector_logic_1_Res [get_bd_pins PYNQ_wrapper_blocks/console_input_en] [get_bd_pins system_ila_0/probe9]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets util_vector_logic_1_Res]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins ZYNQ_ARM_processing_system/IRQ_F2P] [get_bd_pins xlconcat_0/dout]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins CHERI_RISCV_Flute_mkSoC_Top/EN_ma_ddr4_ready] [get_bd_pins xlconstant_0/dout]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins CHERI_RISCV_Flute_mkSoC_Top/CLK] [get_bd_pins PYNQ_wrapper_blocks/clk] [get_bd_pins ZYNQ_ARM_processing_system/FCLK_CLK0] [get_bd_pins ZYNQ_ARM_processing_system/M_AXI_GP0_ACLK] [get_bd_pins ZYNQ_ARM_processing_system/S_AXI_HP0_ACLK] [get_bd_pins axi_dma_console_io/m_axi_mm2s_aclk] [get_bd_pins axi_dma_console_io/m_axi_s2mm_aclk] [get_bd_pins axi_dma_console_io/s_axi_lite_aclk] [get_bd_pins axi_dma_receive_tran_0/clk] [get_bd_pins console_io_dma_0/clk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins sensors_blocks/clkb] [get_bd_pins smartconnect_other_peripherals/aclk] [get_bd_pins system_ila_0/clk]

  # Create address segments
  assign_bd_address -offset 0xC0003000 -range 0x00001000 -target_address_space [get_bd_addr_spaces CHERI_RISCV_Flute_mkSoC_Top/core_dmem_post_fabric] [get_bd_addr_segs sensors_blocks/axi_bram_ctrl_sensors/S_AXI/Mem0] -force
  assign_bd_address -offset 0x40400000 -range 0x00010000 -target_address_space [get_bd_addr_spaces ZYNQ_ARM_processing_system/Data] [get_bd_addr_segs PYNQ_wrapper_blocks/continuous_monitoring_system_blocks/axi_dma_0/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x40410000 -range 0x00010000 -target_address_space [get_bd_addr_spaces ZYNQ_ARM_processing_system/Data] [get_bd_addr_segs axi_dma_console_io/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x41200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces ZYNQ_ARM_processing_system/Data] [get_bd_addr_segs PYNQ_wrapper_blocks/axi_gpio_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x41220000 -range 0x00010000 -target_address_space [get_bd_addr_spaces ZYNQ_ARM_processing_system/Data] [get_bd_addr_segs PYNQ_wrapper_blocks/bram_loader/axi_gpio_2/S_AXI/Reg] -force
  assign_bd_address -offset 0x41230000 -range 0x00010000 -target_address_space [get_bd_addr_spaces ZYNQ_ARM_processing_system/Data] [get_bd_addr_segs PYNQ_wrapper_blocks/axi_gpio_3/S_AXI/Reg] -force
  assign_bd_address -offset 0x41240000 -range 0x00010000 -target_address_space [get_bd_addr_spaces ZYNQ_ARM_processing_system/Data] [get_bd_addr_segs PYNQ_wrapper_blocks/continuous_monitoring_system_blocks/axi_gpio_to_cms_ctrl_interface/axi_gpio_cms_ctrl/S_AXI/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces axi_dma_console_io/Data_MM2S] [get_bd_addr_segs ZYNQ_ARM_processing_system/S_AXI_HP0/HP0_DDR_LOWOCM] -force
  assign_bd_address -offset 0x00000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces axi_dma_console_io/Data_S2MM] [get_bd_addr_segs ZYNQ_ARM_processing_system/S_AXI_HP0/HP0_DDR_LOWOCM] -force
  assign_bd_address -offset 0x00000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces PYNQ_wrapper_blocks/continuous_monitoring_system_blocks/axi_dma_0/Data_S2MM] [get_bd_addr_segs ZYNQ_ARM_processing_system/S_AXI_HP0/HP0_DDR_LOWOCM] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


