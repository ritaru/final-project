`timescale 1ns / 1ps

module CLK_COUNTER(
	input RESETN,
	input CLK,
	input [3:0] STATE,
	input [17:0] TIME_SETDATA,
	input TIME_SET_FLAG,
	output wire [17:0] DATA
    );
	
	reg [4:0] hour;
	reg [5:0] min, sec;
	parameter INITIAL_DELAY = 4'b0000,
				 FUNCTION_SET = 4'b0001,
				 INITIAL_SETUP = 4'b0010,
				 CLEAR_SCREEN = 4'b0011,
				 SETUP = 4'b0100, // Menu select
				 TIME_SET = 4'b0101, // Time set
				 TZ_SET = 4'b0110, // Tinezone select
				 LINE1 = 4'b1000,
				 LINE2 = 4'b1001;
	
	// TODO: STATE�� ���� ����
	// TODO: Timezone�� Offset ����(STATE == TZ_SETUP�� ��� ���� Timezone Tracking)
	// TODO: ���� Count�� GMT ����, ǥ�ô� Timezone ����
	
	always @(negedge RESETN, posedge CLK) begin
		if (~RESETN) begin
			hour <= 15;
			min <= 0;
			sec <= 0;
		end else if (STATE != SETUP && STATE != TIME_SET) begin // TODO: TZ offset application
			if (sec < 59)
				sec <= sec + 1;
			else
				sec <= 0;
				
			if ((min < 59) && (sec == 59))
				min <= min + 1;
			else if ((min == 59) && (sec == 59))
				min <= 0;
			
			if ((hour < 23) && (min == 59) && (sec == 59))
				hour <= hour + 1;
			else if ((hour == 23) && (min == 59) && (sec == 59))
				hour <= 0;	
		end else if (STATE == TIME_SET) begin
			if (TIME_SET_FLAG) begin // Save time data in UTC
				hour <= TIME_SETDATA[17:12];
				min <= TIME_SETDATA[11:6];
				sec <= TIME_SETDATA[5:0];
			end
		end
	end
	
	assign DATA = {{1'b0, hour}, min, sec};

endmodule
