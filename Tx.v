`timescale 1ns / 1ps

module Tx(
	input CLK,
	input RESETN,
	input [7:0] DataOut,
	input TxTrigger,
	output reg TxD,
	output reg TxReady
    );

	reg [7:0] TxBuffer;
	reg [3:0] TxCNT;
	
	always @(negedge RESETN, posedge CLK) begin
		if (~RESETN) 
			TxCNT <= 0;
		else begin
			if (~TxReady) begin
				if (TxCNT < 10)
					TxCNT <= TxCNT + 1;
			end else
				TxCNT <= 0;
		end
	end
	
	always @(negedge RESETN, posedge CLK) begin
		if (~RESETN) begin
			TxBuffer <= 0;
			TxD <= 1;
		end else begin
			if (~TxReady) begin
				case (TxCNT)
					0: begin
						TxD <= 0;
						TxBuffer <= DataOut;
					end
					
					1: TxD <= TxBuffer[0];
					2: TxD <= TxBuffer[1];
					3: TxD <= TxBuffer[2];
					4: TxD <= TxBuffer[3];
					5: TxD <= TxBuffer[4];
					6: TxD <= TxBuffer[5];
					7: TxD <= TxBuffer[6];
					8: TxD <= TxBuffer[7];
					10: TxBuffer <= 0;
					
					default: TxD <= 1;
				endcase
			end
		end
	end
	
	always @(negedge RESETN, posedge CLK, posedge TxTrigger) begin
		if (~RESETN)
			TxReady <= 1;
		else begin
			if (TxTrigger)
				TxReady <= 0;
			else if (TxCNT == 10)
				TxReady <= 1;
		end
	end

endmodule
