`timescale 1ns / 1ps

module ALARM_HANDLER(
  input RESETN,
  input CLK,
  input CLK_1M,
  input [3:0] STATE,
  input [17:0] RTC_DATA,
  input [17:0] ALARM_TIME,
  input ALARM_FLAG,
  output reg ALARM_TIME_UP,
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
	
	reg [8:0] CNT;
	reg CLK_3K;
	reg OUT_EN;
	
	always @(negedge RESETN, posedge CLK) begin
		if (~RESETN)
			ALARM_TIME_UP <= 0;
		else begin
			if (ALARM_FLAG && (RTC_DATA == ALARM_TIME))
				ALARM_TIME_UP <= 1;
			else
				ALARM_TIME_UP <= 0;
		end
	end
	
	always @(negedge RESETN, posedge CLK_1M) begin
		if (~RESETN) begin
			CNT <= 0;
			CLK_3K <= 0;
		end else begin
			if (CNT < 165)
				CNT <= CNT + 1;
			else begin
				CNT <= 0;
				CLK_3K <= ~CLK_3K;
			end
		end
	end
	
	reg [11:0] SOS_CNT;
	
	always @(negedge RESETN, posedge CLK) begin
		if (~RESETN)
			SOS_CNT <= 0;
		else begin
			SOS_CNT <= SOS_CNT < 2499 ? SOS_CNT + 1 : 0;
		end
	end
	
	always @(negedge RESETN, posedge CLK) begin
		if (~RESETN)
			OUT_EN <= 0; // Active High
		else if (STATE == ALARM_TIME_REACHED) begin
			if (SOS_CNT < 99) begin
				OUT_EN <= 1; // Short Signal
			end else if (SOS_CNT < 199)
				OUT_EN <= 0;
			else if (SOS_CNT < 299)
				OUT_EN <= 1;
			else if (SOS_CNT < 399)
				OUT_EN <= 0;
			else if (SOS_CNT < 499)
				OUT_EN <= 1;
			else if (SOS_CNT < 599)
				OUT_EN <= 0;
			else if (SOS_CNT < 799)
				OUT_EN <= 1; // Long signal
			else if (SOS_CNT < 899)
				OUT_EN <= 0;
			else if (SOS_CNT < 1099)
				OUT_EN <= 1;
			else if (SOS_CNT < 1199)
				OUT_EN <= 0;
			else if (SOS_CNT < 1399)
				OUT_EN <= 1;
			else if (SOS_CNT < 1499)
				OUT_EN <= 0;
			else if (SOS_CNT < 1599)
				OUT_EN <= 1; // Short signal
			else if (SOS_CNT < 1699)
				OUT_EN <= 0;
			else if (SOS_CNT < 1799)
				OUT_EN <= 1;
			else if (SOS_CNT < 1899)
				OUT_EN <= 0;
			else if (SOS_CNT < 1999)
				OUT_EN <= 1;
			else if (SOS_CNT < 2499)
				OUT_EN <= 0;
		end else
			OUT_EN <= 0;
	end
	
	assign BUZZER = OUT_EN & CLK_3K;
endmodule
