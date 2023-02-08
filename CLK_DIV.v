`timescale 1ns / 1ps


module CLK_DIV #(parameter MAX = 15)(
    input clk,
    
    output new_clk
    );

    reg [MAX:0] cnt = 0;
    assign new_clk = cnt[MAX];
    always@(posedge clk) begin
        cnt <= cnt + 1'b1;
    end
endmodule
