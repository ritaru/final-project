`timescale 1ns / 1ps

module SEP_DIGITS(
	input [5:0] DATA,
	output reg [3:0] SEP_A,
	output reg [3:0] SEP_B
    );

	always @(DATA) begin
		if (DATA < 10) begin
			SEP_A <= 0;
			SEP_B <= DATA[3:0];
		end else if (DATA < 20) begin
			SEP_A <= 1;
			SEP_B <= DATA - 10;
		end else if (DATA < 30) begin
			SEP_A <= 2;
			SEP_B <= DATA - 20;
		end else if (DATA < 40) begin
			SEP_A <= 3;
			SEP_B <= DATA - 30;
		end else if (DATA < 50) begin
			SEP_A <= 4;
			SEP_B <= DATA - 40;
		end else if (DATA < 60) begin
			SEP_A <= 5;
			SEP_B <= DATA - 50;
		end else begin
			SEP_A <= 6;
			SEP_B <= DATA - 60;
		end
	end

endmodule
