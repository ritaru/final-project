`timescale 1ns / 1ps


module TIME_SET_TB;

  reg CLK;
  reg CLK_1HZ;
  reg RESETN;
  reg [3:0] STATE;
  reg [4:0] BUTTONS;
  wire [17:0] RTC_DATA;
  wire [17:0] TIME_SETDATA;
  wire TIME_SET_FLAG;

  parameter UP = 5'b10000,
            DOWN = 5'b01000,
            LEFT = 5'b00010,
            RIGHT = 5'b00001,
            CENTER = 5'b00100;

  initial begin
    RESETN <= 0;
    CLK <= 0;
    CLK_1HZ <= 0;
    STATE <= 4'b1000;
    BUTTONS <= 0;

    #5000000 RESETN <= 1;
    #1000000 STATE <= 4'b0101;
    #2000000;
    #2000000 BUTTONS <= LEFT;
    #1000000 BUTTONS <= 0;
    #2000000 BUTTONS <= LEFT;
    #1000000 BUTTONS <= 0;
    #2000000 BUTTONS <= LEFT;
    #1000000 BUTTONS <= 0;
    #2000000 BUTTONS <= UP;
    #1000000 BUTTONS <= 0;
    #2000000 BUTTONS <= UP;
    #1000000 BUTTONS <= 0;
    #2000000 BUTTONS <= CENTER;
    #1000000 BUTTONS <= 0;
    STATE <= 4'b1000;
  end

  always begin
    #500000 CLK <= ~CLK;
  end

  always begin
    #500000000 CLK_1HZ <= ~CLK_1HZ;
  end

  TIME_SET clock_setup (
    .RESETN(RESETN),
    .CLK(CLK),
    .STATE(STATE),
    .BUTTONS(BUTTONS),
    .CLOCK_DATA(RTC_DATA),
    .TIME_SETDATA(TIME_SETDATA),
    .TIME_SET_FLAG(TIME_SET_FLAG)
  );

  CLK_COUNTER uut (
    .RESETN(RESETN),
    .CLK(CLK_1HZ),
    .TIME_SETDATA(TIME_SETDATA),
    .TIME_SET_FLAG(TIME_SET_FLAG),
    .DATA(RTC_DATA)
  );

endmodule
