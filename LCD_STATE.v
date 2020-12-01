`timescale 1ns / 1ps

module LCD_STATE(
	input RESETN,
	input CLK,
	input CENTER_BUTTON,
	output reg [3:0] STATE,
	output reg [31:0] CNT
    );		 

	parameter INITIAL_DELAY = 4'b0000,
				 FUNCTION_SET = 4'b0001,
				 INITIAL_SETUP = 4'b0010,
				 SETUP = 4'b0100, // Menu select
				 TIME_SET = 4'b0101, // Time set
				 TZ_SET = 4'b0110, // Tinezone select
				 LINE1 = 4'b1000,
				 LINE2 = 4'b1001;

	reg [9:0] BUTTON_CNT;
	
	always @(negedge RESETN, posedge CLK) begin
		if (~RESETN) begin
			STATE <= INITIAL_DELAY;
			BUTTON_CNT <= 0;
		end else begin
			case(STATE)
				INITIAL_DELAY: if(CNT == 20) STATE <= FUNCTION_SET; // Wait for more than 15ms
				FUNCTION_SET: if(CNT == 5) STATE <= INITIAL_SETUP; // Wait for more than 5ms
				INITIAL_SETUP: if(CNT == 1) STATE <= LINE1; // 1ms for each step is enough (Typ. 100us)
				SETUP: if(CNT == 1000) STATE <= LINE1;
				LINE1: if(CNT == 20) STATE <= LINE2;
				LINE2: if(CNT == 20) STATE <= LINE1;
				default: STATE <= INITIAL_DELAY;
			endcase
			
			if (CENTER_BUTTON)
				BUTTON_CNT <= BUTTON_CNT + 1;
			else if (BUTTON_CNT > 999) begin
				if (STATE != SETUP) begin
					STATE <= SETUP;
					BUTTON_CNT <= 0;
				end
			end else
			BUTTON_CNT <= 0;
		end
	end

	always @(negedge RESETN, posedge CLK) begin
		if (~RESETN)
			CNT <= 0;
		else begin
			case(STATE)
				INITIAL_DELAY: if(CNT >= 20) CNT <= 0; else CNT <= CNT + 1;
				FUNCTION_SET: if(CNT >= 5) CNT <= 0; else CNT <= CNT + 1;
				INITIAL_SETUP: if(CNT >= 1) CNT <= 0; else CNT <= CNT + 1;
				SETUP: if(CNT >= 1000) CNT <= 0; else CNT <= CNT + 1;
				LINE1: if(CNT >= 20) CNT <= 0; else CNT <= CNT + 1;
				LINE2: if(CNT >= 20) CNT <= 0; else CNT <= CNT + 1;
				default: CNT <= 0;
			endcase
			
			if (STATE == SETUP) begin
				if (CENTER_BUTTON)
					CNT <= 0; // reset counter to zero if any button input applied
			end
		end
	end


endmodule
