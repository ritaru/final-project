`timescale 1ns / 1ps

module CLK_OFFSET(
	input RESETN,
	input CLK,
	input [4:0] TZ_DATA,
	input [17:0] CLOCK_DATA,
	output wire [23:0] LOCAL_CLOCK_DATA
    );

	reg [5:0] hour, min, sec;
	
	// FIXME: fix parameters
	
	parameter AKST = 5'b00000,
				 AST = 5'b00001,
				 CET = 5'b00010,
				 CST = 5'b00011,
				 EST = 5'b00100,
				 GMT = 5'b00101,
				 HKT = 5'b00110,
				 HAST = 5'b00111,
				 JST = 5'b01000,
				 KST = 5'b01001,
				 MSK = 5'b01010,
				 MST = 5'b01011,
				 PDT = 5'b01100,
				 PST = 5'b01101,
				 VLAT = 5'b01110;
	
	always @(negedge RESETN, posedge CLK) begin
		if (~RESETN) begin
			hour <= 0;
			min <= 0;
			sec <= 0;
		end else begin
			case (TZ_DATA)
				AKST: begin // Alaska Standard Time
					hour <= CLOCK_DATA[17:12] - 9;
					min <= CLOCK_DATA[11:6];
					sec <= CLOCK_DATA[5:0];
				end
				
				AST: begin // Arabia Standard Time
					hour <= CLOCK_DATA[17:12] + 3;
					min <= CLOCK_DATA[11:6];
					sec <= CLOCK_DATA[5:0];
				end
				
				CET: begin // Central European Time
					hour <= CLOCK_DATA[17:12] + 1;
					min <= CLOCK_DATA[11:6];
					sec <= CLOCK_DATA[5:0];
				end
				
				CST: begin // China Standard Time
					hour <= CLOCK_DATA[17:12] - 5;
					min <= CLOCK_DATA[11:6];
					sec <= CLOCK_DATA[5:0];
				end
				
				EST: begin // Eastern Standard Time
					hour <= CLOCK_DATA[17:12] - 5;
					min <= CLOCK_DATA[11:6];
					sec <= CLOCK_DATA[5:0];
				end
				
				GMT: begin // Greenwich Mean Time
					hour <= CLOCK_DATA[17:12];
					min <= CLOCK_DATA[11:6];
					sec <= CLOCK_DATA[5:0];
				end
				
				HKT: begin // Hong Kong Time
					hour <= CLOCK_DATA[17:12] + 8;
					min <= CLOCK_DATA[11:6];
					sec <= CLOCK_DATA[5:0];
				end
				
				HAST: begin // Hawaii-Aleutian Standard Time
					hour <= CLOCK_DATA[17:12] - 10;
					min <= CLOCK_DATA[11:6];
					sec <= CLOCK_DATA[5:0];				
				end
				
				JST: begin // Japan Standard Time
					hour <= CLOCK_DATA[17:12] + 9;
					min <= CLOCK_DATA[11:6];
					sec <= CLOCK_DATA[5:0];				
				end
				
				KST: begin // Korea Standard Time
					hour <= CLOCK_DATA[17:12] + 9;
					min <= CLOCK_DATA[11:6];
					sec <= CLOCK_DATA[5:0];				
				end
				
				MSK: begin // Moscow Standard Time
					hour <= CLOCK_DATA[17:12] + 3;
					min <= CLOCK_DATA[11:6];
					sec <= CLOCK_DATA[5:0];			
				end
				
				MST: begin // Mountain Standard Time
					hour <= CLOCK_DATA[17:12] - 7;
					min <= CLOCK_DATA[11:6];
					sec <= CLOCK_DATA[5:0];
				end
				
				PST: begin // Pacific Standard Time
					hour <= CLOCK_DATA[17:12] - 8;
					min <= CLOCK_DATA[11:6];
					sec <= CLOCK_DATA[5:0];
				end
				
				VLAT: begin // Vladivostok Time
					hour <= CLOCK_DATA[17:12] + 10;
					min <= CLOCK_DATA[11:6];
					sec <= CLOCK_DATA[5:0];				
				end
				
				default: begin
					hour <= CLOCK_DATA[17:12];
					min <= CLOCK_DATA[11:6];
					sec <= CLOCK_DATA[5:0];
				end
			endcase
		end
	end
	
	SEP_DIGITS HOUR_SEP(hour, LOCAL_CLOCK_DATA[23:20], LOCAL_CLOCK_DATA[19:16]);
	SEP_DIGITS MIN_SEP(min, LOCAL_CLOCK_DATA[15:12], LOCAL_CLOCK_DATA[11:8]);
	SEP_DIGITS SEC_SEP(sec, LOCAL_CLOCK_DATA[7:4], LOCAL_CLOCK_DATA[3:0]);

endmodule
