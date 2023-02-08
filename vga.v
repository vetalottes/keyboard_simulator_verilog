`timescale 1ns / 1ps

module vga(
    input clk50,
    output reg [9:0] h_counter,
    output reg [9:0] v_counter,
    output hsync,
    output vsync,
    output valid,
    output reg newframe, // 1 clock pulse when new frame starts
    output reg newline // 1 clock pulse when new line starts
    );
  

// Параметры горизонтальной синхронизации (измеряются в тактах)
parameter [9:0] H_ACTIVE  =  10'd799;
parameter [9:0] H_FRONT   =  10'd55;
parameter [9:0] H_PULSE   =  10'd119;
parameter [9:0] H_BACK    =  10'd63;

//  Параметры вертикальной синхронизации (в линиях)
parameter [9:0] V_ACTIVE   =  10'd599;
parameter [9:0] V_FRONT    =  10'd36;
parameter [9:0] V_PULSE =  10'd5;
parameter [9:0] V_BACK  =  10'd22;

// States (more readable)
parameter   [7:0]    H_ACTIVE_STATE    = 8'd0;
parameter   [7:0]   H_FRONT_STATE     = 8'd1;
parameter   [7:0]   H_PULSE_STATE   = 8'd2;
parameter   [7:0]   H_BACK_STATE     = 8'd3;

parameter   [7:0]    V_ACTIVE_STATE    = 8'd0;
parameter   [7:0]   V_FRONT_STATE    = 8'd1;
parameter   [7:0]   V_PULSE_STATE   = 8'd2;
parameter   [7:0]   V_BACK_STATE     = 8'd3;

reg [7:0] h_state;
reg [7:0] v_state;
reg hsync_reg;
reg vsync_reg;   


initial begin
    h_state = 1'b0;
    v_state = 1'b0;
    hsync_reg = 1'b0;
    vsync_reg = 1'b0;
    h_counter = 1'b0;
    v_counter = 1'b0;
    newframe = 1'b0;
    newline = 1'b0;
end

always @(posedge clk50) begin
  newframe <= 1'b0;
  newline <= 1'b0;
  
        ///////////////////////// HORIZONTAL /////////////////////////////////////
        case(h_state)
            H_ACTIVE_STATE: begin
                // итерация горизонтального счетчика h_counter, ноль при H_ACTIVE
                h_counter <= (h_counter==H_ACTIVE)?10'd0:(h_counter + 10'd1);
                // установка hsync в 1
                hsync_reg <= 1'b1;
                // сброс newline
                newline <= 1'b0;
                // переход состояния
                h_state <= (h_counter == H_ACTIVE)?H_FRONT_STATE:H_ACTIVE_STATE;
            end
             
            H_FRONT_STATE: begin
                // Iterate horizontal counter, zero at end of H_FRONT mode
                h_counter <= (h_counter==H_FRONT)?10'd0:(h_counter + 10'd1);
                // Set hsync
                hsync_reg <= 1'b1;
                // State transition
                h_state <= (h_counter == H_FRONT)?H_PULSE_STATE:H_FRONT_STATE; 
            end
            
            H_PULSE_STATE: begin
                // Iterate horizontal counter, zero at end of H_PULSE mode
                h_counter <= (h_counter==H_PULSE)?10'd0:(h_counter + 10'd1);
                // Clear hsync
                hsync_reg <= 1'b0;
                // State transition
                h_state <= (h_counter == H_PULSE)?H_BACK_STATE:H_PULSE_STATE;
            end
            
            H_BACK_STATE: begin
             // Iterate horizontal counter, zero at end of H_BACK mode
                h_counter <= (h_counter==H_BACK)?10'd0:(h_counter + 10'd1) ;
                // Set hsync
                hsync_reg <= 1'b1 ;
                // State transition
                h_state <= (h_counter == H_BACK)?H_ACTIVE_STATE:H_BACK_STATE ;
                // Signal line complete at state transition (offset by 1 for synchronous state transition)
                newline <= (h_counter == (H_BACK-1))?1'b1:1'b0 ;
            end
            default:;
        endcase
        ///////////////////////// VERTICAL ///////////////////////////////////////
        case(v_state)
            V_ACTIVE_STATE: begin
                // increment vertical counter at end of line, zero on state transition
                v_counter<=(newline==1'b1)?((v_counter==V_ACTIVE)?10'd0:(v_counter+10'd1)):v_counter ;
                // set vsync in active mode
                vsync_reg <= 1'b1 ;
                // state transition - only on end of lines
                v_state<=(newline==1'b1)?((v_counter==V_ACTIVE)?V_FRONT_STATE:V_ACTIVE_STATE):V_ACTIVE_STATE ;
                // Deassert frame done
                newframe <= 1'b0 ;
            end
            
            V_FRONT_STATE: begin
                 // increment vertical counter at end of line, zero on state transition
                v_counter<=(newline==1'b1)?((v_counter==V_FRONT)?10'd0:(v_counter + 10'd1)):v_counter ;
                // set vsync in front porch
                vsync_reg <= 1'b1 ;
                // state transition
                v_state<=(newline==1'b1)?((v_counter==V_FRONT)?V_PULSE_STATE:V_FRONT_STATE):V_FRONT_STATE;
            end
            
            V_PULSE_STATE: begin
                // increment vertical counter at end of line, zero on state transition
                v_counter<=(newline==1'b1)?((v_counter==V_PULSE)?10'd0:(v_counter + 10'd1)):v_counter ;
                // clear vsync in pulse
                vsync_reg <= 1'b0 ;
                // state transition
                v_state<=(newline==1'b1)?((v_counter==V_PULSE)?V_BACK_STATE:V_PULSE_STATE):V_PULSE_STATE;
            end
            V_BACK_STATE: begin
                // increment vertical counter at end of line, zero on state transition
                v_counter<=(newline==1'b1)?((v_counter==V_BACK)?10'd0:(v_counter + 10'd1)):v_counter ;
                // set vsync in back porch
                vsync_reg <= 1'b1 ;
                // state transition
                v_state<=(newline==1'b1)?((v_counter==V_BACK)?V_ACTIVE_STATE:V_BACK_STATE):V_BACK_STATE ;
                
                // Deassert frame done
                newframe <= 1'b1 ;
            end
            default:;
        endcase
end

assign hsync = hsync_reg ;
assign vsync = vsync_reg ;
assign valid = (h_state == H_ACTIVE_STATE) && (v_state == V_ACTIVE_STATE);
    
endmodule
