`timescale 1ns / 1ps

module UART_TB;
	
	reg CLK;
	reg CLK_1HZ;
	reg RESETN;
	wire TxClk;
	wire TxReady;
	wire TxTrigger;
	reg [31:0] MEM_DATA;
	reg [23:0] LOCAL_CLOCK_DATA;
	wire [7:0] DataOut;

	initial begin
		RESETN <= 0;
		CLK <= 0;
		CLK_1HZ <= 0;
		MEM_DATA <= {"K", "S", "T", " "};
		LOCAL_CLOCK_DATA <= {4'b0001, 4'b0010, 4'b0011, 4'b1001, 4'b0101, 4'b0001};
		#1000;
		RESETN <= 1;
	end
	
	always begin
		#500 CLK <= ~CLK; // 1MHz
	end
	
	always begin
		#500000000 CLK_1HZ <= ~CLK_1HZ; // 1Hz
	end

	UART_HANDLER uut (
		.CLK(CLK_1HZ),
		.TxClk(TxClk),
		.RESETN(RESETN),
		.CLOCK_DATA(LOCAL_CLOCK_DATA),
		.DataOut(DataOut),
		.MEM_DATA(MEM_DATA),
		.TxReady(TxReady),
		.TxTrigger(TxTrigger)
	);
		
	UART uart (
		.CLK(CLK),
		.RESETN(RESETN),
		.RxD(),
		.TxD(TxD),
		.DataOut(DataOut),
		.DataIn(),
		.TxReady(TxReady),
		.RxReady(),
		.TxClk(TxClk),
		.RxClk(),
		.TxTrigger(TxTrigger)
	);

endmodule
