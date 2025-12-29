`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/28 20:03:34
// Design Name: 
// Module Name: datapath_tb
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


module datapath_tb;
reg clk;
reg rst_n;
reg start;
wire valid_out0, valid_out1;
wire signed [64-1:0] dout_R0;
wire signed [64-1:0] dout_I0;
wire signed [64-1:0] dout_R1;
wire signed [64-1:0] dout_I1;

datapath u_datapath(
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .valid_out0(valid_out0),
    .valid_out1(valid_out1),
    .dout_R0_bram(dout_R0),
    .dout_I0_bram(dout_I0),
    .dout_R1_bram(dout_R1),
    .dout_I1_bram(dout_I1)
);

parameter CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk = ~clk;  
initial begin
    clk = 0;
    rst_n = 0;
    start = 0;
    #(CLK_PERIOD*50);
    rst_n = 1;
    #(CLK_PERIOD*2);
    start = 1;
    #(CLK_PERIOD);
    start = 0;
    #(CLK_PERIOD*3000);
    $finish;
end
endmodule
