`timescale 1ns / 1ps

module TIME_SET(
	input RESETN,
	input CLK,
	input [3:0] STATE,
	input [4:0] BUTTONS,
	input [17:0] CLOCK_DATA,
	output wire [17:0] TIME_SETDATA,
	output reg TIME_SET_FLAG
    );
	
	reg time_data_loaded;
	reg [3:0] cursor_position;
	reg [4:0] buttons_prev;
	reg [5:0] hour, min, sec;
	
	parameter INITIAL_DELAY = 4'b0000,
				 FUNCTION_SET = 4'b0001,
				 INITIAL_SETUP = 4'b0010,
				 CLEAR_SCREEN = 4'b0011,
				 SETUP = 4'b0100, // Menu select
				 TIME_SET = 4'b0101, // Time set
				 TZ_SET = 4'b0110, // Tinezone select
				 LINE1 = 4'b1000,
				 LINE2 = 4'b1001;
				 
	parameter UP = 5'b10000,
				 DOWN = 5'b01000,
				 LEFT = 5'b00010,
				 RIGHT = 5'b00001,
				 CENTER = 5'b00100;

	always @(negedge RESETN or posedge CLK) begin
		if (~RESETN) begin
			TIME_SET_FLAG <= 0;
			hour <= 0;
			min <= 0;
			sec <= 0;
			cursor_position <= 0;
			time_data_loaded <= 0;
		end else begin
			if (STATE == TIME_SET) begin
				if (~time_data_loaded) begin
					hour <= CLOCK_DATA[17:12];
					min <= CLOCK_DATA[11:6];
					sec <= CLOCK_DATA[5:0];
					time_data_loaded <= 1'b1;
					TIME_SET_FLAG <= 1'b0;
				end
					
				case ((buttons_prev ^ BUTTONS) & BUTTONS)
					UP: begin
						case (cursor_position)
							0: if (sec < 59) sec <= sec + 1; else sec <= 0;
							1: if (sec < 49) sec <= sec + 10; else sec <= sec - 50;
							2: if (min < 59) min <= min + 1; else min <= 0;
							3: if (min < 49) min <= min + 10; else min <= min - 50;
							4: if (hour < 23) hour <= hour + 1; else hour <= 0;
						endcase
					end
					
					DOWN: begin
						case(cursor_position)
							0: if (sec > 0) sec <= sec - 1; else sec <= 59;
							1: if (sec > 9) sec <= sec - 10; else sec <= sec + 50;
							2: if (min > 0) min <= min - 1; else min <= 59;
							3: if (min > 9) min <= min - 10; else min <= min + 50;
							4: if (hour > 0) hour <= hour - 1; else hour <= 23;
							endcase
						end
					
					LEFT: begin
						if (cursor_position < 4)
							cursor_position <= cursor_position + 1;
						else
							cursor_position <= 0;
					end
					
					RIGHT: begin
						if (cursor_position > 0)
							cursor_position <= cursor_position - 1;
						else
							cursor_position <= 4;
					end
					
					CENTER: begin
						TIME_SET_FLAG <= 1'b1;
						time_data_loaded <= 1'b0;
					end
				endcase
				
				buttons_prev <= BUTTONS;
			end
		end
	end
	
	assign TIME_SETDATA = {hour, min, sec};

endmodule
