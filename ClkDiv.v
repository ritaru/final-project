`timescale 1ns / 1ps

module ClkDiv(
	input CLK,
	input RESETN,
	output reg TxClk,
	output reg RxClk
    );
	
	reg [5:0] TxCNT;
	reg [2:0] RxCNT;
	
	// 9.6154KHz Clock for 9600bps
	always @(negedge RESETN, posedge CLK) begin
		if (~RESETN) begin
			TxClk <= 0;
			TxCNT <= 0;
		end else begin
			if (TxCNT < 51)
				TxCNT <= TxCNT + 1;
			else begin
				TxCNT <= 0;
				TxClk <= ~TxClk;
			end
		end
	end
	
	// 125KHz Clock ~= 13 * 9.6KHz = 124.8KHz (Non-standard)
	always @(negedge RESETN, posedge CLK) begin
		if (~RESETN) begin
			RxClk <= 0;
			RxCNT <= 0;
		end else begin
			RxCNT <= RxCNT + 1;
			if (RxCNT == 0)
				RxClk <= ~RxClk;
		end
	end

endmodule
