`timescale 1ns / 1ps

module testforvga();

parameter	STOP_CODE = 8'hF0,
            RESET_CODE = 8'h0D, // tab
            SET_CODE = 8'h29, // пробел
			clk_period = 10,
			PS2_clk_period = 40,
			code_space_period = 60;

reg clk, PS2_clk, PS2_dat;
reg [7:0] key_code;
reg [3:0] i;

always #(clk_period) clk <= ~clk;

DEVICE t(.clk(clk), .clk_pc2(PS2_clk), .data_pc2(PS2_dat));
//);

initial begin
	PS2_clk <= 1;
	PS2_dat <= 1;
	key_code <= 0;

	clk <= 0;

	#(2*clk_period) key_code = HEX_CD(4'h1); // enter
	PS2_press_and_release_key(key_code);
	#(2*clk_period) key_code = SET_CODE; // пробел
	PS2_press_and_release_key(key_code);
	#(2*clk_period) key_code = HEX_CD(4'h9); // s
	PS2_press_and_release_key(key_code);
	#(2*clk_period) key_code = SET_CODE; // пробел
	PS2_press_and_release_key(key_code);
	#(2*clk_period) key_code = HEX_CD(4'h0); // a
	PS2_press_and_release_key(key_code);
	#(2*clk_period) key_code = SET_CODE; // пробел
	PS2_press_and_release_key(key_code);
	#(2*clk_period) key_code = RESET_CODE; // tab
	PS2_press_and_release_key(key_code);
	#(2*clk_period) key_code = HEX_CD(4'h9);
	PS2_press_and_release_key(key_code);
	$finish;
end


// Нажатие и отжатие клавиши
task automatic PS2_press_and_release_key(input [7:0] code);
	begin
		fork
			PS2_gen_byte_clk();
			PS2_code_input(code);
		join
		#code_space_period;
		fork
			PS2_gen_byte_clk();
			PS2_code_input(STOP_CODE);
		join
		#code_space_period;
		fork
			PS2_gen_byte_clk();
			PS2_code_input(code);
		join
	end
endtask

// Генерация пакета данных
task automatic PS2_code_input( input [7:0] code);
	begin
		PS2_dat <= 0;
		for (i = 0; i < 8; i = i + 1) begin
			@(posedge PS2_clk)
			PS2_dat <= code[i];
		end

		@(posedge PS2_clk)
		PS2_dat <= ~^(code);

		@(posedge PS2_clk)
		PS2_dat <= 1;
	end
endtask

// Генерация синхросигнала для передачи пакета
task automatic PS2_gen_byte_clk;
	begin
		#(clk_period);
		repeat(22) begin 
			PS2_clk <= ~PS2_clk;
			#(PS2_clk_period);
		end
		PS2_clk <= 1;
	end
endtask

function [7:0] HEX_CD;
	input [3:0] number_in;
	begin
		case(number_in)
			4'h0: HEX_CD = 8'h1C; //a
			4'h1: HEX_CD = 8'h5A; //enter +
			4'h2: HEX_CD = 8'h15; //q +
			4'h3: HEX_CD = 8'h29; // пробел
			4'h4: HEX_CD = 8'h2C; // таб
			4'h5: HEX_CD = 8'h34; //g +
			4'h6: HEX_CD = 8'h33; //h
			4'h7: HEX_CD = 8'h42; //k
			4'h8: HEX_CD = 8'h4B; //l
			4'h9: HEX_CD = 8'h1B; //s +
			4'hA: HEX_CD = 8'h1C; //a
			4'hB: HEX_CD = 8'h21; //c
			4'hC: HEX_CD = 8'h22; //x
			4'hD: HEX_CD = 8'h1A; // нет такого: шифт
			4'hE: HEX_CD = 8'h4D; //p +
			4'hF: HEX_CD = 8'h44; //o +
			default: HEX_CD = 0;
		endcase
	end
endfunction

endmodule