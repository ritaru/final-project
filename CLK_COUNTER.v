`timescale 1ns / 1ps

module CLK_COUNTER(
	input RESETN,
	input CLK,
	input [3:0] STATE,
	output wire [17:0] DATA
    );
	
	reg [5:0] hour, min, sec;
	
	// TODO: STATE별 구분 동작
	// TODO: Timezone별 Offset 적용(STATE == TZ_SETUP인 경우 현재 Timezone Tracking)
	// TODO: 실제 Count는 GMT 기준, 표시는 Timezone 기준
	
	always @(negedge RESETN, posedge CLK) begin
		if (~RESETN) begin
			hour <= 15;
			min <= 0;
			sec <= 0;
		end else begin // TODO: TZ offset application
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
		end
	end
	
	assign DATA = {hour, min, sec};

endmodule
