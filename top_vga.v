`timescale 1ns / 1ps

module top_vga(
        input clk,
        input res_out,
        input [7:0] res_code,
        output hsync,
        output vsync,
        output [3:0] r,
        output [3:0] g,
        output [3:0] b
    );

parameter [9:0] WIDTH = 10'd80; // 800 = 80 column
parameter [9:0] HEIGHT = 10'd60; // 600 = 60 column

wire clk50; // 50MHz signal (clk divided by 2)
CLK_DIV #(.MAX(1'd0)) div2(.clk(clk), .new_clk(clk50));

wire [9:0] x;
wire [9:0] y;
wire newframe;
wire newline;
wire valid;
reg [3:0]rval;
reg [3:0]gval;
reg [3:0]bval; 
  
vga  vga(
    .clk50(clk50),
    .h_counter(x),
    .v_counter(y),
    .hsync(hsync),
    .vsync(vsync),
    .valid(valid),
    .newframe(newframe),
    .newline(newline));

wire [7:0] pixels;
wire [31:0] line;
reg [5:0] char;

wire [7:0] line_px;
wire [7:0] column_px;

assign line_px = {1'b0,y[9:3]};
assign column_px = {1'b0,x[9:3]};

reg [9:0] line_counter;
 
initial begin
    char = 6'b0;
    line_counter = 10'b1;
    rval = 4'b0;
    bval = 4'b0;
    gval = 4'b0;
end

always @(*) begin
   if({2'b00,line_px} < line_counter) begin
   case (line_px)
    8'd37:
        case (column_px) 
              8'd50: begin
                case (res_code)
                    8'h15: char = 6'b000000; // q
                    8'h1D: char = 6'b000001; // w
                    8'h24: char = 6'b000010; // e
                    8'h2D: char = 6'b000011; // r
                    8'h2C: char = 6'b000100; // t
                    8'h35: char = 6'b000101; // y
                    8'h3C: char = 6'b000110; // u
                    8'h43: char = 6'b000111; // i
                    8'h44: char = 6'b001000; // o
                    8'h4D: char = 6'b001001; // p
                    8'h1C: char = 6'b001010; // a
                    8'h1B: char = 6'b001011; // s
                    8'h23: char = 6'b001100; // d
                    8'h2B: char = 6'b001101; // f
                    8'h34: char = 6'b001110; // g
                    8'h33: char = 6'b001111; // h
                    8'h3B: char = 6'b010000; // j
                    8'h42: char = 6'b010001; // k
                    8'h4B: char = 6'b010010; // l
                    8'h1A: char = 6'b010011; // z
                    8'h22: char = 6'b010100; // x
                    8'h21: char = 6'b010101; // c 
                    8'h2A: char = 6'b010110; // v 
                    8'h32: char = 6'b010111; // b
                    8'h31: char = 6'b011000; // n 
                    8'h3A: char = 6'b011001; // m
                    8'h45: char = 6'b011010; // 0
                    8'h16: char = 6'b011011; // 1
                    8'h1E: char = 6'b011100; // 2
                    8'h26: char = 6'b011101; // 3
                    8'h25: char = 6'b011110; // 4
                    8'h2E: char = 6'b011111; // 5
                    8'h36: char = 6'b100000; // 6
                    8'h3D: char = 6'b100001; // 7
                    8'h3E: char = 6'b100010; // 8
                    8'h46: char = 6'b100011; // 9
                    8'h41: char = 6'b100100; // ,
                    8'h49: char = 6'b100101; // .
                    8'h4A: char = 6'b100110; // /
                    8'h4C: char = 6'b100111; // ;
                    8'h52: char = 6'b101000; // '
                    8'h4E: char = 6'b101001; // -
                    8'h55: char = 6'b101010; // =
                    8'h54: char = 6'b101011; // [
                    8'h5B: char = 6'b101100; // ]
                    8'h5D: char = 6'b101101; // \
                    default: char = 6'b111111;
                endcase 
              end
            default: char = 6'b111111;
        endcase
        default: char = 6'b111111;
   endcase
   end
end

chars chars(
  .char(char),
  .rownum(y[2:0]),
  .pixels(pixels)
  );
   
   always@(posedge clk) begin 
       rval = 4'b0;
       bval = 4'b0;
       gval = 4'b0;
       if (line_counter +10'd2 > HEIGHT) line_counter <= 10'hff;
              else line_counter <= line_counter + 10'd2;
       if ((valid) && (pixels[3'd7-x[2:0]])) begin 
              if (res_out == 0) begin
                    rval <= 4'b0000;
                    gval <= 4'b1111;
                    bval <= 4'b0000;
               end
               if (res_out == 1) begin
                    rval <= 4'b1111;
                    gval <= 4'b0001;
                    bval <= 4'b0000;
               end
        end
   end    

assign r = rval;
assign g = gval;
assign b = bval;
        
endmodule
