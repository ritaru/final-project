`timescale 1ns / 1ps

module main(
	input RESETN,
	input CLK,
	input CLK_1HZ,
	input CLK_1M,
	input [4:0] BUTTONS,
	output wire LCD_EN,
	output wire LCD_RS,
	output wire LCD_RW,
	output wire [7:0] LCD_DATA,
	output wire BUZZER,
	output wire TxD
);

	// LCD related signals
	wire [3:0] STATE;
	wire [1:0] MENU_STATE;
	wire [31:0] LCD_CNT;
	wire [4:0] CHAR_CNT;
	assign LCD_EN = CLK;
	
	// Clock related signals
	reg [17:0] CLOCK_DATA;
	wire [23:0] LOCAL_CLOCK_DATA; // BCD Coded HHMMSS data - 4 Bits * 6 = 3 Bytes(1 Byte per two digits)
	wire [17:0]	RTC_DATA; // 6 Bits per HH,MM,SS
	wire TIME_SET_FLAG;
	
	// Additional Feature signals
	wire [4:0] TZ_DATA; // Timezone state
	wire [17:0] TIME_SETDATA; // 6 Bits per HH,MM,SS
	wire [17:0] ALARM_TIME; // 6 Bits per HH,MM,SS
	wire ALARM_FLAG;
	wire ALARM_TIME_IS_SET;
	reg ALARM_TIME_UP;
	
	// Memory related signals
	wire MEM_EN, MEM_OUT_EN;
	wire [31:0] MEM_DATA;
	
	assign MEM_OUT_EN = 1; // FIXME: Implement Timezone Memory Output register EN signal generation
	
	parameter ALARM_SET = 4'b0111,
				 TIME_SET = 4'b0101;
	
	always @(negedge RESETN, posedge CLK) begin // 3:1 Mux for Time BCD Data Generation
		if (~RESETN)
			CLOCK_DATA <= 0;
		else begin
			case (STATE)
				ALARM_SET: CLOCK_DATA <= ALARM_TIME;
				TIME_SET: CLOCK_DATA <= TIME_SETDATA;
				default: CLOCK_DATA <= RTC_DATA;
			endcase
		end
	end

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
	
	// Block memory
	TZ_ROM_32x32 tz_string (.clka(CLK),
										.ena(MEM_EN),
										.regcea(MEM_OUT_EN),
										.addra(TZ_DATA),
										.douta(MEM_DATA)
									 ); // 32 x 32 ROM
	
	// LCD Driver Modules
	LCD_STATE state_timer(
		.RESETN(RESETN),
		.CLK(CLK),
		.BUTTONS(BUTTONS),
		.STATE(STATE),
		.ALARM_STATE(ALARM_TIME_UP),
		.ALARM_MENU_STATE(ALARM_TIME_IS_SET),
		.MENU_STATE(MENU_STATE),
		.CNT(LCD_CNT),
		.CHAR_CNT(CHAR_CNT)
		);

	LCD_ACTION action_description(
		.RESETN(RESETN),
		.CLK(CLK),
		.STATE(STATE),
		.MENU_STATE(MENU_STATE),
		.CNT(LCD_CNT),
		.CHAR_CNT(CHAR_CNT),
		.CLOCK_DATA(LOCAL_CLOCK_DATA),
		.MEM_DATA(MEM_DATA),
		.LCD_RS(LCD_RS),
		.LCD_RW(LCD_RW),
		.LCD_DATA(LCD_DATA),
		.ALARM_FLAG(ALARM_FLAG)
		);
	
	// Clock related modules
	CLK_COUNTER clock_rtc(
		.RESETN(RESETN),
		.CLK(CLK_1HZ),
		.TIME_SETDATA(TIME_SETDATA),
		.TIME_SET_FLAG(TIME_SET_FLAG),
		.DATA(RTC_DATA)
		);
	
	// Additional features
	TIMEZONE_SELECT clock_tz(
		.RESETN(RESETN),
		.CLK(CLK),
		.STATE(STATE),
		.BUTTONS({BUTTONS[4:3], BUTTONS[1:0]}),
		.TZ_DATA(TZ_DATA),
		.MEM_EN(MEM_EN)
		);
	
	CLK_OFFSET clock_offset(
		.RESETN(RESETN),
		.CLK(CLK),
		.STATE(STATE),
		.TZ_DATA(TZ_DATA),
		.CLOCK_DATA(CLOCK_DATA),
		.LOCAL_CLOCK_DATA(LOCAL_CLOCK_DATA)
		);

	ALARM_SET clock_alarm( 
		.RESETN(RESETN),
		.CLK(CLK),
		.STATE(STATE),
		.BUTTONS(BUTTONS),
		.RTC_DATA(RTC_DATA),
		.ALARM_TIME_SET(ALARM_TIME_IS_SET),
		.ALARM_SET_DATA(ALARM_TIME),
		.ALARM_SET_FLAG(ALARM_FLAG)
		); 

	ALARM_HANDLER alarm_handler(
		.RESETN(RESETN),
		.CLK(CLK),
		.STATE(STATE),
		.BUZZER(BUZZER)
	);

	TIME_SET clock_setup(
		.RESETN(RESETN),
		.CLK(CLK),
		.STATE(STATE),
		.BUTTONS(BUTTONS),
		.CLOCK_DATA(RTC_DATA),
		.TIME_SETDATA(TIME_SETDATA),
		.TIME_SET_FLAG(TIME_SET_FLAG)
		);
	
	wire TxClk;
	wire TxTrigger;
	wire TxReady;
	wire [7:0] DataOut;
	wire [23:0] UART_RTC;
	
	CLK_OFFSET rtc_offset (
		.RESETN(RESETN),
		.CLK(CLK),
		.STATE(STATE),
		.TZ_DATA(TZ_DATA),
		.CLOCK_DATA(RTC_DATA),
		.LOCAL_CLOCK_DATA(UART_RTC)
	);
	
	UART_HANDLER uart_manager (
		.CLK(CLK_1HZ),
		.TxClk(TxClk),
		.RESETN(RESETN),
		.CLOCK_DATA(UART_RTC),
		.DataOut(DataOut),
		.MEM_DATA(MEM_DATA),
		.TxReady(TxReady),
		.TxTrigger(TxTrigger)
	);
	
	UART uart (
		.CLK(CLK_1M),
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
