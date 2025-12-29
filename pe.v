`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2025/11/25 20:15:17
// Design Name:
// Module Name: pe
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
//   Processing Element (PE) for complex multiply-accumulate (MAC).
//   Computes: dout += din * w, where din and w are complex numbers (R/I).
//   - When en=1: accumulates the complex product into dout_R/dout_I.
//   - When en=0: clears the accumulators (dout_R/dout_I) and output flags.
//   - Passes w_R/w_I through to the next stage via w_R_nxt/w_I_nxt.
//   - valid_out is a registered version of valid for downstream alignment.
//////////////////////////////////////////////////////////////////////////////////

module pe#(
    parameter WORD_LEN = 24
//257 * 2 * 8
)(
    input                              clk,
    input                              rst_n,
    input                              en,
    input      signed [WORD_LEN-1:0]   din_R, din_I, w_R, w_I,
    input                              valid,
    output reg signed [2*WORD_LEN-1:0] dout_R, dout_I,
    output reg signed [WORD_LEN-1:0]   w_R_nxt, w_I_nxt,
    output reg                         valid_out
);
    wire signed [2*WORD_LEN-1:0] result_R, result_I;
    //reg [WORD_LEN-1:0] w_R_nxt, w_I_nxt;

    assign result_R = din_R * w_R - din_I * w_I;
    assign result_I = din_I * w_R + din_R * w_I;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            dout_R    <= 0;
            dout_I    <= 0;
            w_R_nxt   <= 0;
            w_I_nxt   <= 0;
            valid_out <= 0;
        end else if (en) begin
            dout_R    <= result_R + dout_R;
            dout_I    <= result_I + dout_I;
            w_R_nxt   <= w_R;   // pass through weight to next PE
            w_I_nxt   <= w_I;
            valid_out <= valid;
        end else begin
            dout_R    <= 0;
            dout_I    <= 0;
            w_R_nxt   <= 0;
            w_I_nxt   <= 0;
            valid_out <= 0;
        end
    end
endmodule
