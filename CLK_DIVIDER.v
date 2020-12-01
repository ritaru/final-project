`timescale 1ns / 1ps

module CLK_DIVIDER(
	input RESETN,
	input CLK,
	input [4:0] CLK_DIVISOR,
	output reg CLK_OUT
    );

	integer CNT;
	
	always @(negedge RESETN, posedge CLK) begin
		if (~RESETN) begin
			CNT <= 0;
			CLK_OUT <= 0;
		end else if (CNT > (CLK_DIVISOR >> 2 - 1)) begin
			CNT <= 0;
			CLK_OUT <= ~CLK_OUT;
		end else
			CNT <= CNT + 1;
	end

endmodule
