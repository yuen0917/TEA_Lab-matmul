`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2025/11/25 21:57:29
// Design Name:
// Module Name: two_pe
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
//   two_pe instantiates two complex multiply-accumulate PEs (pe0 and pe1).
//   - pe0 processes input stream 0 using the external complex weight (w_R/w_I).
//   - pe1 processes input stream 1 using the weight forwarded from pe0 (w_R_nxt/w_I_nxt).
//   - Stream 1 (din_1) and en are delayed by 1 cycle to align with forwarded weight.
//   - valid is pipelined through pe0 -> pe1, producing valid_out_0 and valid_out_1.
//   Timing notes:
//   - PE1 operates one cycle later than PE0 due to input/register alignment.
//   - valid_out_0 corresponds to PE0 output timing; valid_out_1 corresponds to PE1 output timing.
//   - When integrating with output BRAM write-back, account for the 1-cycle skew between streams.
//////////////////////////////////////////////////////////////////////////////////


module two_pe#(
    parameter WORD_LEN = 24
)(
    input                        clk,
    input                        rst_n,
    input                        en, valid,
    input  signed [WORD_LEN-1:0] din_R_0, din_I_0, w_R, w_I,
    input  signed [WORD_LEN-1:0] din_R_1, din_I_1,
    output signed [64-1:0]       dout_R_0, dout_I_0,
    output signed [64-1:0]       dout_R_1, dout_I_1,
    output                       valid_out_0, valid_out_1
);
    wire signed [2*WORD_LEN-1:0] dout_R_0_t, dout_I_0_t;
    wire signed [2*WORD_LEN-1:0] dout_R_1_t, dout_I_1_t;

    reg  signed [WORD_LEN-1:0]   din_R_1_temp, din_I_1_temp;
    wire        [WORD_LEN-1:0]   w_R_nxt, w_I_nxt;
    wire                         valid_temp;
    reg                          en_temp;
    // delay din_1 by one cycle
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            din_R_1_temp <= 0;
            din_I_1_temp <= 0;
            en_temp      <= 0;
        end else if(en) begin
            din_R_1_temp <= din_R_1;
            din_I_1_temp <= din_I_1;
            en_temp      <= en;
        end else begin
            din_R_1_temp <= 0;
            din_I_1_temp <= 0;
            en_temp      <= 0;
        end
    end

    assign valid_out_0 = valid_temp;

    pe #(
        .WORD_LEN(WORD_LEN)
    )u_pe0(
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .din_R(din_R_0),
        .din_I(din_I_0),
        .w_R(w_R),
        .w_I(w_I),
        .w_R_nxt(w_R_nxt),
        .w_I_nxt(w_I_nxt),
        .dout_R(dout_R_0_t),
        .dout_I(dout_I_0_t),
        .valid(valid),  // valid signal not used in this design
        .valid_out(valid_temp)
    );

    pe #(
        .WORD_LEN(WORD_LEN)
    )u_pe1(
        .clk(clk),
        .rst_n(rst_n),
        .en(en_temp),
        .din_R(din_R_1_temp),
        .din_I(din_I_1_temp),
        .w_R(w_R_nxt),
        .w_I(w_I_nxt),
        .dout_R(dout_R_1_t),
        .dout_I(dout_I_1_t),
        .valid(valid_temp),  // valid signal not used in this design
        .valid_out(valid_out_1)
    );
    // clip data from 2*WORD_LEN+2 to 32 bit
    // assign dout_R_0 = dout_R_0_t > ({(WORD_LEN-1){1'b1}} << WORD_LEN-1) - 1 ? ({(WORD_LEN-1){1'b1}} << WORD_LEN-1) - 1:
    //                  (dout_R_0_t < ({(WORD_LEN-1){1'b1}} << WORD_LEN-1)) ? ({(WORD_LEN-1){1'b1}} << WORD_LEN-1) :
    //                  dout_R_0_t;
    // assign dout_R_1 = dout_R_1_t > ({(WORD_LEN-1){1'b1}} << WORD_LEN-1) - 1 ? ({(WORD_LEN-1){1'b1}} << WORD_LEN-1) - 1:
    //                  (dout_R_1_t < ({(WORD_LEN-1){1'b1}} << WORD_LEN-1)) ? ({(WORD_LEN-1){1'b1}} << WORD_LEN-1) :
    //                  dout_R_1_t;
    // assign dout_I_0 = dout_I_0_t > ({(WORD_LEN-1){1'b1}} << WORD_LEN-1) - 1 ? ({(WORD_LEN-1){1'b1}} << WORD_LEN-1) - 1:
    //                  (dout_I_0_t < ({(WORD_LEN-1){1'b1}} << WORD_LEN-1)) ? ({(WORD_LEN-1){1'b1}} << WORD_LEN-1) :
    //                  dout_I_0_t;
    // assign dout_I_1 = dout_I_1_t > ({(WORD_LEN-1){1'b1}} << WORD_LEN-1) - 1 ? ({(WORD_LEN-1){1'b1}} << WORD_LEN-1) - 1:
    //                  (dout_I_1_t < ({(WORD_LEN-1){1'b1}} << WORD_LEN-1)) ? ({(WORD_LEN-1){1'b1}} << WORD_LEN-1) :
    //                  dout_I_1_t;


    assign dout_R_0 = dout_R_0_t;
    assign dout_R_1 = dout_R_1_t;
    assign dout_I_0 = dout_I_0_t;
    assign dout_I_1 = dout_I_1_t;

endmodule
