`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2025/12/29 23:35:49
// Design Name:
// Module Name: controller
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
//   This controller schedules BRAM reads, PE accumulation, and BRAM write-back for
//   a group-based complex dot-product / matmul datapath.
//
//   High-level operation:
//   - Data is processed in "groups". Each group consists of VETOR_LEN (=8) elements.
//   - For each group, the controller reads 8 consecutive 32-bit words from the input/weight BRAMs,
//     enables the processing elements (PEs) to accumulate results, then writes the final 64-bit
//     accumulated outputs into the output BRAMs.
//
//   BRAM read (Port A) behavior:
//   - Port A is used as read-only for all input/weight BRAMs (WE=0).
//   - One shared address bram_addr_a is broadcast to multiple 32-bit BRAMs (R0i/I0i/R1i/I1i/WR/WI),
//     so all inputs and weights must be aligned at the same address.
//   - Addressing uses byte addressing:
//       bram_addr_a = (count << 2) + (outer_count << 5)
//     where count = 0..7 selects an element within the group (step = 4 bytes),
//     and outer_count selects the group base (group stride = 8 words = 32 bytes).
//     Therefore, element i of group g is read from address: 32*g + 4*i.
//
//   PE control:
//   - en_pe is asserted during COMPUTE to enable accumulation.
//   - When en_pe is deasserted, the PE modules clear their internal accumulators (per PE design).
//   - A READY state is inserted before COMPUTE to allow BRAM read latency and data stabilization.
//
//   BRAM write-back behavior (64-bit output BRAMs):
//   - Output BRAMs use byte addressing with 64-bit words (8 bytes per entry).
//   - The controller writes outputs in two phases:
//       * WRITE_BACK_0: writes output stream 0 (R0/I0) via Port B (bram_we_b = 8'hFF).
//       * WRITE_BACK_1: writes output stream 1 (R1/I1) via Port C (bram_we_c = 8'hFF).
//   - Write addresses are derived from the (delayed) group counter:
//       bram_addr_b = temp_outer_count[1] << 3
//       bram_addr_c = temp_outer_count[1] << 3
//     i.e., output entry k is written at address 8*k.
//
//   FSM summary:
//   - IDLE   : wait for start.
//   - READY  : enable BRAM reads, prime the pipeline.
//   - COMPUTE: iterate count=0..VETOR_LEN-1 with en_pe=1 to accumulate a group.
//   - WRITE_BACK_0 / WRITE_BACK_1: write accumulated results to output BRAMs.
//   - SHIFT  : prepare next group; asserts 'valid' for test/observation.
//   - FIN    : asserts 'finish' for one clock cycle, then returns to IDLE.
//
//   Notes:
//   - 'finish' is a one-cycle pulse when the FSM enters FIN.
//   - The second output stream may be time-skewed relative to the first (e.g., due to PE chaining),
//     so write-back is separated into two states to match output timing.
//////////////////////////////////////////////////////////////////////////////////

module controller#(
    parameter DATA_WIDTH_I = 32,
    parameter DATA_WIDTH_O = 64,
    parameter ADDR_WIDTH   = 32,
    parameter VETOR_LEN    = 8,
    parameter NUM_GROUP    = 257
)(
    input      clk,
    input      rst_n,
    input      start,

    output reg en_pe,
    // read data bram
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *)
    output  wire        bram_clk_a,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA RST" *)
    output  wire        bram_rst_a,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *)
    output  reg        bram_en_a,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *)
    output  reg  [3:0]  bram_we_a,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *)
    output  wire  [31:0] bram_addr_a,
    //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *)
    // output  wire  [31:0] bram_din_a,
    // (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *)
    // input wire [31:0] bram_dout_a,


    // write  data bram 0
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *)
    output  wire        bram_clk_b,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTB RST" *)
    output  wire        bram_rst_b,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *)
    output  reg         bram_en_b,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTB WE" *)
    output  reg  [7:0]  bram_we_b,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *)
    output  reg  [31:0] bram_addr_b,
    //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTB DIN" *)
    // output  wire  [31:0] bram_din_b,
    // (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *)
    // input wire [31:0] bram_dout_b,

// write data bram 1
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTC CLK" *)
    output  wire        bram_clk_c,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTC RST" *)
    output  wire        bram_rst_c,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTC EN" *)
    output  reg         bram_en_c,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTC WE" *)
    output  reg  [7:0]  bram_we_c,
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTC ADDR" *)
    output  reg  [31:0] bram_addr_c,
    //(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTC DIN" *)
    // output  wire  [31:0] bram_din_c,
    // (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORTC DOUT" *)
    // input wire [31:0] bram_dout_c,
    output valid,
    output finish
);
    integer i;
    reg [3:0] count; // count from 0 to 7
    reg [8:0] outer_count; // count from 0 to 256
    reg [8:0] temp_outer_count [0:1];
    reg [3:0] state, next_state;

    localparam IDLE         = 4'd0;
    localparam READY        = 4'd1;
    localparam COMPUTE      = 4'd2;
    localparam WRITE_BACK_0 = 4'd3;
    localparam WRITE_BACK_1 = 4'd4;
    localparam SHIFT        = 4'd5;
    localparam FIN          = 4'd6;

    reg [ 1:0] en_b_temp;
    reg [ 7:0] we_b_temp [0:1];
    reg [31:0] addr_b_temp [0:1];
    reg [ 1:0] en_c_temp;
    reg [ 7:0] we_c_temp [0:1];
    reg [31:0] addr_c_temp [0:1];

    assign bram_clk_a = clk;
    assign bram_rst_a = ~rst_n;
    assign bram_clk_b = clk;
    assign bram_rst_b = ~rst_n;
    assign bram_clk_c = clk;
    assign bram_rst_c = ~rst_n;
    reg en_pe_temp, en_pe_temp_1; // delay en_pe by 2 clk cycle
    assign valid = (state == SHIFT);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            en_pe <= 0;
        end else begin
            en_pe <= en_pe_temp;
        end
    end

    // shift  2 cycle for output bram address, enable, write enable
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            //en_b_temp[1] <= 1'b0;
            // we_b_temp[1] <= 1'b0;
            // addr_b_temp[1] <= 32'b0;
            // //en_c_temp[1] <= 1'b0;
            // we_c_temp[1] <= 1'b0;
            // addr_c_temp[1] <= 32'b0;

            //bram_en_b <= 0;
            bram_we_b   <= 0;
            bram_addr_b <= 0;
            //bram_en_c <= 0;
            bram_we_c   <= 0;
            bram_addr_c <= 0;
        end else begin
            // en_b_temp[1] <= en_b_temp[0];
            // we_b_temp[1] <= we_b_temp[0];
            // addr_b_temp[1] <= addr_b_temp[0];

            // en_c_temp[1] <= en_c_temp[0];
            // we_c_temp[1] <= we_c_temp[0];
            // addr_c_temp[1] <= addr_c_temp[0];

            //bram_en_b <= en_b_temp[1];
            bram_we_b   <= we_b_temp[0];
            bram_addr_b <= addr_b_temp[0];

            //bram_en_c <= en_c_temp[1];
            bram_we_c   <= we_c_temp[0];
            bram_addr_c <= addr_c_temp[0];
        end
    end

    // start FSM
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case (state)
            IDLE:
                next_state = start ? READY : IDLE;
            READY:
                next_state = COMPUTE;                                             // prepare for compute first group of data
            COMPUTE:
                next_state = (count == VETOR_LEN - 1) ? WRITE_BACK_0 : COMPUTE;   // count == 8-1 change state
            WRITE_BACK_0:                                                         // compute last data, and write baoutput ck first output data
                next_state = WRITE_BACK_1;
            WRITE_BACK_1:                                                         // write back second output data
                next_state = SHIFT;
            SHIFT:                                                                // prepare for next group of data
                next_state = (outer_count == 256) ? FIN : COMPUTE;
            FIN:
                next_state = IDLE;
            default:
                next_state = IDLE;
        endcase
    end
    // end FSM
    assign finish = (state == FIN);   // finish signal for one cycle pulse width

    // small counter
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
        end else if (state == COMPUTE) begin
            // if (count == VETOR_LEN - 1)
            //     count <= 0;
            // else
            count <= count + 1;
        end else begin
            count <= 0;
        end
    end


    // large counter
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            outer_count <= 0;
        end else if (state == IDLE) begin
            outer_count <= 0;
        end else if (state == WRITE_BACK_0) begin
            outer_count <= outer_count + 1;
        end
    end

    // shift large counter for 1 clk cycle
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            temp_outer_count[0] <= 0;
            temp_outer_count[1] <= 0;
        end else begin
            temp_outer_count[0] <= outer_count;
            temp_outer_count[1] <= temp_outer_count[0];
        end
    end
    assign bram_addr_a = (count << 2) + (outer_count << 5);    // address of input data bram and weight bram

    always @(*) begin
        addr_b_temp[0] = temp_outer_count[1] << 3;
    end

    always @(*) begin
        addr_c_temp[0] = temp_outer_count[1] << 3;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            en_pe_temp   <= 0;
            bram_en_a    <= 0;
            bram_we_a    <= 0;

            bram_en_b    <= 0;
            we_b_temp[0] <= 0;

            bram_en_c    <= 0;
            we_c_temp[0] <= 0;
            //valid <= 0;

        end else if (state == IDLE) begin
            en_pe_temp   <= 0;
            bram_en_a    <= 0;
            bram_we_a    <= 0;

            bram_en_b    <= 0;
            we_b_temp[0] <= 0;

            bram_en_c    <= 0;
            we_c_temp[0] <= 0;
        end else if (state == READY) begin
            en_pe_temp   <= 0;
            bram_en_a    <= 1;
            bram_we_a    <= 4'b0;

            bram_en_b    <= 1;    // 0
            we_b_temp[0] <= 8'b0;

            bram_en_c    <= 1;  // 0
            we_c_temp[0] <= 8'b0;
            //valid <= 1;

        end else if (state == COMPUTE) begin
            en_pe_temp   <= 1;
            bram_en_a    <= 1;
            bram_we_a    <= 4'b0;

            bram_en_b    <= 1;     // 0
            we_b_temp[0] <= 8'b0;

            bram_en_c    <= 1;    // 0
            we_c_temp[0] <= 8'b0;
            //valid <= 0;

        end else if (state == WRITE_BACK_0) begin
            en_pe_temp   <= 0;
            bram_en_a    <= 1;
            bram_we_a    <= 4'b0;

            bram_en_b    <= 1;
            we_b_temp[0] <= 8'b1111_1111;

            bram_en_c    <= 1;
            we_c_temp[0] <= 8'b0;

        end else if (state == WRITE_BACK_1) begin
            en_pe_temp   <= 0;
            bram_en_a    <= 1;
            bram_we_a    <= 4'b0;

            bram_en_b    <= 1;
            we_b_temp[0] <= 4'b0;

            bram_en_c    <= 1;
            we_c_temp[0] <= 8'b1111_1111;

        end else if (state == SHIFT) begin
            en_pe_temp   <= 0;
            bram_en_a    <= 1;
            bram_we_a    <= 4'b0;

            bram_en_b    <= 1;    // 0
            we_b_temp[0] <= 8'b0;

            bram_en_c    <= 1;    // 0
            we_c_temp[0] <= 8'b0;
        end
    end

endmodule
