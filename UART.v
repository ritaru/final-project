`timescale 1ns / 1ps

module UART(
	input CLK,
	input RESETN,
	input [7:0] DataOut,
	output wire [7:0] DataIn,
	output wire TxD,
	input RxD,
	output wire TxReady,
	output wire RxReady,
	output wire TxClk,
	output wire RxClk,
	input TxTrigger
    );
	
	Tx tx(.CLK(TxClk), .RESETN(RESETN), .DataOut(DataOut), .TxD(TxD), .TxReady(TxReady), .TxTrigger(TxTrigger));
	//Rx rx(.CLK(RxClk), .RESETN(RESETN), .DataIn(DataIn), .RxD(RxD), .RxReady(RxReady));
	
	ClkDiv clkgen(.CLK(CLK), .RESETN(RESETN), .TxClk(TxClk), .RxClk(RxClk));
endmodule
