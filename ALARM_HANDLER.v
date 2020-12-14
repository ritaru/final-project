`timescale 1ns / 1ps

module ALARM_HANDLER(
  input RESETN,
  input CLK,
  input [3:0] STATE,
  output wire BUZZER
);

	parameter INITIAL_DELAY = 4'b0000,
				 FUNCTION_SET = 4'b0001,
				 INITIAL_SETUP = 4'b0010,
				 CLEAR_SCREEN = 4'b0011,
				 SETUP = 4'b0100, // Menu select
				 TIME_SET = 4'b0101, // Time set
				 TZ_SET = 4'b0110, // Tinezone select
				 ALARM_SET = 4'b0111,
				 LINE1 = 4'b1000,
				 LINE2 = 4'b1001,
				 ALARM_TIME_REACHED = 4'b1010;

	assign BUZZER = (STATE == ALARM_TIME_REACHED) & CLK;
endmodule
