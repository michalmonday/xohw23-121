
// Copyright (c) 2000-2009 Bluespec, Inc.

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// $Revision: 24080 $
// $Date: 2011-05-18 15:32:52 -0400 (Wed, 18 May 2011) $

`ifdef  BSV_WARN_REGFILE_ADDR_RANGE
`else
`define BSV_WARN_REGFILE_ADDR_RANGE 0 
`endif


`ifdef BSV_ASSIGNMENT_DELAY
`else
`define BSV_ASSIGNMENT_DELAY
`endif


// Multi-ported Register File
module RegFile(CLK,
               ADDR_IN, D_IN, WE,
               ADDR_1, D_OUT_1,
               ADDR_2, D_OUT_2,
               ADDR_3, D_OUT_3,
               ADDR_4, D_OUT_4,
               ADDR_5, D_OUT_5,
               ADDR_6, D_OUT_6,
               ADDR_7, D_OUT_7,
               ADDR_8, D_OUT_8,
               ADDR_9, D_OUT_9,
               ADDR_10, D_OUT_10,
               ADDR_11, D_OUT_11,
               ADDR_12, D_OUT_12,
               ADDR_13, D_OUT_13,
               ADDR_14, D_OUT_14,
               ADDR_15, D_OUT_15,
               ADDR_16, D_OUT_16,
               ADDR_17, D_OUT_17,
               ADDR_18, D_OUT_18,
               ADDR_19, D_OUT_19,
               ADDR_20, D_OUT_20,
               ADDR_21, D_OUT_21,
               ADDR_22, D_OUT_22,
               ADDR_23, D_OUT_23,
               ADDR_24, D_OUT_24,
               ADDR_25, D_OUT_25,
               ADDR_26, D_OUT_26,
               ADDR_27, D_OUT_27,
               ADDR_28, D_OUT_28,
               ADDR_29, D_OUT_29,
               ADDR_30, D_OUT_30,
               ADDR_31, D_OUT_31,
               ADDR_32, D_OUT_32,
               ADDR_33, D_OUT_33,
               ADDR_34, D_OUT_34,
               ADDR_35, D_OUT_35,
               ADDR_36, D_OUT_36,
               ADDR_37, D_OUT_37,
               ADDR_38, D_OUT_38,
               ADDR_39, D_OUT_39,
               ADDR_40, D_OUT_40,
               ADDR_41, D_OUT_41,
               ADDR_42, D_OUT_42,
               ADDR_43, D_OUT_43,
               ADDR_44, D_OUT_44,
               ADDR_45, D_OUT_45,
               ADDR_46, D_OUT_46,
               ADDR_47, D_OUT_47,
               ADDR_48, D_OUT_48,
               ADDR_49, D_OUT_49,
               ADDR_50, D_OUT_50
               );
   parameter                   addr_width = 1;
   parameter                   data_width = 1;
   parameter                   lo = 0;
   parameter                   hi = 1;

   input                       CLK;
   input [addr_width - 1 : 0]  ADDR_IN;
   input [data_width - 1 : 0]  D_IN;
   input                       WE;

   input [addr_width - 1 : 0]  ADDR_1;
   output [data_width - 1 : 0] D_OUT_1;

   input [addr_width - 1 : 0]  ADDR_2;
   output [data_width - 1 : 0] D_OUT_2;

   input [addr_width - 1 : 0]  ADDR_3;
   output [data_width - 1 : 0] D_OUT_3;

   input [addr_width - 1 : 0]  ADDR_4;
   output [data_width - 1 : 0] D_OUT_4;

   input [addr_width - 1 : 0]  ADDR_5;
   output [data_width - 1 : 0] D_OUT_5;

   input [addr_width - 1 : 0]  ADDR_6;
   output [data_width - 1 : 0] D_OUT_6;

   input [addr_width - 1 : 0]  ADDR_7;
   output [data_width - 1 : 0] D_OUT_7;

   input [addr_width - 1 : 0]  ADDR_8;
   output [data_width - 1 : 0] D_OUT_8;

   input [addr_width - 1 : 0]  ADDR_9;
   output [data_width - 1 : 0] D_OUT_9;

   input [addr_width - 1 : 0]  ADDR_10;
   output [data_width - 1 : 0] D_OUT_10;

   input [addr_width - 1 : 0]  ADDR_11;
   output [data_width - 1 : 0] D_OUT_11;

   input [addr_width - 1 : 0]  ADDR_12;
   output [data_width - 1 : 0] D_OUT_12;

   input [addr_width - 1 : 0]  ADDR_13;
   output [data_width - 1 : 0] D_OUT_13;

   input [addr_width - 1 : 0]  ADDR_14;
   output [data_width - 1 : 0] D_OUT_14;

   input [addr_width - 1 : 0]  ADDR_15;
   output [data_width - 1 : 0] D_OUT_15;

   input [addr_width - 1 : 0]  ADDR_16;
   output [data_width - 1 : 0] D_OUT_16;

   input [addr_width - 1 : 0]  ADDR_17;
   output [data_width - 1 : 0] D_OUT_17;

   input [addr_width - 1 : 0]  ADDR_18;
   output [data_width - 1 : 0] D_OUT_18;

   input [addr_width - 1 : 0]  ADDR_19;
   output [data_width - 1 : 0] D_OUT_19;

   input [addr_width - 1 : 0]  ADDR_20;
   output [data_width - 1 : 0] D_OUT_20;

   input [addr_width - 1 : 0]  ADDR_21;
   output [data_width - 1 : 0] D_OUT_21;

   input [addr_width - 1 : 0]  ADDR_22;
   output [data_width - 1 : 0] D_OUT_22;

   input [addr_width - 1 : 0]  ADDR_23;
   output [data_width - 1 : 0] D_OUT_23;

   input [addr_width - 1 : 0]  ADDR_24;
   output [data_width - 1 : 0] D_OUT_24;

   input [addr_width - 1 : 0]  ADDR_25;
   output [data_width - 1 : 0] D_OUT_25;

   input [addr_width - 1 : 0]  ADDR_26;
   output [data_width - 1 : 0] D_OUT_26;

   input [addr_width - 1 : 0]  ADDR_27;
   output [data_width - 1 : 0] D_OUT_27;

   input [addr_width - 1 : 0]  ADDR_28;
   output [data_width - 1 : 0] D_OUT_28;

   input [addr_width - 1 : 0]  ADDR_29;
   output [data_width - 1 : 0] D_OUT_29;

   input [addr_width - 1 : 0]  ADDR_30;
   output [data_width - 1 : 0] D_OUT_30;

   input [addr_width - 1 : 0]  ADDR_31;
   output [data_width - 1 : 0] D_OUT_31;

   input [addr_width - 1 : 0]  ADDR_32;
   output [data_width - 1 : 0] D_OUT_32;

   input [addr_width - 1 : 0]  ADDR_33;
   output [data_width - 1 : 0] D_OUT_33;

   input [addr_width - 1 : 0]  ADDR_34;
   output [data_width - 1 : 0] D_OUT_34;

   input [addr_width - 1 : 0]  ADDR_35;
   output [data_width - 1 : 0] D_OUT_35;

   input [addr_width - 1 : 0]  ADDR_36;
   output [data_width - 1 : 0] D_OUT_36;

   input [addr_width - 1 : 0]  ADDR_37;
   output [data_width - 1 : 0] D_OUT_37;

   input [addr_width - 1 : 0]  ADDR_38;
   output [data_width - 1 : 0] D_OUT_38;

   input [addr_width - 1 : 0]  ADDR_39;
   output [data_width - 1 : 0] D_OUT_39;

   input [addr_width - 1 : 0]  ADDR_40;
   output [data_width - 1 : 0] D_OUT_40;

   input [addr_width - 1 : 0]  ADDR_41;
   output [data_width - 1 : 0] D_OUT_41;

   input [addr_width - 1 : 0]  ADDR_42;
   output [data_width - 1 : 0] D_OUT_42;

   input [addr_width - 1 : 0]  ADDR_43;
   output [data_width - 1 : 0] D_OUT_43;

   input [addr_width - 1 : 0]  ADDR_44;
   output [data_width - 1 : 0] D_OUT_44;

   input [addr_width - 1 : 0]  ADDR_45;
   output [data_width - 1 : 0] D_OUT_45;

   input [addr_width - 1 : 0]  ADDR_46;
   output [data_width - 1 : 0] D_OUT_46;

   input [addr_width - 1 : 0]  ADDR_47;
   output [data_width - 1 : 0] D_OUT_47;

   input [addr_width - 1 : 0]  ADDR_48;
   output [data_width - 1 : 0] D_OUT_48;

   input [addr_width - 1 : 0]  ADDR_49;
   output [data_width - 1 : 0] D_OUT_49;

   input [addr_width - 1 : 0]  ADDR_50;
   output [data_width - 1 : 0] D_OUT_50;

   reg [data_width - 1 : 0]    arr[lo:hi];


`ifdef BSV_NO_INITIAL_BLOCKS
`else // not BSV_NO_INITIAL_BLOCKS
   // synopsys translate_off
   initial
     begin : init_block
        integer                     i; 		// temporary for generate reset value
        for (i = lo; i <= hi; i = i + 1) begin
           arr[i] = {((data_width + 1)/2){2'b10}} ;
        end
     end // initial begin
   // synopsys translate_on
`endif // BSV_NO_INITIAL_BLOCKS


   always@(posedge CLK)
     begin
        if (WE)
          arr[ADDR_IN] <= `BSV_ASSIGNMENT_DELAY D_IN;
     end // always@ (posedge CLK)

   assign D_OUT_1 = arr[ADDR_1];
   assign D_OUT_2 = arr[ADDR_2];
   assign D_OUT_3 = arr[ADDR_3];
   assign D_OUT_4 = arr[ADDR_4];
   assign D_OUT_5 = arr[ADDR_5];
   assign D_OUT_6 = arr[ADDR_6];
   assign D_OUT_7 = arr[ADDR_7];
   assign D_OUT_8 = arr[ADDR_8];
   assign D_OUT_9 = arr[ADDR_9];
   assign D_OUT_10 = arr[ADDR_10];
   assign D_OUT_11 = arr[ADDR_11];
   assign D_OUT_12 = arr[ADDR_12];
   assign D_OUT_13 = arr[ADDR_13];
   assign D_OUT_14 = arr[ADDR_14];
   assign D_OUT_15 = arr[ADDR_15];
   assign D_OUT_16 = arr[ADDR_16];
   assign D_OUT_17 = arr[ADDR_17];
   assign D_OUT_18 = arr[ADDR_18];
   assign D_OUT_19 = arr[ADDR_19];
   assign D_OUT_20 = arr[ADDR_20];
   assign D_OUT_21 = arr[ADDR_21];
   assign D_OUT_22 = arr[ADDR_22];
   assign D_OUT_23 = arr[ADDR_23];
   assign D_OUT_24 = arr[ADDR_24];
   assign D_OUT_25 = arr[ADDR_25];
   assign D_OUT_26 = arr[ADDR_26];
   assign D_OUT_27 = arr[ADDR_27];
   assign D_OUT_28 = arr[ADDR_28];
   assign D_OUT_29 = arr[ADDR_29];
   assign D_OUT_30 = arr[ADDR_30];
   assign D_OUT_31 = arr[ADDR_31];
   assign D_OUT_32 = arr[ADDR_32];
   assign D_OUT_33 = arr[ADDR_33];
   assign D_OUT_34 = arr[ADDR_34];
   assign D_OUT_35 = arr[ADDR_35];
   assign D_OUT_36 = arr[ADDR_36];
   assign D_OUT_37 = arr[ADDR_37];
   assign D_OUT_38 = arr[ADDR_38];
   assign D_OUT_39 = arr[ADDR_39];
   assign D_OUT_40 = arr[ADDR_40];
   assign D_OUT_41 = arr[ADDR_41];
   assign D_OUT_42 = arr[ADDR_42];
   assign D_OUT_43 = arr[ADDR_43];
   assign D_OUT_44 = arr[ADDR_44];
   assign D_OUT_45 = arr[ADDR_45];
   assign D_OUT_46 = arr[ADDR_46];
   assign D_OUT_47 = arr[ADDR_47];
   assign D_OUT_48 = arr[ADDR_48];
   assign D_OUT_49 = arr[ADDR_49];
   assign D_OUT_50 = arr[ADDR_50];

   // synopsys translate_off
   always@(posedge CLK)
     begin : runtime_check
        reg enable_check;
        enable_check = `BSV_WARN_REGFILE_ADDR_RANGE ;
        if ( enable_check )
           begin
              if (( ADDR_1 < lo ) || (ADDR_1 > hi) )
                $display( "Warning: RegFile: %m -- Address port 1 is out of bounds: %h", ADDR_1 ) ;
              if (( ADDR_2 < lo ) || (ADDR_2 > hi) )
                $display( "Warning: RegFile: %m -- Address port 2 is out of bounds: %h", ADDR_2 ) ;
              if (( ADDR_3 < lo ) || (ADDR_3 > hi) )
                $display( "Warning: RegFile: %m -- Address port 3 is out of bounds: %h", ADDR_3 ) ;
              if (( ADDR_4 < lo ) || (ADDR_4 > hi) )
                $display( "Warning: RegFile: %m -- Address port 4 is out of bounds: %h", ADDR_4 ) ;
              if (( ADDR_5 < lo ) || (ADDR_5 > hi) )
                $display( "Warning: RegFile: %m -- Address port 5 is out of bounds: %h", ADDR_5 ) ;
              if (( ADDR_6 < lo ) || (ADDR_6 > hi) )
                $display( "Warning: RegFile: %m -- Address port 6 is out of bounds: %h", ADDR_6 ) ;
              if (( ADDR_7 < lo ) || (ADDR_7 > hi) )
                $display( "Warning: RegFile: %m -- Address port 7 is out of bounds: %h", ADDR_7 ) ;
              if (( ADDR_8 < lo ) || (ADDR_8 > hi) )
                $display( "Warning: RegFile: %m -- Address port 8 is out of bounds: %h", ADDR_8 ) ;
              if (( ADDR_9 < lo ) || (ADDR_9 > hi) )
                $display( "Warning: RegFile: %m -- Address port 9 is out of bounds: %h", ADDR_9 ) ;
              if (( ADDR_10 < lo ) || (ADDR_10 > hi) )
                $display( "Warning: RegFile: %m -- Address port 10 is out of bounds: %h", ADDR_10 ) ;
              if (( ADDR_11 < lo ) || (ADDR_11 > hi) )
                $display( "Warning: RegFile: %m -- Address port 11 is out of bounds: %h", ADDR_11 ) ;
              if (( ADDR_12 < lo ) || (ADDR_12 > hi) )
                $display( "Warning: RegFile: %m -- Address port 12 is out of bounds: %h", ADDR_12 ) ;
              if (( ADDR_13 < lo ) || (ADDR_13 > hi) )
                $display( "Warning: RegFile: %m -- Address port 13 is out of bounds: %h", ADDR_13 ) ;
              if (( ADDR_14 < lo ) || (ADDR_14 > hi) )
                $display( "Warning: RegFile: %m -- Address port 14 is out of bounds: %h", ADDR_14 ) ;
              if (( ADDR_15 < lo ) || (ADDR_15 > hi) )
                $display( "Warning: RegFile: %m -- Address port 15 is out of bounds: %h", ADDR_15 ) ;
              if (( ADDR_16 < lo ) || (ADDR_16 > hi) )
                $display( "Warning: RegFile: %m -- Address port 16 is out of bounds: %h", ADDR_16 ) ;
              if (( ADDR_17 < lo ) || (ADDR_17 > hi) )
                $display( "Warning: RegFile: %m -- Address port 17 is out of bounds: %h", ADDR_17 ) ;
              if (( ADDR_18 < lo ) || (ADDR_18 > hi) )
                $display( "Warning: RegFile: %m -- Address port 18 is out of bounds: %h", ADDR_18 ) ;
              if (( ADDR_19 < lo ) || (ADDR_19 > hi) )
                $display( "Warning: RegFile: %m -- Address port 19 is out of bounds: %h", ADDR_19 ) ;
              if (( ADDR_20 < lo ) || (ADDR_20 > hi) )
                $display( "Warning: RegFile: %m -- Address port 20 is out of bounds: %h", ADDR_20 ) ;
              if (( ADDR_21 < lo ) || (ADDR_21 > hi) )
                $display( "Warning: RegFile: %m -- Address port 21 is out of bounds: %h", ADDR_21 ) ;
              if (( ADDR_22 < lo ) || (ADDR_22 > hi) )
                $display( "Warning: RegFile: %m -- Address port 22 is out of bounds: %h", ADDR_22 ) ;
              if (( ADDR_23 < lo ) || (ADDR_23 > hi) )
                $display( "Warning: RegFile: %m -- Address port 23 is out of bounds: %h", ADDR_23 ) ;
              if (( ADDR_24 < lo ) || (ADDR_24 > hi) )
                $display( "Warning: RegFile: %m -- Address port 24 is out of bounds: %h", ADDR_24 ) ;
              if (( ADDR_25 < lo ) || (ADDR_25 > hi) )
                $display( "Warning: RegFile: %m -- Address port 25 is out of bounds: %h", ADDR_25 ) ;
              if (( ADDR_26 < lo ) || (ADDR_26 > hi) )
                $display( "Warning: RegFile: %m -- Address port 26 is out of bounds: %h", ADDR_26 ) ;
              if (( ADDR_27 < lo ) || (ADDR_27 > hi) )
                $display( "Warning: RegFile: %m -- Address port 27 is out of bounds: %h", ADDR_27 ) ;
              if (( ADDR_28 < lo ) || (ADDR_28 > hi) )
                $display( "Warning: RegFile: %m -- Address port 28 is out of bounds: %h", ADDR_28 ) ;
              if (( ADDR_29 < lo ) || (ADDR_29 > hi) )
                $display( "Warning: RegFile: %m -- Address port 29 is out of bounds: %h", ADDR_29 ) ;
              if (( ADDR_30 < lo ) || (ADDR_30 > hi) )
                $display( "Warning: RegFile: %m -- Address port 30 is out of bounds: %h", ADDR_30 ) ;
              if (( ADDR_31 < lo ) || (ADDR_31 > hi) )
                $display( "Warning: RegFile: %m -- Address port 31 is out of bounds: %h", ADDR_31 ) ;
              if (( ADDR_32 < lo ) || (ADDR_32 > hi) )
                $display( "Warning: RegFile: %m -- Address port 32 is out of bounds: %h", ADDR_32 ) ;
              if (( ADDR_33 < lo ) || (ADDR_33 > hi) )
                $display( "Warning: RegFile: %m -- Address port 33 is out of bounds: %h", ADDR_33 ) ;
              if (( ADDR_34 < lo ) || (ADDR_34 > hi) )
                $display( "Warning: RegFile: %m -- Address port 34 is out of bounds: %h", ADDR_34 ) ;
              if (( ADDR_35 < lo ) || (ADDR_35 > hi) )
                $display( "Warning: RegFile: %m -- Address port 35 is out of bounds: %h", ADDR_35 ) ;
              if (( ADDR_36 < lo ) || (ADDR_36 > hi) )
                $display( "Warning: RegFile: %m -- Address port 36 is out of bounds: %h", ADDR_36 ) ;
              if (( ADDR_37 < lo ) || (ADDR_37 > hi) )
                $display( "Warning: RegFile: %m -- Address port 37 is out of bounds: %h", ADDR_37 ) ;
              if (( ADDR_38 < lo ) || (ADDR_38 > hi) )
                $display( "Warning: RegFile: %m -- Address port 38 is out of bounds: %h", ADDR_38 ) ;
              if (( ADDR_39 < lo ) || (ADDR_39 > hi) )
                $display( "Warning: RegFile: %m -- Address port 39 is out of bounds: %h", ADDR_39 ) ;
              if (( ADDR_40 < lo ) || (ADDR_40 > hi) )
                $display( "Warning: RegFile: %m -- Address port 40 is out of bounds: %h", ADDR_40 ) ;
              if (( ADDR_41 < lo ) || (ADDR_41 > hi) )
                $display( "Warning: RegFile: %m -- Address port 41 is out of bounds: %h", ADDR_41 ) ;
              if (( ADDR_42 < lo ) || (ADDR_42 > hi) )
                $display( "Warning: RegFile: %m -- Address port 42 is out of bounds: %h", ADDR_42 ) ;
              if (( ADDR_43 < lo ) || (ADDR_43 > hi) )
                $display( "Warning: RegFile: %m -- Address port 43 is out of bounds: %h", ADDR_43 ) ;
              if (( ADDR_44 < lo ) || (ADDR_44 > hi) )
                $display( "Warning: RegFile: %m -- Address port 44 is out of bounds: %h", ADDR_44 ) ;
              if (( ADDR_45 < lo ) || (ADDR_45 > hi) )
                $display( "Warning: RegFile: %m -- Address port 45 is out of bounds: %h", ADDR_45 ) ;
              if (( ADDR_46 < lo ) || (ADDR_46 > hi) )
                $display( "Warning: RegFile: %m -- Address port 46 is out of bounds: %h", ADDR_46 ) ;
              if (( ADDR_47 < lo ) || (ADDR_47 > hi) )
                $display( "Warning: RegFile: %m -- Address port 47 is out of bounds: %h", ADDR_47 ) ;
              if (( ADDR_48 < lo ) || (ADDR_48 > hi) )
                $display( "Warning: RegFile: %m -- Address port 48 is out of bounds: %h", ADDR_48 ) ;
              if (( ADDR_49 < lo ) || (ADDR_49 > hi) )
                $display( "Warning: RegFile: %m -- Address port 49 is out of bounds: %h", ADDR_49 ) ;
              if (( ADDR_50 < lo ) || (ADDR_50 > hi) )
                $display( "Warning: RegFile: %m -- Address port 50 is out of bounds: %h", ADDR_50 ) ;
              if ( WE && ( ADDR_IN < lo ) || (ADDR_IN > hi) )
                $display( "Warning: RegFile: %m -- Write Address port is out of bounds: %h", ADDR_IN ) ;
           end
     end
   // synopsys translate_on

endmodule
