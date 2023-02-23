//
// Generated by Bluespec Compiler, version untagged-g034050db (build 034050db)
//
//
// Ports:
// Name                         I/O  size props
// RDY_mem_server_request_put     O     1 reg
// mem_server_response_get        O   256 reg
// RDY_mem_server_response_get    O     1 reg
// CLK                            I     1 clock
// RST_N                          I     1 reset
// mem_server_request_put         I   353
// EN_mem_server_request_put      I     1
// EN_mem_server_response_get     I     1
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

module mkMem_Model(CLK,
		   RST_N,

		   mem_server_request_put,
		   EN_mem_server_request_put,
		   RDY_mem_server_request_put,

		   EN_mem_server_response_get,
		   mem_server_response_get,
		   RDY_mem_server_response_get);
  input  CLK;
  input  RST_N;

  // action method mem_server_request_put
  input  [352 : 0] mem_server_request_put;
  input  EN_mem_server_request_put;
  output RDY_mem_server_request_put;

  // actionvalue method mem_server_response_get
  input  EN_mem_server_response_get;
  output [255 : 0] mem_server_response_get;
  output RDY_mem_server_response_get;

  // signals for module outputs
  wire [255 : 0] mem_server_response_get;
  wire RDY_mem_server_request_put, RDY_mem_server_response_get;

  // ports of submodule f_raw_mem_rsps
  wire [255 : 0] f_raw_mem_rsps$D_IN, f_raw_mem_rsps$D_OUT;
  wire f_raw_mem_rsps$CLR,
       f_raw_mem_rsps$DEQ,
       f_raw_mem_rsps$EMPTY_N,
       f_raw_mem_rsps$ENQ,
       f_raw_mem_rsps$FULL_N;

  // ports of submodule rf
  wire [255 : 0] rf$D_IN, rf$D_OUT_1;
  wire [63 : 0] rf$ADDR_1,
		rf$ADDR_10,
		rf$ADDR_11,
		rf$ADDR_12,
		rf$ADDR_13,
		rf$ADDR_14,
		rf$ADDR_15,
		rf$ADDR_16,
		rf$ADDR_17,
		rf$ADDR_18,
		rf$ADDR_19,
		rf$ADDR_2,
		rf$ADDR_20,
		rf$ADDR_21,
		rf$ADDR_22,
		rf$ADDR_23,
		rf$ADDR_24,
		rf$ADDR_25,
		rf$ADDR_26,
		rf$ADDR_27,
		rf$ADDR_28,
		rf$ADDR_29,
		rf$ADDR_3,
		rf$ADDR_30,
		rf$ADDR_31,
		rf$ADDR_32,
		rf$ADDR_33,
		rf$ADDR_34,
		rf$ADDR_35,
		rf$ADDR_36,
		rf$ADDR_37,
		rf$ADDR_4,
		rf$ADDR_5,
		rf$ADDR_6,
		rf$ADDR_7,
		rf$ADDR_8,
		rf$ADDR_9,
		rf$ADDR_IN;
  wire rf$WE;

  // rule scheduling signals
  wire CAN_FIRE_mem_server_request_put,
       CAN_FIRE_mem_server_response_get,
       WILL_FIRE_mem_server_request_put,
       WILL_FIRE_mem_server_response_get;

  // declarations used by system tasks
  // synopsys translate_off
  reg [31 : 0] v__h1002;
  reg [31 : 0] v__h996;
  // synopsys translate_on

  // remaining internal signals
  wire mem_server_request_put_BITS_319_TO_256_ULT_335_ETC___d2;

  // action method mem_server_request_put
  assign RDY_mem_server_request_put = f_raw_mem_rsps$FULL_N ;
  assign CAN_FIRE_mem_server_request_put = f_raw_mem_rsps$FULL_N ;
  assign WILL_FIRE_mem_server_request_put = EN_mem_server_request_put ;

  // actionvalue method mem_server_response_get
  assign mem_server_response_get = f_raw_mem_rsps$D_OUT ;
  assign RDY_mem_server_response_get = f_raw_mem_rsps$EMPTY_N ;
  assign CAN_FIRE_mem_server_response_get = f_raw_mem_rsps$EMPTY_N ;
  assign WILL_FIRE_mem_server_response_get = EN_mem_server_response_get ;

  // submodule f_raw_mem_rsps
  FIFO2 #(.width(32'd256), .guarded(1'd1)) f_raw_mem_rsps(.RST(RST_N),
							  .CLK(CLK),
							  .D_IN(f_raw_mem_rsps$D_IN),
							  .ENQ(f_raw_mem_rsps$ENQ),
							  .DEQ(f_raw_mem_rsps$DEQ),
							  .CLR(f_raw_mem_rsps$CLR),
							  .D_OUT(f_raw_mem_rsps$D_OUT),
							  .FULL_N(f_raw_mem_rsps$FULL_N),
							  .EMPTY_N(f_raw_mem_rsps$EMPTY_N));

  // submodule rf
  RegFileLoad #(.file("Mem.hex"),
		.addr_width(32'd64),
		.data_width(32'd256),
		.lo(64'd0),
		.hi(64'd33554431),
		.binary(1'd0)) rf(.CLK(CLK),
				  .ADDR_1(rf$ADDR_1),
				  .ADDR_10(rf$ADDR_10),
				  .ADDR_11(rf$ADDR_11),
				  .ADDR_12(rf$ADDR_12),
				  .ADDR_13(rf$ADDR_13),
				  .ADDR_14(rf$ADDR_14),
				  .ADDR_15(rf$ADDR_15),
				  .ADDR_16(rf$ADDR_16),
				  .ADDR_17(rf$ADDR_17),
				  .ADDR_18(rf$ADDR_18),
				  .ADDR_19(rf$ADDR_19),
				  .ADDR_2(rf$ADDR_2),
				  .ADDR_20(rf$ADDR_20),
				  .ADDR_21(rf$ADDR_21),
				  .ADDR_22(rf$ADDR_22),
				  .ADDR_23(rf$ADDR_23),
				  .ADDR_24(rf$ADDR_24),
				  .ADDR_25(rf$ADDR_25),
				  .ADDR_26(rf$ADDR_26),
				  .ADDR_27(rf$ADDR_27),
				  .ADDR_28(rf$ADDR_28),
				  .ADDR_29(rf$ADDR_29),
				  .ADDR_3(rf$ADDR_3),
				  .ADDR_30(rf$ADDR_30),
				  .ADDR_31(rf$ADDR_31),
				  .ADDR_32(rf$ADDR_32),
				  .ADDR_33(rf$ADDR_33),
				  .ADDR_34(rf$ADDR_34),
				  .ADDR_35(rf$ADDR_35),
				  .ADDR_36(rf$ADDR_36),
				  .ADDR_37(rf$ADDR_37),
				  .ADDR_4(rf$ADDR_4),
				  .ADDR_5(rf$ADDR_5),
				  .ADDR_6(rf$ADDR_6),
				  .ADDR_7(rf$ADDR_7),
				  .ADDR_8(rf$ADDR_8),
				  .ADDR_9(rf$ADDR_9),
				  .ADDR_IN(rf$ADDR_IN),
				  .D_IN(rf$D_IN),
				  .WE(rf$WE),
				  .D_OUT_1(rf$D_OUT_1),
				  .D_OUT_2(),
				  .D_OUT_3(),
				  .D_OUT_4(),
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

  // submodule f_raw_mem_rsps
  assign f_raw_mem_rsps$D_IN = rf$D_OUT_1 ;
  assign f_raw_mem_rsps$ENQ =
	     EN_mem_server_request_put &&
	     mem_server_request_put_BITS_319_TO_256_ULT_335_ETC___d2 &&
	     !mem_server_request_put[352] ;
  assign f_raw_mem_rsps$DEQ = EN_mem_server_response_get ;
  assign f_raw_mem_rsps$CLR = 1'b0 ;

  // submodule rf
  assign rf$ADDR_1 = mem_server_request_put[319:256] ;
  assign rf$ADDR_10 = 64'h0 ;
  assign rf$ADDR_11 = 64'h0 ;
  assign rf$ADDR_12 = 64'h0 ;
  assign rf$ADDR_13 = 64'h0 ;
  assign rf$ADDR_14 = 64'h0 ;
  assign rf$ADDR_15 = 64'h0 ;
  assign rf$ADDR_16 = 64'h0 ;
  assign rf$ADDR_17 = 64'h0 ;
  assign rf$ADDR_18 = 64'h0 ;
  assign rf$ADDR_19 = 64'h0 ;
  assign rf$ADDR_2 = 64'h0 ;
  assign rf$ADDR_20 = 64'h0 ;
  assign rf$ADDR_21 = 64'h0 ;
  assign rf$ADDR_22 = 64'h0 ;
  assign rf$ADDR_23 = 64'h0 ;
  assign rf$ADDR_24 = 64'h0 ;
  assign rf$ADDR_25 = 64'h0 ;
  assign rf$ADDR_26 = 64'h0 ;
  assign rf$ADDR_27 = 64'h0 ;
  assign rf$ADDR_28 = 64'h0 ;
  assign rf$ADDR_29 = 64'h0 ;
  assign rf$ADDR_3 = 64'h0 ;
  assign rf$ADDR_30 = 64'h0 ;
  assign rf$ADDR_31 = 64'h0 ;
  assign rf$ADDR_32 = 64'h0 ;
  assign rf$ADDR_33 = 64'h0 ;
  assign rf$ADDR_34 = 64'h0 ;
  assign rf$ADDR_35 = 64'h0 ;
  assign rf$ADDR_36 = 64'h0 ;
  assign rf$ADDR_37 = 64'h0 ;
  assign rf$ADDR_4 = 64'h0 ;
  assign rf$ADDR_5 = 64'h0 ;
  assign rf$ADDR_6 = 64'h0 ;
  assign rf$ADDR_7 = 64'h0 ;
  assign rf$ADDR_8 = 64'h0 ;
  assign rf$ADDR_9 = 64'h0 ;
  assign rf$ADDR_IN = mem_server_request_put[319:256] ;
  assign rf$D_IN = mem_server_request_put[255:0] ;
  assign rf$WE =
	     EN_mem_server_request_put &&
	     mem_server_request_put_BITS_319_TO_256_ULT_335_ETC___d2 &&
	     mem_server_request_put[352] ;

  // remaining internal signals
  assign mem_server_request_put_BITS_319_TO_256_ULT_335_ETC___d2 =
	     mem_server_request_put[319:256] < 64'd33554432 ;

  // handling of system tasks

  // synopsys translate_off
  always@(negedge CLK)
  begin
    #0;
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_mem_server_request_put &&
	  !mem_server_request_put_BITS_319_TO_256_ULT_335_ETC___d2)
	begin
	  v__h1002 = $stime;
	  #0;
	end
    v__h996 = v__h1002 / 32'd10;
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_mem_server_request_put &&
	  !mem_server_request_put_BITS_319_TO_256_ULT_335_ETC___d2)
	$display("%0d: ERROR: Mem_Model.request.put: addr 0x%0h >= size 0x%0h (num raw-mem words)",
		 v__h996,
		 mem_server_request_put[319:256],
		 64'd33554432);
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_mem_server_request_put &&
	  !mem_server_request_put_BITS_319_TO_256_ULT_335_ETC___d2)
	$finish(32'd1);
  end
  // synopsys translate_on
endmodule  // mkMem_Model
