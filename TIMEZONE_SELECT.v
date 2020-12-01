`timescale 1ns / 1ps

module TIMEZONE_SELECT(
	input RESETN,
	input CLK,
	input [3:0] STATE,
	input [3:0] BUTTONS,
	output reg [4:0] TZ_DATA,
	output reg MEM_EN
    );
	
	parameter TZ_SET = 4'b0110,
				 UP = 4'b1000,
				 DOWN = 4'b0100,
				 LEFT = 4'b0010,
				 RIGHT = 4'b0001,
				 KST = 5'b01001;
	
	reg [3:0] BUTTONS_PREV;
	
	always @(negedge RESETN, posedge CLK) begin
		if (~RESETN) begin
			TZ_DATA <= KST; // Default KST
			BUTTONS_PREV <= 0;
			MEM_EN <= 1;
		end else begin
			if ((BUTTONS_PREV ^ BUTTONS) && BUTTONS) begin // Applied One-shot trigger
				case (BUTTONS_PREV ^ BUTTONS)
					UP: TZ_DATA <= TZ_DATA + 1;
					DOWN: TZ_DATA <= TZ_DATA - 1;
					LEFT: TZ_DATA <= TZ_DATA - 10;
					RIGHT: TZ_DATA <= TZ_DATA + 10;
				endcase
			end
			
			/*if (STATE == TZ_SET) begin
				MEM_EN <= 1;
				if ((BUTTONS_PREV ^ BUTTONS) && BUTTONS) begin // Applied One-shot trigger
					case (BUTTONS_PREV ^ BUTTONS)
						UP: TZ_DATA <= TZ_DATA + 1;
						DOWN: TZ_DATA <= TZ_DATA - 1;
						LEFT: TZ_DATA <= TZ_DATA - 10;
						RIGHT: TZ_DATA <= TZ_DATA + 10;
					endcase
				end
			end else
				MEM_EN <= 0;
				*/
			
			BUTTONS_PREV <= BUTTONS;
		end
	end

endmodule
