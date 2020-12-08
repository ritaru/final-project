`timescale 1ns / 1ps

module TIME_SET(
	input RESETN,
	input CLK,
	input [3:0] STATE,
	input [4:0] BUTTONS,
	input [17:0] CLOCK_DATA,
	output reg [17:0] TIME_SETDATA,
	output reg TIME_SET_FLAG
    );

	reg time_data_loaded;
	reg [3:0] cursor_position;
	reg [4:0] buttons_prev;
	
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
			TIME_SETDATA <= 0;
			TIME_SET_FLAG <= 0;
			cursor_position <= 0;
			time_data_loaded <= 0;
		end else begin
			if (STATE == TIME_SET) begin
				if (~time_data_loaded) begin
					TIME_SETDATA <= CLOCK_DATA;
					time_data_loaded <= 1'b1;
				end
					
				case ((buttons_prev ^ BUTTONS) & BUTTONS)
					UP: begin
						case (cursor_position)
							0: if (TIME_SETDATA[5:0] < 59) TIME_SETDATA[5:0] <= TIME_SETDATA[5:0] + 1; else TIME_SETDATA[5:0] <= 0;
							1: if (TIME_SETDATA[5:0] < 49) TIME_SETDATA[5:0] <= TIME_SETDATA[5:0] + 10; else TIME_SETDATA[5:0] <= TIME_SETDATA[5:0] + 14;
							2: if (TIME_SETDATA[11:6] < 59) TIME_SETDATA[11:6] <= TIME_SETDATA[11:6] + 1; else TIME_SETDATA[11:6] <= 0;
							3: if (TIME_SETDATA[11:6] < 49) TIME_SETDATA[11:6] <= TIME_SETDATA[11:6] + 10; else TIME_SETDATA[11:6] <= TIME_SETDATA[11:6] + 14;
							4: if (TIME_SETDATA[17:12] < 23) TIME_SETDATA[17:12] <= TIME_SETDATA[17:12] + 1; else TIME_SETDATA[17:12] <= 0;
							5: begin
								if (TIME_SETDATA[17:12] < 13)
									TIME_SETDATA[17:12] <= TIME_SETDATA[17:12] + 10;
								else if (TIME_SETDATA[17:12] < 20)
									TIME_SETDATA[17:12] <= TIME_SETDATA[17:12] + 54;
								else
									TIME_SETDATA[17:12] <= TIME_SETDATA[17:12] + 44;
							end
						endcase
					end
					
					DOWN: begin
						case(cursor_position)
							0: if (TIME_SETDATA[5:0] > 0) TIME_SETDATA[5:0] <= TIME_SETDATA[5:0] - 1; else TIME_SETDATA[5:0] <= 59;
							1: if (TIME_SETDATA[5:0] > 9) TIME_SETDATA[5:0] <= TIME_SETDATA[5:0] - 10; else TIME_SETDATA[5:0] <= TIME_SETDATA[5:0] + 50;
							2: if (TIME_SETDATA[11:6] > 0) TIME_SETDATA[11:6] <= TIME_SETDATA[11:6] - 1; else TIME_SETDATA[11:6] <= 59;
							3: if (TIME_SETDATA[11:6] > 9) TIME_SETDATA[11:6] <= TIME_SETDATA[11:6] - 10; else TIME_SETDATA[11:6] <= TIME_SETDATA[11:6] + 50;
							4: if (TIME_SETDATA[17:12] > 0) TIME_SETDATA[17:12] <= TIME_SETDATA[17:12] - 1; else TIME_SETDATA[17:12] <= 23;
							5: begin
									if (TIME_SETDATA[17:12] > 9)
										TIME_SETDATA[17:12] <= TIME_SETDATA[17:12] - 10;
									else if (TIME_SETDATA[17:12] < 4)
										TIME_SETDATA[17:12] <= TIME_SETDATA[17:12] + 20;
									else
										TIME_SETDATA[17:12] <= TIME_SETDATA[17:12] + 10;
								end
							endcase
						end
					
					LEFT: begin
						if (cursor_position < 5)
							cursor_position <= cursor_position + 1;
						else
							cursor_position <= 0;
					end
					
					RIGHT: begin
						if (cursor_position > 0)
							cursor_position <= cursor_position - 1;
						else
							cursor_position <= 5;
					end
					
					CENTER: begin
						TIME_SET_FLAG <= 1'b1;
						time_data_loaded <= 1'b0;
					end
					
					default: TIME_SET_FLAG <= 1'b0;
				endcase
				
				buttons_prev <= BUTTONS;
			end
		end
	end

endmodule
