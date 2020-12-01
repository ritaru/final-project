`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:28:14 12/01/2020
// Design Name:   TZ_ROM_32x32
// Module Name:   C:/Users/RiTA/Projects/final-project/TZ_ROM_TB.v
// Project Name:  Clock
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: TZ_ROM_32x32
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module TZ_ROM_TB;

	// Inputs
	reg clka;
	reg ena;
	reg regcea;
	reg [6:0] addra;

	// Outputs
	wire [31:0] douta;

	// Instantiate the Unit Under Test (UUT)
	TZ_ROM_32x32 uut (
		.clka(clka), 
		.ena(ena), 
		.regcea(regcea), 
		.addra(addra), 
		.douta(douta)
	);

	initial begin
		// Initialize Inputs
		clka = 0;
		ena = 0;
		regcea = 0;
		addra = 0;

		// Wait 100 ns for global reset to finish
		#100;
		
		ena = 1;
		regcea = 1;
		addra = 36;
        
		// Add stimulus here

	end
	
	always begin
		clka = ~clka;
	end
      
endmodule

