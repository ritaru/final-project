`timescale 1ns / 1ps

module CLK_OFFSET(
	input RESETN,
	input CLK,
	input [3:0] STATE,
	input [3:0] TZ_DATA,
	input [17:0] CLOCK_DATA,
	output wire [23:0] LOCAL_CLOCK_DATA
    );

	reg [5:0] hour, min, sec;
	reg [3:0] offset_hour;
	// reg [5:0] offset_min; // Trimmed off any excess signals, but can implement later
	reg offset_dir;
	
	parameter AKST = 4'b0000,
				 AST = 4'b0001,
				 CET = 4'b0010,
				 CST = 4'b0011,
				 EET = 4'b0100,
				 EST = 4'b0101,
				 GMT = 4'b0110,
				 HKT = 4'b0111,
				 HAST = 4'b1000,
				 JST = 4'b1001,
				 KST = 4'b1010,
				 MSK = 4'b1011,
				 MST = 4'b1100,
				 PST = 4'b1101,
				 VLAT = 4'b1110,
				 WST = 4'b1111;
				 
	parameter INITIAL_DELAY = 4'b0000,
				 FUNCTION_SET = 4'b0001,
				 INITIAL_SETUP = 4'b0010,
				 CLEAR_SCREEN = 4'b0011,
				 SETUP = 4'b0100, // Menu select
				 TIME_SET = 4'b0101, // Time set
				 TZ_SET = 4'b0110, // Tinezone select
				 LINE1 = 4'b1000,
				 LINE2 = 4'b1001;
	
	always @(negedge RESETN, posedge CLK) begin
		if (~RESETN) begin
			offset_dir <= 0;
			offset_hour <= 0;
			// offset_min <= 0;
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
				
				EET: begin // Eastern Europe Time
					offset_hour <= 2;
					offset_dir <= 1;
				end
				
				EST: begin // Eastern Standard Time
					offset_hour <= 5;
					offset_dir <= 0;
				end
				
				GMT: begin // Greenwich Mean Time
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
				
				WST: begin // Western Standard Time
					offset_hour <= 8;
					offset_dir <= 1;
				end
				
				default: begin
					offset_hour <= 0;
					offset_dir <= 1;
				end
			endcase
		end
	end
	
	always @(negedge RESETN, posedge CLK) begin // Offset is always applied to time data.	
		if (~RESETN) begin
			hour <= 0;
			min <= 0;
			sec <= 0;
		end else begin
			if (offset_dir == 1) begin // Offset handling section
					if (CLOCK_DATA[17:12] < (24 - offset_hour))
						hour <= CLOCK_DATA[17:12] + {2'b0, offset_hour};
					else
						hour <= CLOCK_DATA[17:12] - (24 - {2'b0, offset_hour});
				end else begin
					if (CLOCK_DATA[17:12] < offset_hour)
						hour <= 24 - ({2'b0, offset_hour} - CLOCK_DATA[17:12]);
					else
						hour <= CLOCK_DATA[17:12] - {2'b0, offset_hour};
				end
				min <= CLOCK_DATA[11:6];
				sec <= CLOCK_DATA[5:0];
		end
	end
	
	SEP_DIGITS HOUR_SEP(hour, LOCAL_CLOCK_DATA[23:20], LOCAL_CLOCK_DATA[19:16]);
	SEP_DIGITS MIN_SEP(min, LOCAL_CLOCK_DATA[15:12], LOCAL_CLOCK_DATA[11:8]);
	SEP_DIGITS SEC_SEP(sec, LOCAL_CLOCK_DATA[7:4], LOCAL_CLOCK_DATA[3:0]);

endmodule
