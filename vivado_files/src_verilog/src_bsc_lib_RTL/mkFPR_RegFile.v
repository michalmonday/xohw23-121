//
// Generated by Bluespec Compiler, version untagged-g034050db (build 034050db)
//
//
// Ports:
// Name                         I/O  size props
// RDY_server_reset_request_put   O     1 reg
// RDY_server_reset_response_get  O     1
// read_rs1                       O    64
// read_rs1_port2                 O    64
// read_rs2                       O    64
// read_rs3                       O    64
// CLK                            I     1 clock
// RST_N                          I     1 reset
// read_rs1_rs1                   I     5
// read_rs1_port2_rs1             I     5
// read_rs2_rs2                   I     5
// read_rs3_rs3                   I     5
// write_rd_rd                    I     5
// write_rd_rd_val                I    64 reg
// EN_server_reset_request_put    I     1
// EN_server_reset_response_get   I     1
// EN_write_rd                    I     1
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

module mkFPR_RegFile(CLK,
		     RST_N,

		     EN_server_reset_request_put,
		     RDY_server_reset_request_put,

		     EN_server_reset_response_get,
		     RDY_server_reset_response_get,

		     read_rs1_rs1,
		     read_rs1,

		     read_rs1_port2_rs1,
		     read_rs1_port2,

		     read_rs2_rs2,
		     read_rs2,

		     read_rs3_rs3,
		     read_rs3,

		     write_rd_rd,
		     write_rd_rd_val,
		     EN_write_rd);
  input  CLK;
  input  RST_N;

  // action method server_reset_request_put
  input  EN_server_reset_request_put;
  output RDY_server_reset_request_put;

  // action method server_reset_response_get
  input  EN_server_reset_response_get;
  output RDY_server_reset_response_get;

  // value method read_rs1
  input  [4 : 0] read_rs1_rs1;
  output [63 : 0] read_rs1;

  // value method read_rs1_port2
  input  [4 : 0] read_rs1_port2_rs1;
  output [63 : 0] read_rs1_port2;

  // value method read_rs2
  input  [4 : 0] read_rs2_rs2;
  output [63 : 0] read_rs2;

  // value method read_rs3
  input  [4 : 0] read_rs3_rs3;
  output [63 : 0] read_rs3;

  // action method write_rd
  input  [4 : 0] write_rd_rd;
  input  [63 : 0] write_rd_rd_val;
  input  EN_write_rd;

  // signals for module outputs
  wire [63 : 0] read_rs1, read_rs1_port2, read_rs2, read_rs3;
  wire RDY_server_reset_request_put, RDY_server_reset_response_get;

  // register rg_state
  reg [1 : 0] rg_state;
  reg [1 : 0] rg_state$D_IN;
  wire rg_state$EN;

  // ports of submodule f_reset_rsps
  wire f_reset_rsps$CLR,
       f_reset_rsps$DEQ,
       f_reset_rsps$EMPTY_N,
       f_reset_rsps$ENQ,
       f_reset_rsps$FULL_N;

  // ports of submodule regfile
  wire [63 : 0] regfile$D_IN,
		regfile$D_OUT_1,
		regfile$D_OUT_2,
		regfile$D_OUT_3,
		regfile$D_OUT_4;
  wire [4 : 0] regfile$ADDR_1,
	       regfile$ADDR_10,
	       regfile$ADDR_11,
	       regfile$ADDR_12,
	       regfile$ADDR_13,
	       regfile$ADDR_14,
	       regfile$ADDR_15,
	       regfile$ADDR_16,
	       regfile$ADDR_17,
	       regfile$ADDR_18,
	       regfile$ADDR_19,
	       regfile$ADDR_2,
	       regfile$ADDR_20,
	       regfile$ADDR_21,
	       regfile$ADDR_22,
	       regfile$ADDR_23,
	       regfile$ADDR_24,
	       regfile$ADDR_25,
	       regfile$ADDR_26,
	       regfile$ADDR_27,
	       regfile$ADDR_28,
	       regfile$ADDR_29,
	       regfile$ADDR_3,
	       regfile$ADDR_30,
	       regfile$ADDR_31,
	       regfile$ADDR_32,
	       regfile$ADDR_33,
	       regfile$ADDR_34,
	       regfile$ADDR_35,
	       regfile$ADDR_36,
	       regfile$ADDR_37,
	       regfile$ADDR_4,
	       regfile$ADDR_5,
	       regfile$ADDR_6,
	       regfile$ADDR_7,
	       regfile$ADDR_8,
	       regfile$ADDR_9,
	       regfile$ADDR_IN;
  wire regfile$WE;

  // rule scheduling signals
  wire CAN_FIRE_RL_rl_reset_loop,
       CAN_FIRE_RL_rl_reset_start,
       CAN_FIRE_server_reset_request_put,
       CAN_FIRE_server_reset_response_get,
       CAN_FIRE_write_rd,
       WILL_FIRE_RL_rl_reset_loop,
       WILL_FIRE_RL_rl_reset_start,
       WILL_FIRE_server_reset_request_put,
       WILL_FIRE_server_reset_response_get,
       WILL_FIRE_write_rd;

  // action method server_reset_request_put
  assign RDY_server_reset_request_put = f_reset_rsps$FULL_N ;
  assign CAN_FIRE_server_reset_request_put = f_reset_rsps$FULL_N ;
  assign WILL_FIRE_server_reset_request_put = EN_server_reset_request_put ;

  // action method server_reset_response_get
  assign RDY_server_reset_response_get =
	     rg_state == 2'd2 && f_reset_rsps$EMPTY_N ;
  assign CAN_FIRE_server_reset_response_get =
	     rg_state == 2'd2 && f_reset_rsps$EMPTY_N ;
  assign WILL_FIRE_server_reset_response_get = EN_server_reset_response_get ;

  // value method read_rs1
  assign read_rs1 = regfile$D_OUT_4 ;

  // value method read_rs1_port2
  assign read_rs1_port2 = regfile$D_OUT_3 ;

  // value method read_rs2
  assign read_rs2 = regfile$D_OUT_2 ;

  // value method read_rs3
  assign read_rs3 = regfile$D_OUT_1 ;

  // action method write_rd
  assign CAN_FIRE_write_rd = 1'd1 ;
  assign WILL_FIRE_write_rd = EN_write_rd ;

  // submodule f_reset_rsps
  FIFO20 #(.guarded(1'd1)) f_reset_rsps(.RST(RST_N),
					.CLK(CLK),
					.ENQ(f_reset_rsps$ENQ),
					.DEQ(f_reset_rsps$DEQ),
					.CLR(f_reset_rsps$CLR),
					.FULL_N(f_reset_rsps$FULL_N),
					.EMPTY_N(f_reset_rsps$EMPTY_N));

  // submodule regfile
  RegFile #(.addr_width(32'd5),
	    .data_width(32'd64),
	    .lo(5'h0),
	    .hi(5'd31)) regfile(.CLK(CLK),
				.ADDR_1(regfile$ADDR_1),
				.ADDR_10(regfile$ADDR_10),
				.ADDR_11(regfile$ADDR_11),
				.ADDR_12(regfile$ADDR_12),
				.ADDR_13(regfile$ADDR_13),
				.ADDR_14(regfile$ADDR_14),
				.ADDR_15(regfile$ADDR_15),
				.ADDR_16(regfile$ADDR_16),
				.ADDR_17(regfile$ADDR_17),
				.ADDR_18(regfile$ADDR_18),
				.ADDR_19(regfile$ADDR_19),
				.ADDR_2(regfile$ADDR_2),
				.ADDR_20(regfile$ADDR_20),
				.ADDR_21(regfile$ADDR_21),
				.ADDR_22(regfile$ADDR_22),
				.ADDR_23(regfile$ADDR_23),
				.ADDR_24(regfile$ADDR_24),
				.ADDR_25(regfile$ADDR_25),
				.ADDR_26(regfile$ADDR_26),
				.ADDR_27(regfile$ADDR_27),
				.ADDR_28(regfile$ADDR_28),
				.ADDR_29(regfile$ADDR_29),
				.ADDR_3(regfile$ADDR_3),
				.ADDR_30(regfile$ADDR_30),
				.ADDR_31(regfile$ADDR_31),
				.ADDR_32(regfile$ADDR_32),
				.ADDR_33(regfile$ADDR_33),
				.ADDR_34(regfile$ADDR_34),
				.ADDR_35(regfile$ADDR_35),
				.ADDR_36(regfile$ADDR_36),
				.ADDR_37(regfile$ADDR_37),
				.ADDR_4(regfile$ADDR_4),
				.ADDR_5(regfile$ADDR_5),
				.ADDR_6(regfile$ADDR_6),
				.ADDR_7(regfile$ADDR_7),
				.ADDR_8(regfile$ADDR_8),
				.ADDR_9(regfile$ADDR_9),
				.ADDR_IN(regfile$ADDR_IN),
				.D_IN(regfile$D_IN),
				.WE(regfile$WE),
				.D_OUT_1(regfile$D_OUT_1),
				.D_OUT_2(regfile$D_OUT_2),
				.D_OUT_3(regfile$D_OUT_3),
				.D_OUT_4(regfile$D_OUT_4),
				.D_OUT_5(),
				.D_OUT_6(),
				.D_OUT_7(),
				.D_OUT_8(),
				.D_OUT_9(),
				.D_OUT_10(),
				.D_OUT_11(),
				.D_OUT_12(),
				.D_OUT_13(),
				.D_OUT_14(),
				.D_OUT_15(),
				.D_OUT_16(),
				.D_OUT_17(),
				.D_OUT_18(),
				.D_OUT_19(),
				.D_OUT_20(),
				.D_OUT_21(),
				.D_OUT_22(),
				.D_OUT_23(),
				.D_OUT_24(),
				.D_OUT_25(),
				.D_OUT_26(),
				.D_OUT_27(),
				.D_OUT_28(),
				.D_OUT_29(),
				.D_OUT_30(),
				.D_OUT_31(),
				.D_OUT_32(),
				.D_OUT_33(),
				.D_OUT_34(),
				.D_OUT_35(),
				.D_OUT_36(),
				.D_OUT_37());

  // rule RL_rl_reset_start
  assign CAN_FIRE_RL_rl_reset_start = rg_state == 2'd0 ;
  assign WILL_FIRE_RL_rl_reset_start = CAN_FIRE_RL_rl_reset_start ;

  // rule RL_rl_reset_loop
  assign CAN_FIRE_RL_rl_reset_loop = rg_state == 2'd1 ;
  assign WILL_FIRE_RL_rl_reset_loop = CAN_FIRE_RL_rl_reset_loop ;

  // register rg_state
  always@(EN_server_reset_request_put or
	  WILL_FIRE_RL_rl_reset_loop or WILL_FIRE_RL_rl_reset_start)
  case (1'b1)
    EN_server_reset_request_put: rg_state$D_IN = 2'd0;
    WILL_FIRE_RL_rl_reset_loop: rg_state$D_IN = 2'd2;
    WILL_FIRE_RL_rl_reset_start: rg_state$D_IN = 2'd1;
    default: rg_state$D_IN = 2'b10 /* unspecified value */ ;
  endcase
  assign rg_state$EN =
	     EN_server_reset_request_put || WILL_FIRE_RL_rl_reset_start ||
	     WILL_FIRE_RL_rl_reset_loop ;

  // submodule f_reset_rsps
  assign f_reset_rsps$ENQ = EN_server_reset_request_put ;
  assign f_reset_rsps$DEQ = EN_server_reset_response_get ;
  assign f_reset_rsps$CLR = 1'b0 ;

  // submodule regfile
  assign regfile$ADDR_1 = read_rs3_rs3 ;
  assign regfile$ADDR_10 = 5'h0 ;
  assign regfile$ADDR_11 = 5'h0 ;
  assign regfile$ADDR_12 = 5'h0 ;
  assign regfile$ADDR_13 = 5'h0 ;
  assign regfile$ADDR_14 = 5'h0 ;
  assign regfile$ADDR_15 = 5'h0 ;
  assign regfile$ADDR_16 = 5'h0 ;
  assign regfile$ADDR_17 = 5'h0 ;
  assign regfile$ADDR_18 = 5'h0 ;
  assign regfile$ADDR_19 = 5'h0 ;
  assign regfile$ADDR_2 = read_rs2_rs2 ;
  assign regfile$ADDR_20 = 5'h0 ;
  assign regfile$ADDR_21 = 5'h0 ;
  assign regfile$ADDR_22 = 5'h0 ;
  assign regfile$ADDR_23 = 5'h0 ;
  assign regfile$ADDR_24 = 5'h0 ;
  assign regfile$ADDR_25 = 5'h0 ;
  assign regfile$ADDR_26 = 5'h0 ;
  assign regfile$ADDR_27 = 5'h0 ;
  assign regfile$ADDR_28 = 5'h0 ;
  assign regfile$ADDR_29 = 5'h0 ;
  assign regfile$ADDR_3 = read_rs1_port2_rs1 ;
  assign regfile$ADDR_30 = 5'h0 ;
  assign regfile$ADDR_31 = 5'h0 ;
  assign regfile$ADDR_32 = 5'h0 ;
  assign regfile$ADDR_33 = 5'h0 ;
  assign regfile$ADDR_34 = 5'h0 ;
  assign regfile$ADDR_35 = 5'h0 ;
  assign regfile$ADDR_36 = 5'h0 ;
  assign regfile$ADDR_37 = 5'h0 ;
  assign regfile$ADDR_4 = read_rs1_rs1 ;
  assign regfile$ADDR_5 = 5'h0 ;
  assign regfile$ADDR_6 = 5'h0 ;
  assign regfile$ADDR_7 = 5'h0 ;
  assign regfile$ADDR_8 = 5'h0 ;
  assign regfile$ADDR_9 = 5'h0 ;
  assign regfile$ADDR_IN = write_rd_rd ;
  assign regfile$D_IN = write_rd_rd_val ;
  assign regfile$WE = EN_write_rd ;

  // handling of inlined registers

  always@(posedge CLK)
  begin
    if (RST_N == `BSV_RESET_VALUE)
      begin
        rg_state <= `BSV_ASSIGNMENT_DELAY 2'd0;
      end
    else
      begin
        if (rg_state$EN) rg_state <= `BSV_ASSIGNMENT_DELAY rg_state$D_IN;
      end
  end

  // synopsys translate_off
  `ifdef BSV_NO_INITIAL_BLOCKS
  `else // not BSV_NO_INITIAL_BLOCKS
  initial
  begin
    rg_state = 2'h2;
  end
  `endif // BSV_NO_INITIAL_BLOCKS
  // synopsys translate_on
endmodule  // mkFPR_RegFile
