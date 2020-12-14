`timescale 1ns / 1ps

module Rx(
	input CLK,
	input RESETN,
	input RxD,
	output reg [7:0] DataIn,
	output reg RxReady
    );
	 
	reg [7:0] RxBuffer;
	reg [2:0] RxBufferPointer;
	reg [3:0] RxCNT;

endmodule
