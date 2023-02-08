`timescale 1ns / 1ps

module FIB(input clk, input [7:0] code, input set_signal, input reset_signal, output reg res_out, output reg [7:0] res_code); // output reg lamp);

// code - код нажатой клавиши
// set_signal\reset_signal - сигналы установки\сброса
// res_out - true/false true/false в зависимости от сравнения (1 только в случае, когда символы не равны)
// res_code - код эталонной клавиши, который передается в vga для отображения
reg [2:0] state;
reg [7:0] need_symbol; // эталонное значение, с которым сравнивается нажатая клавиша

initial
begin
    res_out <= 0;
    state <= 3'd1;
end

always@(posedge clk)
begin
    if (reset_signal) begin
        res_out <= 0;
        res_code <= 8'h5A;
        state <= 3'd1;
    end
    case (state)
		3'd0: // задаем первое "нереальное" эталонное, которое равно символу включения клавиатурного тренажера
		begin
			need_symbol[7:0] <= 8'h5A; // тот символ, который запускает все - enter
			state <= 3'd2;
		end
		3'd1: // начало
		begin
		    res_out <= 0;
			if ((code[7:0] == 8'h5A) || (code[7:0] == 8'h00)) // если запускаем (клавиша enter) или неизвестная клавиша
                state <= 3'd0;
            else 
                state <= 3'd2;
		end
		3'd2: // сравнение
		begin
		  if ((code[7:0] == need_symbol[7:0]) && (need_symbol[7:0] == 8'h5A)) begin
			res_code[7:0] <= 8'h1B; // первое нормальное(!) эталонное (S), которое и нужно будет нажимать на клавиатуре
		      state <= 3'd4;
		  end
		  if ((code[7:0] == need_symbol[7:0]) && (need_symbol[7:0] != 8'h5A)) begin
		      state <=3'd3; // задать новое эталонное
		  end
		  if (code != need_symbol) begin
		      res_out <= 1; 
		      state <=3'd4; // оставить эталонное прежним
		  end
		end
		3'd3: // задаем эталонное
		begin
            		case (need_symbol)
			8'h1B: need_symbol <= 8'h1C; // S->A
			8'h1C: need_symbol <= 8'h34; // A->G
			8'h34: need_symbol <= 8'h4D; // P
			8'h4D: need_symbol <= 8'h45; // 0
			8'h45: need_symbol <= 8'h1D; // W
			8'h1D: need_symbol <= 8'h25; // 4
			8'h25: need_symbol <= 8'h4E; // -
			8'h4E: need_symbol <= 8'h22; // X
			8'h22: need_symbol <= 8'h15; // Q
			8'h15: need_symbol <= 8'h16; // 1
			8'h16: need_symbol <= 8'h2A; // V
			8'h2A: need_symbol <= 8'h3D; // 7
			8'h3D: need_symbol <= 8'h43; // I
			8'h43: need_symbol <= 8'h41; // ,
			8'h41: need_symbol <= 8'h23; // D
			8'h23: need_symbol <= 8'h2E; // 5
			8'h2E: need_symbol <= 8'h3E; // 8
			8'h3E: need_symbol <= 8'h3A; // M
			8'h3A: need_symbol <= 8'h2D; // R
			8'h2D: need_symbol <= 8'h42; // K
			8'h42: need_symbol <= 8'h5B; // ]
			8'h5B: need_symbol <= 8'h32; // B
			8'h32: need_symbol <= 8'h2C; // T
			8'h2C: need_symbol <= 8'h49; // .
			8'h49: need_symbol <= 8'h21; // C
			8'h21: need_symbol <= 8'h54; // [
			8'h54: need_symbol <= 8'h3C; // U
			8'h3C: need_symbol <= 8'h1A; // Z
			8'h1A: need_symbol <= 8'h4C; // ;
			8'h4C: need_symbol <= 8'h46; // 9
			8'h46: need_symbol <= 8'h1E; // 2
			8'h1E: need_symbol <= 8'h52; // '
			8'h52: need_symbol <= 8'h2B; // F
			8'h2B: need_symbol <= 8'h3B; // J
			8'h3B: need_symbol <= 8'h55; // =
			8'h55: need_symbol <= 8'h24; // E
			8'h24: need_symbol <= 8'h4B; // L
			8'h4B: need_symbol <= 8'h31; // N
			8'h31: need_symbol <= 8'h5D; // \
			8'h5D: need_symbol <= 8'h4A; // /
			8'h4A: need_symbol <= 8'h33; // H
			8'h33: need_symbol <= 8'h44; // O
			8'h44: need_symbol <= 8'h26; // 3
			8'h26: need_symbol <= 8'h35; // Y
			8'h35: need_symbol <= 8'h36; // 6
			    8'h36: need_symbol <= 8'h1B; // S (заново цикл)
            	endcase
            	state <=3'd4;
		end
		3'd4: begin // результат для vga
			 if (code[7:0] == 8'h5A) begin
			 	need_symbol <= 8'h1B;
			 end
			 else begin
			 	res_code[7:0] <= need_symbol[7:0];
			 end
			 if (set_signal) begin
				 state <= 3'd1; // если пришло новое значение символа с клавиатуры
			 end
		end
		default: state = 3'd1;
	endcase
end
endmodule
