// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
// Date        : Wed Dec 23 21:59:56 2020
// Host        : TOP-R9GCMPE-TYX running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/Users/tianyinxi/Desktop/bram/bram.srcs/sources_1/ip/SDPR/SDPR_stub.v
// Design      : SDPR
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tfgg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_1,Vivado 2017.4" *)
module SDPR(clka, ena, wea, addra, dina, clkb, enb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[18:0],dina[11:0],clkb,enb,addrb[18:0],doutb[11:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [18:0]addra;
  input [11:0]dina;
  input clkb;
  input enb;
  input [18:0]addrb;
  output [11:0]doutb;
endmodule
