`timescale 1ns / 1ps

module TIMEZONE_SELECT(
	input RESETN,
	input CLK,
	input [3:0] STATE,
	input [3:0] BUTTONS,
	output reg [3:0] TZ_DATA,
	output reg MEM_EN
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
				 
	parameter UP = 4'b1000,
				 DOWN = 4'b0100,
				 LEFT = 4'b0010,
				 RIGHT = 4'b0001;
				 
	parameter KST = 4'b1010;
	
	reg [3:0] BUTTONS_PREV;
	
	always @(negedge RESETN, posedge CLK) begin
		if (~RESETN) begin
			TZ_DATA <= KST; // Default KST
			BUTTONS_PREV <= 0;
			MEM_EN <= 1;
		end else begin
			if (STATE == TZ_SET) begin
				MEM_EN <= 1;
				if ((BUTTONS_PREV ^ BUTTONS) && BUTTONS) begin // Applied One-shot trigger
					case (BUTTONS_PREV ^ BUTTONS)
						UP: TZ_DATA <= TZ_DATA + 1;
						DOWN: TZ_DATA <= TZ_DATA - 1;
					endcase
				end
			end else
				MEM_EN <= 0;
			
			BUTTONS_PREV <= BUTTONS;
		end
	end

endmodule
