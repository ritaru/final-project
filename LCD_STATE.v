`timescale 1ns / 1ps

module LCD_STATE(
	input RESETN,
	input CLK,
	input [4:0] BUTTONS,
	input ALARM_STATE,
	output reg [3:0] STATE,
	output reg [1:0] MENU_STATE,
	output reg [31:0] CNT,
	output reg [4:0] CHAR_CNT,
	output reg ALARM_MENU_STATE
    );		 

	parameter INITIAL_DELAY = 4'b0000,
				 FUNCTION_SET = 4'b0001,
				 INITIAL_SETUP = 4'b0010,
				 CLEAR_SCREEN = 4'b0011,
				 SETUP = 4'b0100, // Menu select
				 TIME_SET = 4'b0101, // Time set
				 TZ_SET = 4'b0110, // Tinezone select
				 ALARM_SET = 4'b0111,
				 LINE1 = 4'b1000,
				 LINE2 = 4'b1001,
				 ALARM_TIME_REACHED = 4'b1010;
	
	reg [9:0] BUTTON_CNT;
	reg [4:0] BUTTONS_PREV;
	wire [4:0] BUTTONS_ONESHOT;
	
	assign BUTTONS_ONESHOT = (BUTTONS ^ BUTTONS_PREV) & BUTTONS;
	
	always @(negedge RESETN, posedge CLK) begin
		if (~RESETN) begin
			STATE <= INITIAL_DELAY;
			MENU_STATE <= 0;
			BUTTON_CNT <= 0;
			BUTTONS_PREV <= 0;
			ALARM_MENU_STATE <= 0;
		end else begin
			case(STATE)
				INITIAL_DELAY: if(CNT == 20) STATE <= FUNCTION_SET; // Wait for more than 15ms
				FUNCTION_SET: if(CNT == 5) STATE <= INITIAL_SETUP; // Wait for more than 5ms
				INITIAL_SETUP: if(CNT == 1) STATE <= CLEAR_SCREEN; // 1ms for each step is enough (Typ. 100us)
				CLEAR_SCREEN: if (CNT == 1) STATE <= LINE1;
				
				SETUP: begin
					case (BUTTONS_ONESHOT)
						5'b00100: begin
							case (MENU_STATE)
								2'b00: STATE <= TIME_SET;
								2'b01: STATE <= TZ_SET;
								2'b10: STATE <= ALARM_SET;
								2'b11: STATE <= LINE1;
							endcase
						end
						5'b10000: MENU_STATE <= MENU_STATE + 1;
						5'b01000: MENU_STATE <= MENU_STATE + 3;
					endcase
				end
				
				TIME_SET: if (BUTTONS_ONESHOT[2]) STATE <= LINE1;
				TZ_SET: if (BUTTONS_ONESHOT[2]) STATE <= LINE1;
				ALARM_SET: begin
					case (ALARM_MENU_STATE)
						0: if (BUTTONS_ONESHOT[2]) ALARM_MENU_STATE <= 1;
						1: begin
							if (BUTTONS_ONESHOT[2]) begin
								STATE <= LINE1;
								ALARM_MENU_STATE <= 0;
							end
						end
					endcase
				end

				LINE1: if (ALARM_STATE) STATE <= ALARM_TIME_REACHED; else if(CNT == 20) STATE <= LINE2;
				LINE2: if (ALARM_STATE) STATE <= ALARM_TIME_REACHED; else if(CNT == 20) STATE <= LINE1;

				ALARM_TIME_REACHED: if (BUTTONS_ONESHOT[2]) STATE <= LINE1;

				default: STATE <= INITIAL_DELAY;
			endcase
			
			if (STATE == LINE1 || STATE == LINE2) begin
				if (BUTTONS[2] && BUTTON_CNT < 1000)
					BUTTON_CNT <= BUTTON_CNT + 1;
				else if (BUTTON_CNT > 999) begin
					STATE <= SETUP;
					BUTTON_CNT <= 0;
				end
			end else
				BUTTON_CNT <= 0;

			BUTTONS_PREV <= BUTTONS;
		end
	end

	always @(negedge RESETN, posedge CLK) begin
		if (~RESETN) begin
			CNT <= 0;
			CHAR_CNT <= 0;
		end else begin
			case(STATE)
				INITIAL_DELAY: if(CNT >= 20) CNT <= 0; else CNT <= CNT + 1;
				FUNCTION_SET: if(CNT >= 5) CNT <= 0; else CNT <= CNT + 1;
				INITIAL_SETUP: if(CNT >= 1) CNT <= 0; else CNT <= CNT + 1;
				CLEAR_SCREEN: if(CNT >= 1) CNT <= 0; else CNT <= CNT + 1;
				LINE1: if(CNT >= 20) CNT <= 0; else CNT <= CNT + 1;
				LINE2: if(CNT >= 20) CNT <= 0; else CNT <= CNT + 1;
				default: CNT <= 0;
			endcase
			
			case(STATE)
				SETUP: if (CHAR_CNT >= 23) CHAR_CNT <= 0; else CHAR_CNT <= CHAR_CNT + 1;
				TZ_SET: if (CHAR_CNT >= 22) CHAR_CNT <= 0; else CHAR_CNT <= CHAR_CNT + 1;
				TIME_SET: if (CHAR_CNT >= 23) CHAR_CNT <= 0; else CHAR_CNT <= CHAR_CNT + 1;
				ALARM_SET: if (CHAR_CNT >= 23) CHAR_CNT <= 0; else CHAR_CNT <= CHAR_CNT + 1;
				default: CHAR_CNT <= 0;
			endcase
		end
	end


endmodule
