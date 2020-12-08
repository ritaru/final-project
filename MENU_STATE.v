`timescale 1ns / 1ps

module MENU_STATE(
	input RESETN,
	input CLK,
	input [3:0] STATE,
	output reg [4:0] CHAR_CNT,
	output reg [1:0] MENU_STATE
    );
		
	parameter INITIAL_DELAY = 4'b0000,
				 FUNCTION_SET = 4'b0001,
				 INITIAL_SETUP = 4'b0010,
				 CLEAR_SCREEN = 4'b0011,
				 SETUP = 4'b0100, // Menu select
				 TIME_SET = 4'b0101, // Time set
				 TZ_SET = 4'b0110, // Tinezone select
				 LINE1 = 4'b1000,
				 LINE2 = 4'b1001;
				 
	always @(negedge RESETN, posedge CLK) begin
		if (~RESETN)
			CHAR_CNT <= 0;
		else begin
			case (STATE)
				SETUP: if (CHAR_CNT >= 22) CHAR_CNT <= 0; else CHAR_CNT <= CHAR_CNT + 1;
				default: CHAR_CNT <= 0;
			endcase
		end
	end

	always @(negedge RESETN, posedge CLK) begin
		if (~RESETN)
			MENU_STATE <= 0;
		else begin
			if (STATE == SETUP)
				
		end
	end

endmodule
