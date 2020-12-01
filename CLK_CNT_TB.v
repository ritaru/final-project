`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:00:02 11/27/2020
// Design Name:   CLK_COUNTER
// Module Name:   C:/Users/RiTA/Projects/Clock/CLK_CNT_TB.v
// Project Name:  Clock
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: CLK_COUNTER
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module CLK_CNT_TB;

	// Inputs
	reg RESETN;
	reg CLK;
	reg [3:0] STATE;
	reg [6:0] TZ_DATA;

	// Outputs
	wire [23:0] DATA;

	// Instantiate the Unit Under Test (UUT)
	CLK_COUNTER uut (
		.RESETN(RESETN), 
		.CLK(CLK), 
		.STATE(STATE), 
		.TZ_DATA(TZ_DATA), 
		.DATA(DATA)
	);

	initial begin
		RESETN = 0;
		CLK = 0;
		STATE = 0;
		TZ_DATA = 114;
		#100;
		RESETN = 1;
	end
	
	always begin
	#1 CLK <= ~CLK;
	end
      
endmodule

