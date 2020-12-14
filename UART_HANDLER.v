`timescale 1ns / 1ps

module UART_HANDLER(
	input CLK,
	input RESETN,
	input TxClk,
	input TxReady,
	input [31:0] MEM_DATA,
	input [23:0] CLOCK_DATA,
	output reg [7:0] DataOut,
	output reg TxTrigger
    );

	reg trigger_prev;
	wire [7:0] TxBuffer [13:0];
	reg [3:0] TxPointer;
	
	assign TxBuffer[0] = MEM_DATA[31:24]; // K
	assign TxBuffer[1] = MEM_DATA[23:16]; // S
	assign TxBuffer[2] = MEM_DATA[15:8]; // T
	assign TxBuffer[3] = MEM_DATA[7:0]; // " "
	assign TxBuffer[4] = " ";
	assign TxBuffer[5] = {4'b0000, CLOCK_DATA[23:20]} | 8'b00110000; // 1
	assign TxBuffer[6] = {4'b0000, CLOCK_DATA[19:16]} | 8'b00110000; // 6
	assign TxBuffer[7] = ":";
	assign TxBuffer[8] = {4'b0000, CLOCK_DATA[15:12]} | 8'b00110000; // 0
	assign TxBuffer[9] = {4'b0000, CLOCK_DATA[11:8]} | 8'b00110000; // 3
	assign TxBuffer[10] = ":";
	assign TxBuffer[11] = {4'b0000, CLOCK_DATA[7:4]} | 8'b00110000; // 2
	assign TxBuffer[12] = {4'b0000, CLOCK_DATA[3:0]} | 8'b00110000; // 8
	assign TxBuffer[13] = 13; // "<CR>"
	
	always @(negedge RESETN, posedge TxClk) begin
		if (~RESETN) begin
			TxPointer <= 0;
			TxTrigger <= 0;
			trigger_prev <= 0;
			DataOut <= 0;
		end else begin
			if (CLK) begin
				if (~trigger_prev) begin
					trigger_prev <= 1;
					TxTrigger <= 1;
					DataOut <= TxBuffer[TxPointer];
				end else
					TxTrigger <= 0;
					
				if ((trigger_prev & TxReady) && TxPointer < 13) begin
					trigger_prev <= 0;
					TxPointer <= TxPointer + 1;
				end
			end else begin
				trigger_prev <= 0;
				TxPointer <= 0;
			end
			
		end
	end

endmodule
