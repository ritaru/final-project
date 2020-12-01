`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:58:00 11/27/2020
// Design Name:   SEP_DIGITS
// Module Name:   C:/Users/RiTA/Projects/Clock/SEP_TB.v
// Project Name:  Clock
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: SEP_DIGITS
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module SEP_TB;

	// Inputs
	reg [5:0] DATA;

	// Outputs
	wire [3:0] SEP_A;
	wire [3:0] SEP_B;

	// Instantiate the Unit Under Test (UUT)
	SEP_DIGITS uut (
		.DATA(DATA), 
		.SEP_A(SEP_A), 
		.SEP_B(SEP_B)
	);

	initial begin
		DATA = 0;
		#100;
      
		#10 DATA <= 11;
		#10 DATA <= 22;
		#10 DATA <= 33;
		#10 DATA <= 44;
		#10 DATA <= 55;
		#10 DATA <= 63;
		
	end
      
endmodule

