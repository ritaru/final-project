`timescale 1ns / 1ps

module CLK_OFFSET(
	input RESETN,
	input CLK,
	input [4:0] TZ_DATA,
	input [17:0] CLOCK_DATA,
	output wire [23:0] LOCAL_CLOCK_DATA
    );

	reg [5:0] hour, min, sec;
	reg [5:0] offset_hour, offset_min;
	reg offset_dir;
	
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
				 PST = 5'b01100,
				 VLAT = 5'b01101;
	
	always @(negedge RESETN, posedge CLK) begin
		if (~RESETN) begin
			hour <= 0;
			min <= 0;
			sec <= 0;
			offset_dir <= 0;
			offset_hour <= 0;
			offset_min <= 0;
		end else begin
			case (TZ_DATA)
				AKST: begin // Alaska Standard Time
					offset_hour <= 9;
					offset_dir <= 0;
				end
				
				AST: begin // Arabia Standard Time
					offset_hour <= 3;
					offset_dir <= 1;
				end
				
				CET: begin // Central European Time
					offset_hour <= 1;
					offset_dir <= 1;
				end
				
				CST: begin // China Standard Time
					offset_hour <= 8;
					offset_dir <= 1;
				end
				
				EST: begin // Eastern Standard Time
					offset_hour <= 5;
					offset_dir <= 0;
				end
				
				GMT: begin
					offset_hour <= 0;
					offset_dir <= 1;
				end
				
				HKT: begin // Hong Kong Time
					offset_hour <= 8;
					offset_dir <= 1;
				end
				
				HAST: begin // Hawaii-Aleutian Standard Time
					offset_hour <= 10;
					offset_dir <= 0;
				end
				
				JST: begin // Japan Standard Time
					offset_hour <= 9;
					offset_dir <= 1;
				end
				
				KST: begin // Korea Standard Time
					offset_hour <= 9;
					offset_dir <= 1;
				end
				
				MSK: begin // Moscow Standard Time
					offset_hour <= 3;
					offset_dir <= 1;
				end
				
				MST: begin // Mountain Standard Time
					offset_hour <= 7;
					offset_dir <= 0;
				end
				
				PST: begin // Pacific Standard Time
					offset_hour <= 8;
					offset_dir <= 0;
				end
				
				VLAT: begin // Vladivostok Time
					offset_hour <= 10;
					offset_dir <= 1;
				end
				
				default: begin
					hour <= CLOCK_DATA[17:12];
					min <= CLOCK_DATA[11:6];
					sec <= CLOCK_DATA[5:0];
				end
			endcase
			
			if (offset_dir == 1) begin
				if (CLOCK_DATA[17:12] < (24 - offset_hour))
					hour <= CLOCK_DATA[17:12] + offset_hour;
				else
					hour <= CLOCK_DATA[17:12] - (24 - offset_hour);
			end else begin
				if (CLOCK_DATA[17:12] < offset_hour)
					hour <= 24 - (offset_hour - CLOCK_DATA[17:12]);
				else
					hour <= CLOCK_DATA[17:12] - offset_hour;
			end
			
			min <= CLOCK_DATA[11:6];
			sec <= CLOCK_DATA[5:0];
		end
	end
	
	SEP_DIGITS HOUR_SEP(hour, LOCAL_CLOCK_DATA[23:20], LOCAL_CLOCK_DATA[19:16]);
	SEP_DIGITS MIN_SEP(min, LOCAL_CLOCK_DATA[15:12], LOCAL_CLOCK_DATA[11:8]);
	SEP_DIGITS SEC_SEP(sec, LOCAL_CLOCK_DATA[7:4], LOCAL_CLOCK_DATA[3:0]);

endmodule
