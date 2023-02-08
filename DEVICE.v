`timescale 1ns / 1ps

module DEVICE(
    input clk,
    input clk_pc2,
    input data_pc2,
    //output lamp,
    output hsync,
    output vsync,
    output [3:0] r,
    output [3:0] g,
    output [3:0] b
);

//wire [31:0] dataOut; // for result SQUARE

wire set_signal_enable;
wire reset_signal_enable;
wire new_clk;
//wire lamp = lamp;

//assign clk = clk_old; //------------commite for bitstream
//CLK_DIV div(
//    .clk(clk_old), 
//    .new_clk(clk));  //-----------uncommite for bitstream
    
CLK_DIV div(.clk(clk), .new_clk(new_clk));

wire [7:0] recieved_data; // то что выходит из ресивера для дешифратора
wire [7:0] inForFSM; // то что выходит из дешифратора для автомата
wire [7:0] res_code; // то что выходит из автомата для вга
wire set_signal;
wire reset_signal;
reg flag = 0;
wire pc2_ro;
reg ro_dc = 0;
wire res_out;

RECIEVER_pc2 reciever(
    .r(data_pc2),
    .clk(clk),
    .PC2_CLK(clk_pc2),
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
    //.lamp(lamp),
    .res_out(res_out));
    
top_vga display(
    .clk(clk), 
    .res_out(res_out),
    .res_code(res_code),
    .hsync(hsync),
    .vsync(vsync),
    .r(r),
    .g(g),
    .b(b));

always @(posedge clk)
begin
    if (pc2_ro&~flag&~clk_pc2) begin
        ro_dc <= 1;
        flag <= 1;
    end
    else ro_dc <= 0;
    if (clk_pc2) flag <= 0;
end

endmodule
