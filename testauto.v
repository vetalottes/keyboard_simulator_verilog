`timescale 1ns / 1ps

module testauto(input clk, PS2_clk, PS2_dat, output [7:0] res_code, output set_signal, output reset_signal, output res_out);

wire [7:0] res_code;
reg flag = 0;
reg ro_dc = 0;
wire pc2_ro;
wire set_signal, reset_signal, res_out;
wire [7:0] recieved_data;
wire [7:0] inForFSM;

RECIEVER_pc2 reciever(
    .r(PS2_dat),
    .clk(clk),
    .PC2_CLK(PS2_clk),
    .R_O(pc2_ro),
    .recieved_data(recieved_data));
    
DC_pc2 dc_pc2 (
    .clk(clk),
    .pc2_data(recieved_data),
    .pc2_ro(ro_dc),
    .fsm_data(inForFSM),
    .set_signal(set_signal),
    .reset_signal(reset_signal));
    
FIB fib2(
    .clk(clk),
    .set_signal(set_signal),
    .reset_signal(reset_signal),
    .code(inForFSM),
    .res_code(res_code),
    .res_out(res_out));

always @(posedge clk)
begin
    if (pc2_ro&~flag&~PS2_clk) begin
        ro_dc <= 1;
        flag <= 1;
    end
    else ro_dc <= 0;
    if (PS2_clk) flag <= 0;
end

endmodule