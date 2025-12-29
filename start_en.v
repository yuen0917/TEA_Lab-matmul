`timescale 1ns / 1ps


module start_en(
    input clk,
    input rst_n,
    input start,
    output reg start_out
    );
reg count;
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        start_out <= 0;
        count <= 0;
    end
    else if (start && !count)
    begin
        start_out <= 1;
        count <= 1;
    end
    else begin
        start_out <= 0;
    end
end
endmodule
