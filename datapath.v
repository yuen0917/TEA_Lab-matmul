`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/28 19:44:24
// Design Name: 
// Module Name: datapath
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module datapath(
    input clk,
    input rst_n,
    input start,

    output valid_out0, valid_out1,
    output signed [64-1:0] dout_R0_bram,
    output signed [64-1:0] dout_I0_bram,
    output signed [64-1:0] dout_R1_bram,
    output signed [64-1:0] dout_I1_bram,
    output finish,

    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR0i CLK" *)
    input  wire        bram_clk_R0i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR0i RST" *)
    input  wire        bram_rst_R0i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR0i EN" *)
    input  wire        bram_en_R0i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR0i WE" *)
    input  wire  [3:0]  bram_we_R0i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR0i ADDR" *)
    input  wire  [12:0] bram_addr_R0i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR0i DIN" *)
    input  wire  [31:0] bram_din_R0i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR0i DOUT" *)
    output wire [31:0] bram_dout_R0i,

    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI0i CLK" *)
    input  wire        bram_clk_I0i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI0i RST" *)
    input  wire        bram_rst_I0i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI0i EN" *)
    input  wire        bram_en_I0i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI0i WE" *)
    input  wire  [3:0]  bram_we_I0i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI0i ADDR" *)
    input  wire  [12:0] bram_addr_I0i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI0i DIN" *)
    input  wire  [31:0] bram_din_I0i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI0i DOUT" *)
    output wire [31:0] bram_dout_I0i,

    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR1i CLK" *)
    input  wire        bram_clk_R1i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR1i RST" *)
    input  wire        bram_rst_R1i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR1i EN" *)
    input  wire        bram_en_R1i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR1i WE" *)
    input  wire  [3:0]  bram_we_R1i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR1i ADDR" *)
    input  wire  [12:0] bram_addr_R1i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR1i DIN" *)
    input  wire  [31:0] bram_din_R1i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR1i DOUT" *)
    output wire [31:0] bram_dout_R1i,

    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI1i CLK" *)
    input  wire        bram_clk_I1i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI1i RST" *)
    input  wire        bram_rst_I1i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI1i EN" *)
    input  wire        bram_en_I1i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI1i WE" *)
    input  wire  [3:0]  bram_we_I1i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI1i ADDR" *)
    input  wire  [12:0] bram_addr_I1i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI1i DIN" *)
    input  wire  [31:0] bram_din_I1i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI1i DOUT" *)
    output wire [31:0] bram_dout_I1i,

    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTWR CLK" *)
    input  wire        bram_clk_WR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTWR RST" *)
    input  wire        bram_rst_WR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTWR EN" *)
    input  wire        bram_en_WR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTWR WE" *)
    input  wire  [3:0]  bram_we_WR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTWR ADDR" *)
    input  wire  [12:0] bram_addr_WR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTWR DIN" *)
    input  wire  [31:0] bram_din_WR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTWR DOUT" *)
    output wire [31:0] bram_dout_WR,

    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTWI CLK" *)
    input  wire        bram_clk_WI,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTWI RST" *)
    input  wire        bram_rst_WI,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTWI EN" *)
    input  wire        bram_en_WI,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTWI WE" *)
    input  wire  [3:0]  bram_we_WI,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTWI ADDR" *)
    input  wire  [12:0] bram_addr_WI,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTWI DIN" *)
    input  wire  [31:0] bram_din_WI,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTWI DOUT" *)
    output wire [31:0] bram_dout_WI,

    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR0o CLK" *)
    input  wire        bram_clk_R0o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR0o RST" *)
    input  wire        bram_rst_R0o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR0o EN" *)
    input  wire        bram_en_R0o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR0o WE" *)
    input  wire  [7:0]  bram_we_R0o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR0o ADDR" *)
    input  wire  [13:0] bram_addr_R0o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR0o DIN" *)
    input  wire  [63:0] bram_din_R0o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR0o DOUT" *)
    output wire [63:0] bram_dout_R0o,

    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI0o CLK" *)
    input  wire        bram_clk_I0o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI0o RST" *)
    input  wire        bram_rst_I0o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI0o EN" *)
    input  wire        bram_en_I0o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI0o WE" *)
    input  wire  [7:0]  bram_we_I0o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI0o ADDR" *)
    input  wire  [13:0] bram_addr_I0o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI0o DIN" *)
    input  wire  [63:0] bram_din_I0o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI0o DOUT" *)
    output wire [63:0] bram_dout_I0o,

    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR1o CLK" *)
    input  wire        bram_clk_R1o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR1o RST" *)
    input  wire        bram_rst_R1o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR1o EN" *)
    input  wire        bram_en_R1o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR1o WE" *)
    input  wire  [7:0]  bram_we_R1o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR1o ADDR" *)
    input  wire  [13:0] bram_addr_R1o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR1o DIN" *)
    input  wire  [63:0] bram_din_R1o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTR1o DOUT" *)
    output wire [63:0] bram_dout_R1o,

    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI1o CLK" *)
    input  wire        bram_clk_I1o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI1o RST" *)
    input  wire        bram_rst_I1o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI1o EN" *)
    input  wire        bram_en_I1o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI1o WE" *)
    input  wire  [7:0]  bram_we_I1o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI1o ADDR" *)
    input  wire  [13:0] bram_addr_I1o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI1o DIN" *)
    input  wire  [63:0] bram_din_I1o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTI1o DOUT" *)
    output wire [63:0] bram_dout_I1o

);
wire en_pe;
wire bram_clk_a;
wire bram_rst_a;
wire bram_en_a;
wire [3:0]bram_we_a;
wire [31:0]bram_addr_a;
wire [31:0] bram_dout_a, bram_dout_b, bram_dout_c, bram_dout_d, bram_dout_e, bram_dout_f;
wire bram_clk_b;
wire bram_rst_b;
wire bram_en_b;
wire [7:0] bram_we_b;
wire [31:0] bram_addr_b;
wire bram_clk_c;
wire bram_rst_c;
wire bram_en_c;
wire [7:0] bram_we_c;
wire [31:0] bram_addr_c;
wire valid;


wire signed [64-1:0] dout_R0;
wire signed [64-1:0] dout_I0;
wire signed [64-1:0] dout_R1;
wire signed [64-1:0] dout_I1;
two_pe#(
    .WORD_LEN(32)
)u_tpe(
    .clk(clk),
    .rst_n(rst_n),
    .en(en_pe), 
    .valid(valid),
    .din_R_0(bram_dout_a),
    .din_I_0(bram_dout_b),
    .w_R(bram_dout_e), 
    .w_I(bram_dout_f), 
    .din_R_1(bram_dout_c), 
    .din_I_1(bram_dout_d),
    .dout_R_0(dout_R0), 
    .dout_I_0(dout_I0),
    .dout_R_1(dout_R1), 
    .dout_I_1(dout_I1),
    .valid_out_0(valid_out0), 
    .valid_out_1(valid_out1)
    );

controller u_controller(
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .en_pe(en_pe),
    .bram_clk_a(bram_clk_a),
    .bram_rst_a(bram_rst_a),
    .bram_en_a(bram_en_a),
    .bram_we_a(bram_we_a),
    .bram_addr_a(bram_addr_a),
    .bram_clk_b(bram_clk_b),
    .bram_rst_b(bram_rst_b),
    .bram_en_b(bram_en_b),
    .bram_we_b(bram_we_b),
    .bram_addr_b(bram_addr_b),
    .bram_clk_c(bram_clk_c),
    .bram_rst_c(bram_rst_c),
    .bram_en_c(bram_en_c),
    .bram_we_c(bram_we_c),
    .bram_addr_c(bram_addr_c),
    .valid(valid),
    .finish(finish)
    );

blk_mem_gen_0 din_R0_bram (
  .clka(bram_clk_a),            // input wire clka
  .rsta(bram_rst_a),            // input wire rsta
  .ena(bram_en_a),              // input wire ena
  .wea(bram_we_a),              // input wire [3 : 0] wea
  .addra(bram_addr_a),          // input wire [31 : 0] addra     // Let weight from 0 to 7
  .dina(),            // input wire [31 : 0] dina
  .douta(bram_dout_a),          // output wire [31 : 0] douta
  .clkb(bram_clk_R0i),            // input wire clkb
  .rstb(bram_rst_R0i),            // input wire rstb
  .enb(bram_en_R0i),              // input wire enb
  .web(bram_we_R0i),              // input wire [3 : 0] web
  .addrb(bram_addr_R0i),          // input wire [31 : 0] addrb
  .dinb(bram_din_R0i),            // input wire [31 : 0] dinb
  .doutb(bram_dout_R0i)          // output wire [31 : 0] doutb
);

dinI0_bram u_dinI0_bram (
  .clka(bram_clk_a),            // input wire clka
  .rsta(bram_rst_a),            // input wire rsta
  .ena(bram_en_a),              // input wire ena
  .wea(bram_we_a),              // input wire [3 : 0] wea
  .addra(bram_addr_a),          // input wire [31 : 0] addra      // Let weight from 0 to 7
  .dina(),            // input wire [31 : 0] dina
  .douta(bram_dout_b),          // output wire [31 : 0] douta
  .clkb(bram_clk_I0i),            // input wire clkb
  .rstb(bram_rst_I0i),            // input wire rstb
  .enb(bram_en_I0i),              // input wire enb
  .web(bram_we_I0i),              // input wire [3 : 0] web
  .addrb(bram_addr_I0i),          // input wire [31 : 0] addrb
  .dinb(bram_din_I0i),            // input wire [31 : 0] dinb
  .doutb(bram_dout_I0i),          // output wire [31 : 0] doutb
  .rsta_busy(),  // output wire rsta_busy
  .rstb_busy()  // output wire rstb_busy
);
blk_mem_gen_1 u_dinR1_bram (
  .clka(bram_clk_a),            // input wire clka
  .rsta(bram_rst_a),            // input wire rsta
  .ena(bram_en_a),              // input wire ena
  .wea(bram_we_a),              // input wire [3 : 0] wea
  .addra(bram_addr_a),          // input wire [31 : 0] addra       // Let weight from 0 to 7
  .dina(),            // input wire [31 : 0] dina
  .douta(bram_dout_c),          // output wire [31 : 0] douta
  .clkb(bram_clk_R1i),            // input wire clkb
  .rstb(bram_rst_R1i),            // input wire rstb
  .enb(bram_en_R1i),              // input wire enb
  .web(bram_we_R1i),              // input wire [3 : 0] web
  .addrb(bram_addr_R1i),          // input wire [31 : 0] addrb
  .dinb(bram_din_R1i),            // input wire [31 : 0] dinb
  .doutb(bram_dout_R1i),          // output wire [31 : 0] doutb
  .rsta_busy(),  // output wire rsta_busy
  .rstb_busy()  // output wire rstb_busy
);

blk_mem_gen_2 u_dinI1_bram (
  .clka(bram_clk_a),            // input wire clka
  .rsta(bram_rst_a),            // input wire rsta
  .ena(bram_en_a),              // input wire ena
  .wea(bram_we_a),              // input wire [3 : 0] wea
  .addra(bram_addr_a),          // input wire [31 : 0] addra       // Let weight from 0 to 7
  .dina(),            // input wire [31 : 0] dina
  .douta(bram_dout_d),          // output wire [31 : 0] douta
  .clkb(bram_clk_I1i),            // input wire clkb
  .rstb(bram_rst_I1i),            // input wire rstb
  .enb(bram_en_I1i),              // input wire enb
  .web(bram_we_I1i),              // input wire [3 : 0] web
  .addrb(bram_addr_I1i),          // input wire [31 : 0] addrb
  .dinb(bram_din_I1i),            // input wire [31 : 0] dinb
  .doutb(bram_dout_I1i),          // output wire [31 : 0] doutb
  .rsta_busy(),  // output wire rsta_busy
  .rstb_busy()  // output wire rstb_busy
);
wR_bram u_wR_bram (
  .clka(bram_clk_a),            // input wire clka
  .rsta(bram_rst_a),            // input wire rsta
  .ena(bram_en_a),              // input wire ena
  .wea(bram_we_a),              // input wire [3 : 0] wea
  .addra(bram_addr_a),          // input wire [31 : 0] addra
  .dina(),            // input wire [31 : 0] dina
  .douta(bram_dout_e),          // output wire [31 : 0] douta
  .clkb(bram_clk_WR),            // input wire clkb
  .rstb(bram_rst_WR),            // input wire rstb
  .enb(bram_en_WR),              // input wire enb
  .web(bram_we_WR),              // input wire [3 : 0] web
  .addrb(bram_addr_WR),          // input wire [31 : 0] addrb
  .dinb(bram_din_WR),            // input wire [31 : 0] dinb
  .doutb(bram_dout_WR),          // output wire [31 : 0] doutb
  .rsta_busy(),  // output wire rsta_busy
  .rstb_busy()  // output wire rstb_busy
);
wI_bram u_wI_bram (
  .clka(bram_clk_a),            // input wire clka
  .rsta(bram_rst_a),            // input wire rsta
  .ena(bram_en_a),              // input wire ena
  .wea(bram_we_a),              // input wire [3 : 0] wea
  .addra(bram_addr_a),          // input wire [31 : 0] addra
  .dina(),            // input wire [31 : 0] dina
  .douta(bram_dout_f),          // output wire [31 : 0] douta
  .clkb(bram_clk_WI),            // input wire clkb
  .rstb(bram_rst_WI),            // input wire rstb
  .enb(bram_en_WI),              // input wire enb
  .web(bram_we_WI),              // input wire [3 : 0] web
  .addrb(bram_addr_WI),          // input wire [31 : 0] addrb
  .dinb(bram_din_WI),            // input wire [31 : 0] dinb
  .doutb(bram_dout_WI),          // output wire [31 : 0] doutb
  .rsta_busy(),  // output wire rsta_busy
  .rstb_busy()  // output wire rstb_busy
);

doutR0_bram u_doutR0_bram (
  .clka(bram_clk_b),            // input wire clka
  .rsta(bram_rst_b),            // input wire rsta
  .ena(bram_en_b),              // input wire ena
  .wea(bram_we_b),              // input wire [7 : 0] wea
  .addra(bram_addr_b),          // input wire [31 : 0] addra
  .dina(dout_R0),            // input wire [63 : 0] dina
  .douta(dout_R0_bram),          // output wire [63 : 0] douta
  .clkb(bram_clk_R0o),            // input wire clkb
  .rstb(bram_rst_R0o),            // input wire rstb
  .enb(bram_en_R0o),              // input wire enb
  .web(bram_we_R0o),              // input wire [7 : 0] web
  .addrb(bram_addr_R0o),          // input wire [31 : 0] addrb
  .dinb(bram_din_R0o),            // input wire [63 : 0] dinb
  .doutb(bram_dout_R0o),          // output wire [63 : 0] doutb
  .rsta_busy(),  // output wire rsta_busy
  .rstb_busy()  // output wire rstb_busy
);
doutI0_bram u_doutI0_bram (
  .clka(bram_clk_b),            // input wire clka
  .rsta(bram_rst_b),            // input wire rsta
  .ena(bram_en_b),              // input wire ena
  .wea(bram_we_b),              // input wire [7 : 0] wea
  .addra(bram_addr_b),          // input wire [31 : 0] addra
  .dina(dout_I0),            // input wire [63 : 0] dina
  .douta(dout_I0_bram),          // output wire [63 : 0] douta
  .clkb(bram_clk_I0o),            // input wire clkb
  .rstb(bram_rst_I0o),            // input wire rstb
  .enb(bram_en_I0o),              // input wire enb
  .web(bram_we_I0o),              // input wire [7 : 0] web
  .addrb(bram_addr_I0o),          // input wire [31 : 0] addrb
  .dinb(bram_din_I0o),            // input wire [63 : 0] dinb
  .doutb(bram_dout_I0o),          // output wire [63 : 0] doutb
  .rsta_busy(),  // output wire rsta_busy
  .rstb_busy()  // output wire rstb_busy
);

doutR1_bram u_doutR1_bram (
  .clka(bram_clk_c),            // input wire clka
  .rsta(bram_rst_c),            // input wire rsta
  .ena(bram_en_c),              // input wire ena
  .wea(bram_we_c),              // input wire [7 : 0] wea
  .addra(bram_addr_c),          // input wire [31 : 0] addra
  .dina(dout_R1),            // input wire [63 : 0] dina
  .douta(dout_R1_bram),          // output wire [63 : 0] douta
  .clkb(bram_clk_R1o),            // input wire clkb
  .rstb(bram_rst_R1o),            // input wire rstb
  .enb(bram_en_R1o),              // input wire enb
  .web(bram_we_R1o),              // input wire [7 : 0] web
  .addrb(bram_addr_R1o),          // input wire [31 : 0] addrb
  .dinb(bram_din_R1o),            // input wire [63 : 0] dinb
  .doutb(bram_dout_R1o),          // output wire [63 : 0] doutb
  .rsta_busy(),  // output wire rsta_busy
  .rstb_busy()  // output wire rstb_busy
);

doutI1_bram u_doutI1_bram (
  .clka(bram_clk_c),            // input wire clka
  .rsta(bram_rst_c),            // input wire rsta
  .ena(bram_en_c),              // input wire ena
  .wea(bram_we_c),              // input wire [7 : 0] wea
  .addra(bram_addr_c),          // input wire [31 : 0] addra
  .dina(dout_I1),            // input wire [63 : 0] dina
  .douta(dout_I1_bram),          // output wire [63 : 0] douta
  .clkb(bram_clk_I1o),            // input wire clkb
  .rstb(bram_rst_I1o),            // input wire rstb
  .enb(bram_en_I1o),              // input wire enb
  .web(bram_we_I1o),              // input wire [7 : 0] web
  .addrb(bram_addr_I1o),          // input wire [31 : 0] addrb
  .dinb(bram_din_I1o),            // input wire [63 : 0] dinb
  .doutb(bram_dout_I1o),          // output wire [63 : 0] doutb
  .rsta_busy(),  // output wire rsta_busy
  .rstb_busy()  // output wire rstb_busy
);
endmodule
