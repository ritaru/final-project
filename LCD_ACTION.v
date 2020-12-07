`timescale 1ns / 1ps

module LCD_ACTION(
	input RESETN,
	input CLK,
	input [3:0] STATE,
	input [31:0] CNT,
	input [3:0] CHAR_CNT,
	input [23:0] CLOCK_DATA,
	input [31:0] MEM_DATA,
	output reg LCD_RS,
	output reg LCD_RW,
	output reg [7:0] LCD_DATA
    );
	 
	parameter INITIAL_DELAY = 4'b0000,
				 FUNCTION_SET = 4'b0001,
				 INITIAL_SETUP = 4'b0010,
				 CLEAR_SCREEN = 4'b0011,
				 SETUP = 4'b0100,
				 TIME_SET = 4'b0101,
				 TZ_SET = 4'b0110,
				 LINE1 = 4'b1000,
				 LINE2 = 4'b1001;

	always @(negedge RESETN, posedge CLK) begin
		if (~RESETN) begin
			LCD_RS <= 1;
			LCD_RW <= 1;
			LCD_DATA <= 8'b00000000;
		end else begin
			case(STATE)
				FUNCTION_SET: begin
					LCD_RS <= 1'b0;
					LCD_RW <= 1'b0;
					LCD_DATA <= 8'b00111100; // Display two lines, 5x8 character set
				end
				
				INITIAL_SETUP: begin
					case(CNT)
						0: begin
							LCD_RS <= 1'b0;
							LCD_RW <= 1'b0;
							LCD_DATA <= 8'b00001100;
						end
						
						1: begin
							LCD_DATA <= 8'b00000110;
						end
						
						default: begin
							LCD_RS <= 1'b1;
							LCD_RW <= 1'b1;
							LCD_DATA <= 8'bx;
						end
					endcase
				end
				
				CLEAR_SCREEN: begin
					LCD_RS <= 1'b0;
					LCD_RW <= 1'b0;
					LCD_DATA <= 8'b00000001;
				end
				
				LINE1: begin
					LCD_RW <= 1'b0;
					
					case(CNT)
						0: begin
							LCD_RS <= 1'b0;
							LCD_DATA <= 8'b10000100; // Set DDRAM address to 0x04, (5, 0) in LCD
						end
						
						1: begin
							LCD_RS <= 1'b1;
							LCD_DATA <= {4'b0000, CLOCK_DATA[23:20]} | 8'b00110000; // ASCII Code '0' + BCD Data
						end
						
						2: begin
							LCD_RS <= 1'b1;
							LCD_DATA <= {4'b0000, CLOCK_DATA[19:16]} | 8'b00110000;
						end
						
						3: begin
							LCD_RS <= 1'b1;
							if (CLOCK_DATA [0])
								LCD_DATA <= 8'b00111010; // Display colon on every odd seconds
							else
								LCD_DATA <= 8'b00100000; // Display blank on every even seconds
						end
						
						4: begin
							LCD_RS <= 1'b1;
							LCD_DATA <= {4'b0000, CLOCK_DATA[15:12]} | 8'b00110000;
						end
						
						5: begin
							LCD_RS <= 1'b1;
							LCD_DATA <= {4'b0000, CLOCK_DATA[11:8]} | 8'b00110000;
						end
						
						6: begin
							LCD_RS <= 1'b1;
							if (CLOCK_DATA [0])
								LCD_DATA <= 8'b00111010;
							else
								LCD_DATA <= 8'b00100000;
						end
						
						7: begin
							LCD_RS <= 1'b1;
							LCD_DATA <= {4'b0000, CLOCK_DATA[7:4]} | 8'b00110000;
						end
						
						8: begin
							LCD_RS <= 1'b1;
							LCD_DATA <= {4'b0000, CLOCK_DATA[3:0]} | 8'b00110000;
						end
							
						
						default: begin
							LCD_RW <= 1'b1;
							LCD_RS <= 1'b1;
							LCD_DATA <= 8'bx;
						end
					endcase
				end
				
				LINE2: begin
					LCD_RW <= 1'b0;
					
					case(CNT)
						1: begin
							LCD_RS <= 1'b0;
							LCD_DATA <= 8'b11000110; // Set DDRAM address to 0x04, (5, 0) in LCD
						end
						
						2: begin
							LCD_RS <= 1'b1;
							LCD_DATA <= MEM_DATA[31:24]; // Display Timezone data, to be fixed?
						end
						
						3: begin
							LCD_RS <= 1'b1;
							LCD_DATA <= MEM_DATA[23:16];
						end
						
						4: begin
							LCD_RS <= 1'b1;
							LCD_DATA <= MEM_DATA[15:8];
						end
						
						5: begin
							LCD_RS <= 1'b1;
							LCD_DATA <= MEM_DATA[7:0];
						end
						
						default: begin
							LCD_RW <= 1'b1;
							LCD_RS <= 1'b1;
							LCD_DATA <= 8'bx;
						end
					endcase
				end
				
				default: begin
					LCD_RS <= 1'b1;
					LCD_RW <= 1'b1;
					LCD_DATA <= 8'bx;
				end
				
				SETUP: begin
					LCD_RW <= 1'b0;
					
					case (CHAR_CNT)
						1: begin
							LCD_RS <= 1'b0;
							LCD_DATA <= 8'b10000100; // Set DDRAM address to 0x04, (5, 0) in LCD
						end
						
						2: begin
							LCD_RS <= 1'b0;
							LCD_DATA <= 8'b01001101;
						end
						
						3: begin
							LCD_RS <= 1'b0;
							LCD_DATA <= 8'b01000101;
						end
						
						4: begin
							LCD_RS <= 1'b0;
							LCD_DATA <= 8'b01001110;
						end
						
						5: begin
							LCD_RS <= 1'b0;
							LCD_DATA <= 8'b01010101;
						end
						
						6: begin
							LCD_RS <= 1'b0;
							LCD_DATA <= 8'b11000100; // Set DDRAM address to 0x44, (5, 1) in LCD
						end
						
						default: begin
							LCD_RW <= 1'b1;
							LCD_RS <= 1'b1;
							LCD_DATA <= 8'bx;
						end
					endcase
				end
			endcase
		end
	end

endmodule
