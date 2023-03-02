//
// Generated by Bluespec Compiler, version untagged-gb2fda995 (build b2fda995)
//
//
// Ports:
// Name                         I/O  size props
// CLK                            I     1 clock
// RST_N                          I     1 reset
//
// No combinational paths from inputs to outputs
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module mkTop_HW_Side(CLK,
		     RST_N);
  input  CLK;
  input  RST_N;

  // register rg_banner_printed
  reg rg_banner_printed;
  wire rg_banner_printed$D_IN, rg_banner_printed$EN;

  // register rg_console_in_poll
  reg [11 : 0] rg_console_in_poll;
  wire [11 : 0] rg_console_in_poll$D_IN;
  wire rg_console_in_poll$EN;

  // ports of submodule mem_model
  wire [352 : 0] mem_model$mem_server_request_put;
  wire [255 : 0] mem_model$mem_server_response_get;
  wire mem_model$EN_mem_server_request_put,
       mem_model$EN_mem_server_response_get,
       mem_model$RDY_mem_server_request_put,
       mem_model$RDY_mem_server_response_get;

  // ports of submodule soc_top
  wire [352 : 0] soc_top$to_raw_mem_request_get;
  wire [255 : 0] soc_top$to_raw_mem_response_put;
  wire [63 : 0] soc_top$core_dmem_post_fabric_rdata,
		soc_top$core_dmem_pre_fabric_rdata,
		soc_top$mv_tohost_value,
		soc_top$set_verbosity_logdelay,
		soc_top$set_watch_tohost_tohost_addr;
  wire [7 : 0] soc_top$get_to_console_get,
	       soc_top$mv_status,
	       soc_top$put_from_console_put;
  wire [6 : 0] soc_top$core_dmem_post_fabric_bid,
	       soc_top$core_dmem_post_fabric_rid;
  wire [5 : 0] soc_top$core_dmem_pre_fabric_bid,
	       soc_top$core_dmem_pre_fabric_rid;
  wire [3 : 0] soc_top$set_verbosity_verbosity;
  wire [1 : 0] soc_top$core_dmem_post_fabric_bresp,
	       soc_top$core_dmem_post_fabric_rresp,
	       soc_top$core_dmem_pre_fabric_bresp,
	       soc_top$core_dmem_pre_fabric_rresp;
  wire soc_top$EN_cms_ifc_halt_cpu,
       soc_top$EN_get_to_console_get,
       soc_top$EN_ma_ddr4_ready,
       soc_top$EN_put_from_console_put,
       soc_top$EN_set_verbosity,
       soc_top$EN_set_watch_tohost,
       soc_top$EN_to_raw_mem_request_get,
       soc_top$EN_to_raw_mem_response_put,
       soc_top$RDY_get_to_console_get,
       soc_top$RDY_put_from_console_put,
       soc_top$RDY_to_raw_mem_request_get,
       soc_top$RDY_to_raw_mem_response_put,
       soc_top$cms_ifc_halt_cpu_state,
       soc_top$core_dmem_post_fabric_arready,
       soc_top$core_dmem_post_fabric_awready,
       soc_top$core_dmem_post_fabric_bvalid,
       soc_top$core_dmem_post_fabric_rlast,
       soc_top$core_dmem_post_fabric_rvalid,
       soc_top$core_dmem_post_fabric_wready,
       soc_top$core_dmem_pre_fabric_arready,
       soc_top$core_dmem_pre_fabric_awready,
       soc_top$core_dmem_pre_fabric_bvalid,
       soc_top$core_dmem_pre_fabric_rlast,
       soc_top$core_dmem_pre_fabric_rvalid,
       soc_top$core_dmem_pre_fabric_wready,
       soc_top$set_watch_tohost_watch_tohost;

  // rule scheduling signals
  wire CAN_FIRE_RL_connect,
       CAN_FIRE_RL_connect_1,
       CAN_FIRE_RL_connect_2,
       CAN_FIRE_RL_connect_3,
       CAN_FIRE_RL_connect_4,
       CAN_FIRE_RL_connect_5,
       CAN_FIRE_RL_connect_6,
       CAN_FIRE_RL_connect_7,
       CAN_FIRE_RL_connect_8,
       CAN_FIRE_RL_connect_9,
       CAN_FIRE_RL_memCnx_ClientServerRequest,
       CAN_FIRE_RL_memCnx_ClientServerResponse,
       CAN_FIRE_RL_rl_relay_console_in,
       CAN_FIRE_RL_rl_relay_console_out,
       CAN_FIRE_RL_rl_step0,
       CAN_FIRE_RL_rl_terminate,
       CAN_FIRE_RL_rl_terminate_tohost,
       WILL_FIRE_RL_connect,
       WILL_FIRE_RL_connect_1,
       WILL_FIRE_RL_connect_2,
       WILL_FIRE_RL_connect_3,
       WILL_FIRE_RL_connect_4,
       WILL_FIRE_RL_connect_5,
       WILL_FIRE_RL_connect_6,
       WILL_FIRE_RL_connect_7,
       WILL_FIRE_RL_connect_8,
       WILL_FIRE_RL_connect_9,
       WILL_FIRE_RL_memCnx_ClientServerRequest,
       WILL_FIRE_RL_memCnx_ClientServerResponse,
       WILL_FIRE_RL_rl_relay_console_in,
       WILL_FIRE_RL_rl_relay_console_out,
       WILL_FIRE_RL_rl_step0,
       WILL_FIRE_RL_rl_terminate,
       WILL_FIRE_RL_rl_terminate_tohost;

  // declarations used by system tasks
  // synopsys translate_off
  reg [31 : 0] v__h2450;
  reg [31 : 0] v__h2500;
  reg [31 : 0] v__h2616;
  reg [31 : 0] v__h2763;
  reg Task_$test$plusargs__avValue1;
  reg Task_$test$plusargs__avValue2;
  reg TASK_testplusargs___d11;
  reg [63 : 0] tohost_addr__h2316;
  reg [31 : 0] v__h2381;
  reg [7 : 0] v__h2957;
  reg [31 : 0] v__h2444;
  reg [31 : 0] v__h2375;
  reg [31 : 0] v__h2494;
  reg [31 : 0] v__h2757;
  reg [31 : 0] v__h2610;
  // synopsys translate_on

  // remaining internal signals
  wire [63 : 0] test_num__h2659;

  // submodule mem_model
  mkMem_Model mem_model(.CLK(CLK),
			.RST_N(RST_N),
			.mem_server_request_put(mem_model$mem_server_request_put),
			.EN_mem_server_request_put(mem_model$EN_mem_server_request_put),
			.EN_mem_server_response_get(mem_model$EN_mem_server_response_get),
			.RDY_mem_server_request_put(mem_model$RDY_mem_server_request_put),
			.mem_server_response_get(mem_model$mem_server_response_get),
			.RDY_mem_server_response_get(mem_model$RDY_mem_server_response_get));

  // submodule soc_top
  mkSoC_Top soc_top(.CLK(CLK),
		    .RST_N(RST_N),
		    .cms_ifc_halt_cpu_state(soc_top$cms_ifc_halt_cpu_state),
		    .core_dmem_post_fabric_arready(soc_top$core_dmem_post_fabric_arready),
		    .core_dmem_post_fabric_awready(soc_top$core_dmem_post_fabric_awready),
		    .core_dmem_post_fabric_bid(soc_top$core_dmem_post_fabric_bid),
		    .core_dmem_post_fabric_bresp(soc_top$core_dmem_post_fabric_bresp),
		    .core_dmem_post_fabric_bvalid(soc_top$core_dmem_post_fabric_bvalid),
		    .core_dmem_post_fabric_rdata(soc_top$core_dmem_post_fabric_rdata),
		    .core_dmem_post_fabric_rid(soc_top$core_dmem_post_fabric_rid),
		    .core_dmem_post_fabric_rlast(soc_top$core_dmem_post_fabric_rlast),
		    .core_dmem_post_fabric_rresp(soc_top$core_dmem_post_fabric_rresp),
		    .core_dmem_post_fabric_rvalid(soc_top$core_dmem_post_fabric_rvalid),
		    .core_dmem_post_fabric_wready(soc_top$core_dmem_post_fabric_wready),
		    .core_dmem_pre_fabric_arready(soc_top$core_dmem_pre_fabric_arready),
		    .core_dmem_pre_fabric_awready(soc_top$core_dmem_pre_fabric_awready),
		    .core_dmem_pre_fabric_bid(soc_top$core_dmem_pre_fabric_bid),
		    .core_dmem_pre_fabric_bresp(soc_top$core_dmem_pre_fabric_bresp),
		    .core_dmem_pre_fabric_bvalid(soc_top$core_dmem_pre_fabric_bvalid),
		    .core_dmem_pre_fabric_rdata(soc_top$core_dmem_pre_fabric_rdata),
		    .core_dmem_pre_fabric_rid(soc_top$core_dmem_pre_fabric_rid),
		    .core_dmem_pre_fabric_rlast(soc_top$core_dmem_pre_fabric_rlast),
		    .core_dmem_pre_fabric_rresp(soc_top$core_dmem_pre_fabric_rresp),
		    .core_dmem_pre_fabric_rvalid(soc_top$core_dmem_pre_fabric_rvalid),
		    .core_dmem_pre_fabric_wready(soc_top$core_dmem_pre_fabric_wready),
		    .put_from_console_put(soc_top$put_from_console_put),
		    .set_verbosity_logdelay(soc_top$set_verbosity_logdelay),
		    .set_verbosity_verbosity(soc_top$set_verbosity_verbosity),
		    .set_watch_tohost_tohost_addr(soc_top$set_watch_tohost_tohost_addr),
		    .set_watch_tohost_watch_tohost(soc_top$set_watch_tohost_watch_tohost),
		    .to_raw_mem_response_put(soc_top$to_raw_mem_response_put),
		    .EN_to_raw_mem_request_get(soc_top$EN_to_raw_mem_request_get),
		    .EN_to_raw_mem_response_put(soc_top$EN_to_raw_mem_response_put),
		    .EN_get_to_console_get(soc_top$EN_get_to_console_get),
		    .EN_put_from_console_put(soc_top$EN_put_from_console_put),
		    .EN_set_verbosity(soc_top$EN_set_verbosity),
		    .EN_set_watch_tohost(soc_top$EN_set_watch_tohost),
		    .EN_ma_ddr4_ready(soc_top$EN_ma_ddr4_ready),
		    .EN_cms_ifc_halt_cpu(soc_top$EN_cms_ifc_halt_cpu),
		    .to_raw_mem_request_get(soc_top$to_raw_mem_request_get),
		    .RDY_to_raw_mem_request_get(soc_top$RDY_to_raw_mem_request_get),
		    .RDY_to_raw_mem_response_put(soc_top$RDY_to_raw_mem_response_put),
		    .get_to_console_get(soc_top$get_to_console_get),
		    .RDY_get_to_console_get(soc_top$RDY_get_to_console_get),
		    .RDY_put_from_console_put(soc_top$RDY_put_from_console_put),
		    .status(),
		    .RDY_set_verbosity(),
		    .RDY_set_watch_tohost(),
		    .mv_tohost_value(soc_top$mv_tohost_value),
		    .RDY_mv_tohost_value(),
		    .RDY_ma_ddr4_ready(),
		    .mv_status(soc_top$mv_status),
		    .cms_ifc_pc(),
		    .cms_ifc_instr(),
		    .cms_ifc_performance_events(),
		    .cms_ifc_gp_write_reg_name(),
		    .cms_ifc_gp_write_reg(),
		    .cms_ifc_gp_write_valid(),
		    .core_dmem_pre_fabric_awid(),
		    .core_dmem_pre_fabric_awaddr(),
		    .core_dmem_pre_fabric_awlen(),
		    .core_dmem_pre_fabric_awsize(),
		    .core_dmem_pre_fabric_awburst(),
		    .core_dmem_pre_fabric_awlock(),
		    .core_dmem_pre_fabric_awcache(),
		    .core_dmem_pre_fabric_awprot(),
		    .core_dmem_pre_fabric_awqos(),
		    .core_dmem_pre_fabric_awregion(),
		    .core_dmem_pre_fabric_awvalid(),
		    .core_dmem_pre_fabric_wdata(),
		    .core_dmem_pre_fabric_wstrb(),
		    .core_dmem_pre_fabric_wlast(),
		    .core_dmem_pre_fabric_wvalid(),
		    .core_dmem_pre_fabric_bready(),
		    .core_dmem_pre_fabric_arid(),
		    .core_dmem_pre_fabric_araddr(),
		    .core_dmem_pre_fabric_arlen(),
		    .core_dmem_pre_fabric_arsize(),
		    .core_dmem_pre_fabric_arburst(),
		    .core_dmem_pre_fabric_arlock(),
		    .core_dmem_pre_fabric_arcache(),
		    .core_dmem_pre_fabric_arprot(),
		    .core_dmem_pre_fabric_arqos(),
		    .core_dmem_pre_fabric_arregion(),
		    .core_dmem_pre_fabric_arvalid(),
		    .core_dmem_pre_fabric_rready(),
		    .core_dmem_post_fabric_awid(),
		    .core_dmem_post_fabric_awaddr(),
		    .core_dmem_post_fabric_awlen(),
		    .core_dmem_post_fabric_awsize(),
		    .core_dmem_post_fabric_awburst(),
		    .core_dmem_post_fabric_awlock(),
		    .core_dmem_post_fabric_awcache(),
		    .core_dmem_post_fabric_awprot(),
		    .core_dmem_post_fabric_awqos(),
		    .core_dmem_post_fabric_awregion(),
		    .core_dmem_post_fabric_awvalid(),
		    .core_dmem_post_fabric_wdata(),
		    .core_dmem_post_fabric_wstrb(),
		    .core_dmem_post_fabric_wlast(),
		    .core_dmem_post_fabric_wvalid(),
		    .core_dmem_post_fabric_bready(),
		    .core_dmem_post_fabric_arid(),
		    .core_dmem_post_fabric_araddr(),
		    .core_dmem_post_fabric_arlen(),
		    .core_dmem_post_fabric_arsize(),
		    .core_dmem_post_fabric_arburst(),
		    .core_dmem_post_fabric_arlock(),
		    .core_dmem_post_fabric_arcache(),
		    .core_dmem_post_fabric_arprot(),
		    .core_dmem_post_fabric_arqos(),
		    .core_dmem_post_fabric_arregion(),
		    .core_dmem_post_fabric_arvalid(),
		    .core_dmem_post_fabric_rready(),
		    .cpu_reset_completed());

  // rule RL_connect
  assign CAN_FIRE_RL_connect = 1'd1 ;
  assign WILL_FIRE_RL_connect = 1'd1 ;

  // rule RL_connect_1
  assign CAN_FIRE_RL_connect_1 = 1'd1 ;
  assign WILL_FIRE_RL_connect_1 = 1'd1 ;

  // rule RL_connect_2
  assign CAN_FIRE_RL_connect_2 = 1'd1 ;
  assign WILL_FIRE_RL_connect_2 = 1'd1 ;

  // rule RL_connect_3
  assign CAN_FIRE_RL_connect_3 = 1'd1 ;
  assign WILL_FIRE_RL_connect_3 = 1'd1 ;

  // rule RL_connect_4
  assign CAN_FIRE_RL_connect_4 = 1'd1 ;
  assign WILL_FIRE_RL_connect_4 = 1'd1 ;

  // rule RL_connect_5
  assign CAN_FIRE_RL_connect_5 = 1'd1 ;
  assign WILL_FIRE_RL_connect_5 = 1'd1 ;

  // rule RL_connect_6
  assign CAN_FIRE_RL_connect_6 = 1'd1 ;
  assign WILL_FIRE_RL_connect_6 = 1'd1 ;

  // rule RL_connect_7
  assign CAN_FIRE_RL_connect_7 = 1'd1 ;
  assign WILL_FIRE_RL_connect_7 = 1'd1 ;

  // rule RL_connect_8
  assign CAN_FIRE_RL_connect_8 = 1'd1 ;
  assign WILL_FIRE_RL_connect_8 = 1'd1 ;

  // rule RL_connect_9
  assign CAN_FIRE_RL_connect_9 = 1'd1 ;
  assign WILL_FIRE_RL_connect_9 = 1'd1 ;

  // rule RL_rl_terminate
  assign CAN_FIRE_RL_rl_terminate = soc_top$mv_status != 8'd0 ;
  assign WILL_FIRE_RL_rl_terminate = CAN_FIRE_RL_rl_terminate ;

  // rule RL_rl_terminate_tohost
  assign CAN_FIRE_RL_rl_terminate_tohost = soc_top$mv_tohost_value != 64'd0 ;
  assign WILL_FIRE_RL_rl_terminate_tohost = CAN_FIRE_RL_rl_terminate_tohost ;

  // rule RL_rl_step0
  assign CAN_FIRE_RL_rl_step0 = !rg_banner_printed ;
  assign WILL_FIRE_RL_rl_step0 = CAN_FIRE_RL_rl_step0 ;

  // rule RL_rl_relay_console_out
  assign CAN_FIRE_RL_rl_relay_console_out = soc_top$RDY_get_to_console_get ;
  assign WILL_FIRE_RL_rl_relay_console_out = soc_top$RDY_get_to_console_get ;

  // rule RL_rl_relay_console_in
  assign CAN_FIRE_RL_rl_relay_console_in =
	     rg_console_in_poll != 12'd0 || soc_top$RDY_put_from_console_put ;
  assign WILL_FIRE_RL_rl_relay_console_in = CAN_FIRE_RL_rl_relay_console_in ;

  // rule RL_memCnx_ClientServerRequest
  assign CAN_FIRE_RL_memCnx_ClientServerRequest =
	     soc_top$RDY_to_raw_mem_request_get &&
	     mem_model$RDY_mem_server_request_put ;
  assign WILL_FIRE_RL_memCnx_ClientServerRequest =
	     CAN_FIRE_RL_memCnx_ClientServerRequest ;

  // rule RL_memCnx_ClientServerResponse
  assign CAN_FIRE_RL_memCnx_ClientServerResponse =
	     soc_top$RDY_to_raw_mem_response_put &&
	     mem_model$RDY_mem_server_response_get ;
  assign WILL_FIRE_RL_memCnx_ClientServerResponse =
	     CAN_FIRE_RL_memCnx_ClientServerResponse ;

  // register rg_banner_printed
  assign rg_banner_printed$D_IN = 1'd1 ;
  assign rg_banner_printed$EN = CAN_FIRE_RL_rl_step0 ;

  // register rg_console_in_poll
  assign rg_console_in_poll$D_IN = rg_console_in_poll + 12'd1 ;
  assign rg_console_in_poll$EN = CAN_FIRE_RL_rl_relay_console_in ;

  // submodule mem_model
  assign mem_model$mem_server_request_put = soc_top$to_raw_mem_request_get ;
  assign mem_model$EN_mem_server_request_put =
	     CAN_FIRE_RL_memCnx_ClientServerRequest ;
  assign mem_model$EN_mem_server_response_get =
	     CAN_FIRE_RL_memCnx_ClientServerResponse ;

  // submodule soc_top
  assign soc_top$cms_ifc_halt_cpu_state = 1'b0 ;
  assign soc_top$core_dmem_post_fabric_arready = 1'd0 ;
  assign soc_top$core_dmem_post_fabric_awready = 1'd1 ;
  assign soc_top$core_dmem_post_fabric_bid =
	     7'b0101010 /* unspecified value */  ;
  assign soc_top$core_dmem_post_fabric_bresp =
	     2'b10 /* unspecified value */  ;
  assign soc_top$core_dmem_post_fabric_bvalid = 1'd0 ;
  assign soc_top$core_dmem_post_fabric_rdata =
	     64'hAAAAAAAAAAAAAAAA /* unspecified value */  ;
  assign soc_top$core_dmem_post_fabric_rid =
	     7'b0101010 /* unspecified value */  ;
  assign soc_top$core_dmem_post_fabric_rlast = 1'b0 /* unspecified value */  ;
  assign soc_top$core_dmem_post_fabric_rresp =
	     2'b10 /* unspecified value */  ;
  assign soc_top$core_dmem_post_fabric_rvalid = 1'd0 ;
  assign soc_top$core_dmem_post_fabric_wready = 1'd0 ;
  assign soc_top$core_dmem_pre_fabric_arready = 1'd0 ;
  assign soc_top$core_dmem_pre_fabric_awready = 1'd1 ;
  assign soc_top$core_dmem_pre_fabric_bid =
	     6'b101010 /* unspecified value */  ;
  assign soc_top$core_dmem_pre_fabric_bresp = 2'b10 /* unspecified value */  ;
  assign soc_top$core_dmem_pre_fabric_bvalid = 1'd0 ;
  assign soc_top$core_dmem_pre_fabric_rdata =
	     64'hAAAAAAAAAAAAAAAA /* unspecified value */  ;
  assign soc_top$core_dmem_pre_fabric_rid =
	     6'b101010 /* unspecified value */  ;
  assign soc_top$core_dmem_pre_fabric_rlast = 1'b0 /* unspecified value */  ;
  assign soc_top$core_dmem_pre_fabric_rresp = 2'b10 /* unspecified value */  ;
  assign soc_top$core_dmem_pre_fabric_rvalid = 1'd0 ;
  assign soc_top$core_dmem_pre_fabric_wready = 1'd0 ;
  assign soc_top$put_from_console_put = v__h2957 ;
  assign soc_top$set_verbosity_logdelay = 64'd0 ;
  assign soc_top$set_verbosity_verbosity = 4'd2 ;
  assign soc_top$set_watch_tohost_tohost_addr = tohost_addr__h2316 ;
  assign soc_top$set_watch_tohost_watch_tohost = TASK_testplusargs___d11 ;
  assign soc_top$to_raw_mem_response_put = mem_model$mem_server_response_get ;
  assign soc_top$EN_to_raw_mem_request_get =
	     CAN_FIRE_RL_memCnx_ClientServerRequest ;
  assign soc_top$EN_to_raw_mem_response_put =
	     CAN_FIRE_RL_memCnx_ClientServerResponse ;
  assign soc_top$EN_get_to_console_get = soc_top$RDY_get_to_console_get ;
  assign soc_top$EN_put_from_console_put =
	     WILL_FIRE_RL_rl_relay_console_in &&
	     rg_console_in_poll == 12'd0 &&
	     v__h2957 != 8'd0 ;
  assign soc_top$EN_set_verbosity = CAN_FIRE_RL_rl_step0 ;
  assign soc_top$EN_set_watch_tohost = CAN_FIRE_RL_rl_step0 ;
  assign soc_top$EN_ma_ddr4_ready = CAN_FIRE_RL_rl_step0 ;
  assign soc_top$EN_cms_ifc_halt_cpu = 1'b0 ;

  // remaining internal signals
  assign test_num__h2659 = { 1'd0, soc_top$mv_tohost_value[63:1] } ;

  // handling of inlined registers

  always@(posedge CLK)
  begin
    if (RST_N == `BSV_RESET_VALUE)
      begin
        rg_banner_printed <= `BSV_ASSIGNMENT_DELAY 1'd0;
	rg_console_in_poll <= `BSV_ASSIGNMENT_DELAY 12'd0;
      end
    else
      begin
        if (rg_banner_printed$EN)
	  rg_banner_printed <= `BSV_ASSIGNMENT_DELAY rg_banner_printed$D_IN;
	if (rg_console_in_poll$EN)
	  rg_console_in_poll <= `BSV_ASSIGNMENT_DELAY rg_console_in_poll$D_IN;
      end
  end

  // synopsys translate_off
  `ifdef BSV_NO_INITIAL_BLOCKS
  `else // not BSV_NO_INITIAL_BLOCKS
  initial
  begin
    rg_banner_printed = 1'h0;
    rg_console_in_poll = 12'hAAA;
  end
  `endif // BSV_NO_INITIAL_BLOCKS
  // synopsys translate_on

  // handling of system tasks

  // synopsys translate_off
  always@(negedge CLK)
  begin
    #0;
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_rl_terminate)
	begin
	  v__h2450 = $stime;
	  #0;
	end
    v__h2444 = v__h2450 / 32'd10;
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_rl_terminate)
	$display("%0d: %m:.rl_terminate: soc_top status is 0x%0h (= 0d%0d)",
		 v__h2444,
		 soc_top$mv_status,
		 soc_top$mv_status);
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_rl_terminate)
	begin
	  v__h2500 = $stime;
	  #0;
	end
    v__h2494 = v__h2500 / 32'd10;
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_rl_terminate)
	$imported_c_end_timing({ 32'd0, v__h2494 });
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_rl_terminate) $finish(32'd0);
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_rl_terminate_tohost)
	$display("****************************************************************");
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_rl_terminate_tohost)
	begin
	  v__h2616 = $stime;
	  #0;
	end
    v__h2610 = v__h2616 / 32'd10;
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_rl_terminate_tohost)
	$display("%0d: %m:.rl_terminate_tohost: tohost_value is 0x%0h (= 0d%0d)",
		 v__h2610,
		 soc_top$mv_tohost_value,
		 soc_top$mv_tohost_value);
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_rl_terminate_tohost &&
	  soc_top$mv_tohost_value[63:1] == 63'd0)
	$display("    PASS");
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_rl_terminate_tohost &&
	  soc_top$mv_tohost_value[63:1] != 63'd0)
	$display("    FAIL <test_%0d>", test_num__h2659);
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_rl_terminate_tohost)
	begin
	  v__h2763 = $stime;
	  #0;
	end
    v__h2757 = v__h2763 / 32'd10;
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_rl_terminate_tohost)
	$imported_c_end_timing({ 32'd0, v__h2757 });
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_rl_terminate_tohost) $finish(32'd0);
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_rl_step0)
	$display("================================================================");
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_rl_step0)
	$display("Bluespec RISC-V WindSoC simulation v1.2");
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_rl_step0)
	$display("Copyright (c) 2017-2020 Bluespec, Inc. All Rights Reserved.");
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_rl_step0)
	$display("================================================================");
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_rl_step0)
	begin
	  Task_$test$plusargs__avValue1 = $test$plusargs("v1");
	  #0;
	end
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_rl_step0)
	begin
	  Task_$test$plusargs__avValue2 = $test$plusargs("v2");
	  #0;
	end
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_rl_step0)
	begin
	  TASK_testplusargs___d11 = $test$plusargs("tohost");
	  #0;
	end
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_rl_step0)
	begin
	  tohost_addr__h2316 = $imported_c_get_symbol_val("tohost");
	  #0;
	end
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_rl_step0)
	$display("INFO: watch_tohost = %0d, tohost_addr = 0x%0h",
		 TASK_testplusargs___d11,
		 tohost_addr__h2316);
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_rl_step0)
	begin
	  v__h2381 = $stime;
	  #0;
	end
    v__h2375 = v__h2381 / 32'd10;
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_rl_step0)
	$imported_c_start_timing({ 32'd0, v__h2375 });
    if (RST_N != `BSV_RESET_VALUE)
      if (soc_top$RDY_get_to_console_get)
	$write("%c", soc_top$get_to_console_get);
    if (RST_N != `BSV_RESET_VALUE)
      if (soc_top$RDY_get_to_console_get) $fflush(32'h80000001);
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_rl_relay_console_in && rg_console_in_poll == 12'd0)
	begin
	  v__h2957 = $imported_c_trygetchar(8'hAA);
	  #0;
	end
  end
  // synopsys translate_on
endmodule  // mkTop_HW_Side

