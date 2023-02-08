`timescale 1ns / 1ps

module DC_pc2 (input clk, input [7:0] pc2_data, input pc2_ro, output reg [7:0] fsm_data, output reg set_signal, output reg reset_signal); 

reg flag; // флаг, указывающий на то, что пришел код отжатия

parameter [7:0]
	releas = 8'hf0, // код отжатия
	s_key = 8'h29, // код клавиши пробел (set) 
	r_key = 8'h0D, //  код клавиши таб (reset)
	re_key = 8'h59; // код клавиши shift-правый (reset)

reg [7:0] dc; // код клавиши

initial
begin
    fsm_data = 8'b0; // / данные, которые потом будут отправляться в автомат клавиатурного тренажера
    flag = 0; 
    set_signal = 0;
    reset_signal = 0;
    dc = 8'b0;
end

always @(*)
begin
    case (pc2_data)
    // данные dc в зависимости от нажатой клавиши
        8'h15: dc <= 8'h15; // q
        8'h1D: dc <= 8'h1D; // w
        8'h24: dc <= 8'h24; // e
        8'h2D: dc <= 8'h2D; // r
        8'h2C: dc <= 8'h2C; // t
        8'h35: dc <= 8'h35; // y
        8'h3C: dc <= 8'h3C; // u
        8'h43: dc <= 8'h43; // i
        8'h44: dc <= 8'h44; // o
        8'h4D: dc <= 8'h4D; // p
        8'h1C: dc <= 8'h1C; // a
        8'h1B: dc <= 8'h1B; // s
        8'h23: dc <= 8'h23; // d
        8'h2B: dc <= 8'h2B; // f
        8'h34: dc <= 8'h34; // g
        8'h33: dc <= 8'h33; // h
        8'h3B: dc <= 8'h3B; // j
        8'h42: dc <= 8'h42; // k
        8'h4B: dc <= 8'h4B; // l
        8'h1A: dc <= 8'h1A; // z
        8'h22: dc <= 8'h22; // x
        8'h21: dc <= 8'h21; // c
        8'h2A: dc <= 8'h2A; // v
        8'h32: dc <= 8'h32; // b
        8'h31: dc <= 8'h31; // n
        8'h3A: dc <= 8'h3A; // m
        8'h5A: dc <= 8'h5A; // enter
        8'h45: dc <= 8'h45; // 0
        8'h16: dc <= 8'h16; // 1
        8'h1E: dc <= 8'h1E; // 2
        8'h26: dc <= 8'h26; // 3
        8'h25: dc <= 8'h25; // 4
        8'h2E: dc <= 8'h2E; // 5
        8'h36: dc <= 8'h36; // 6
        8'h3D: dc <= 8'h3D; // 7
        8'h3E: dc <= 8'h3E; // 8
        8'h46: dc <= 8'h46; // 9
        8'h41: dc <= 8'h41; // ,
        8'h49: dc <= 8'h49; // .
        8'h4A: dc <= 8'h4A; // /
        8'h4C: dc <= 8'h4C; // ;
        8'h52: dc <= 8'h52; // '
        8'h4E: dc <= 8'h4E; // -
        8'h55: dc <= 8'h55; // =
        8'h54: dc <= 8'h54; // [
        8'h5B: dc <= 8'h5B; // ]
        8'h5D: dc <= 8'h5D; // \
        // итого 47 символов  + tab + shift + ïðîáåë
        default: dc <= 0;
    endcase
end

always @(posedge clk)
begin
	if (pc2_ro)
	begin
		if (pc2_data == releas) flag <= 1;
		// если флаг уже установлен, то сейчас нам предоставлен код отжатой клавиши
		else if (flag)
		begin
			flag <= 0;
			if (pc2_data == s_key)
                set_signal <= 1;
			else if ((pc2_data == r_key) || (pc2_data == re_key))
			begin
				reset_signal <= 1;
				fsm_data <= 0;
			end
			else fsm_data <= dc;
		end
	end
	else
	begin
	   set_signal <= 0;
	   reset_signal <= 0;
	end
end

endmodule
