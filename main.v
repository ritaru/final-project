`timescale 1ns / 1ps

module main(
	input RESETN,
	input CLK,
	input CLK_1HZ,
	input [4:0] BUTTONS,
	output wire LCD_EN,
	output wire LCD_RS,
	output wire LCD_RW,
	output wire [7:0] LCD_DATA
);

	// LCD related signals
	wire [3:0] STATE;
	wire [31:0] LCD_CNT; // TODO: Optimize bit size
	wire [3:0] CHAR_CNT;
	assign LCD_EN = CLK;
	
	// Clock related signals
	wire [23:0] LOCAL_CLOCK_DATA; // BCD Coded HHMMSS data - 4 Bits * 6 = 3 Bytes(1 Byte per two digits)
	// wire [17:0] ALARM_TIME; // 6 Bits per HH,MM,SS
	wire [17:0] TIME_SETDATA, CLOCK_DATA; // 6 Bits per HH,MM,SS
	wire [4:0] TZ_DATA; // Timezone state
	wire TIME_SET_FLAG;
	
	// Memory related signals
	wire MEM_EN, MEM_OUT_EN;
	wire [31:0] MEM_DATA;
	
	assign MEM_OUT_EN = 1; // FIXME: Implement Timezone Memory Output register EN signal generation
	
	// Block memory
	TZ_ROM_32x32 tz_string (.clka(CLK),
										.ena(MEM_EN),
										.regcea(MEM_OUT_EN),
										.addra(TZ_DATA),
										.douta(MEM_DATA)
									 ); // 32 x 32 ROM
	
	// LCD Driver Modules
	LCD_STATE state_timer(RESETN, CLK, BUTTONS[2], STATE, LCD_CNT, CHAR_CNT); // FIXME: fix menu entry error
	LCD_ACTION action_description(RESETN, CLK, STATE, LCD_CNT, CHAR_CNT, LOCAL_CLOCK_DATA, MEM_DATA, LCD_RS, LCD_RW, LCD_DATA);
	
	// Clock related modules
	CLK_COUNTER clock_rtc(RESETN, CLK_1HZ, STATE, TIME_SETDATA, TIME_SET_FLAG, CLOCK_DATA);
	TIMEZONE_SELECT clock_tz(RESETN, CLK, STATE, {BUTTONS[4:3], BUTTONS[1:0]}, TZ_DATA, MEM_EN);
	CLK_OFFSET clock_offset(RESETN, CLK, STATE, TZ_DATA, CLOCK_DATA, TIME_SETDATA, LOCAL_CLOCK_DATA);
	//ALARM_SET clock_alarm(RESETN, CLK, STATE, BUTTONS, ALARM_TIME, ALARM_FLAG); // FIXME: Needs alarm memory separately(to store alarm bells, alarm time)
	TIME_SET clock_setup(RESETN, CLK, STATE, BUTTONS, CLOCK_DATA, TIME_SETDATA, TIME_SET_FLAG);

endmodule
