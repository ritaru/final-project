`timescale 1ns / 1ps

module TIMEZONE_TB;

	// Inputs
	reg RESETN;
	reg CLK;
	reg [3:0] STATE;
	reg [3:0] BUTTONS;

	// Outputs
	wire [7:0] TZ_DATA;

	// Instantiate the Unit Under Test (UUT)
	TIMEZONE_SELECT uut (
		.RESETN(RESETN), 
		.CLK(CLK), 
		.STATE(STATE), 
		.BUTTONS(BUTTONS), 
		.TZ_DATA(TZ_DATA)
	);

	initial begin
		RESETN = 0;
		CLK = 0;
		STATE = 4'b0110;
		BUTTONS = 0;
		#10;
		RESETN = 1;
		#10;
		#10 BUTTONS <= 4'b1000;
		#10 BUTTONS <= 4'b0100;
		#10 BUTTONS <= 4'b0010;
		#10 BUTTONS <= 4'b0001;
	end
	
	always begin
		#1 CLK <= ~CLK;
	end
      
endmodule

