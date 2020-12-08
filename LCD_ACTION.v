`timescale 1ns / 1ps

module LCD_ACTION(
	input RESETN,
	input CLK,
	input [3:0] STATE,
	input [1:0] MENU_STATE,
	input [31:0] CNT,
	input [4:0] CHAR_CNT,
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

	parameter CLOCK_SETUP = 2'b00,
						TIMEZONE_SETUP = 2'b01,
						ALARM_SETUP = 2'b10,
						RETURN = 2'b11;
						
	reg is_lcd_cleared;
	reg [3:0] PREVIOUS_STATE;

	always @(negedge RESETN, posedge CLK) begin
		if (~RESETN) begin
			LCD_RS <= 1;
			LCD_RW <= 1;
			LCD_DATA <= 8'b00000000;
			is_lcd_cleared <= 0;
		end else begin
			
			if (STATE != PREVIOUS_STATE)
				if ((STATE == LINE1 && PREVIOUS_STATE == LINE2) || (STATE == LINE2 && PREVIOUS_STATE == LINE1))
					is_lcd_cleared <= 1;
				else
					is_lcd_cleared <= 0;
		
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
							if (~is_lcd_cleared) begin
								LCD_RW <= 1'b0;
								LCD_RS <= 1'b0;
								LCD_DATA <= 8'b00000001;
							end else begin
								LCD_RW <= 1'b1;
								LCD_RS <= 1'b1;
								LCD_DATA <= 8'bx;
							end
						end

						1: begin
							if (~is_lcd_cleared) begin
								LCD_RW <= 1'b0;
								LCD_RS <= 1'b0;
								LCD_DATA <= 8'b00000001;
								is_lcd_cleared <= 1;
							end else begin
								LCD_RW <= 1'b1;
								LCD_RS <= 1'b1;
								LCD_DATA <= 8'bx;
							end
						end
						
						2: begin
							LCD_RS <= 1'b0;
							LCD_DATA <= 8'b10000100; // Set DDRAM address to 0x04, (5, 0) in LCD
						end
						
						3: begin
							LCD_RS <= 1'b1;
							LCD_DATA <= {4'b0000, CLOCK_DATA[23:20]} | 8'b00110000; // ASCII Code '0' + BCD Data
						end
						
						4: begin
							LCD_RS <= 1'b1;
							LCD_DATA <= {4'b0000, CLOCK_DATA[19:16]} | 8'b00110000;
						end
						
						5: begin
							LCD_RS <= 1'b1;
							if (CLOCK_DATA [0])
								LCD_DATA <= 8'b00111010; // Display colon on every odd seconds
							else
								LCD_DATA <= 8'b00100000; // Display blank on every even seconds
						end
						
						6: begin
							LCD_RS <= 1'b1;
							LCD_DATA <= {4'b0000, CLOCK_DATA[15:12]} | 8'b00110000;
						end
						
						7: begin
							LCD_RS <= 1'b1;
							LCD_DATA <= {4'b0000, CLOCK_DATA[11:8]} | 8'b00110000;
						end
						
						8: begin
							LCD_RS <= 1'b1;
							if (CLOCK_DATA [0])
								LCD_DATA <= 8'b00111010;
							else
								LCD_DATA <= 8'b00100000;
						end
						
						9: begin
							LCD_RS <= 1'b1;
							LCD_DATA <= {4'b0000, CLOCK_DATA[7:4]} | 8'b00110000;
						end
						
						10: begin
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
							
				SETUP: begin
					LCD_RW <= 1'b0;
					
					case (CHAR_CNT)
						0: begin
							if (~is_lcd_cleared) begin
								LCD_RW <= 1'b0;
								LCD_RS <= 1'b0;
								LCD_DATA <= 8'b00000001;
							end else begin
								LCD_RW <= 1'b1;
								LCD_RS <= 1'b1;
								LCD_DATA <= 8'bx;
							end
						end
						
						1: begin
							if (~is_lcd_cleared) begin
								LCD_RW <= 1'b0;
								LCD_RS <= 1'b0;
								LCD_DATA <= 8'b00000001;
							end else begin
								LCD_RW <= 1'b1;
								LCD_RS <= 1'b1;
								LCD_DATA <= 8'bx;
							end
						end

						2: begin
							if (~is_lcd_cleared) begin
								LCD_RW <= 1'b0;
								LCD_RS <= 1'b0;
								LCD_DATA <= 8'b00000001;
								is_lcd_cleared <= 1;
							end else begin
								LCD_RW <= 1'b1;
								LCD_RS <= 1'b1;
								LCD_DATA <= 8'bx;
							end
						end
						
						3: begin
							LCD_RW <= 1'b0;
							LCD_RS <= 1'b0;
							LCD_DATA <= 8'b10000110; // Set DDRAM address to 0x04, (5, 0) in LCD
						end
						
						4: begin
							LCD_RS <= 1'b1;
							LCD_DATA <= 8'b01001101; // M
						end
						
						5: begin
							LCD_RS <= 1'b1;
							LCD_DATA <= 8'b01000101; // E
						end
						
						6: begin
							LCD_RS <= 1'b1;
							LCD_DATA <= 8'b01001110; // N
						end
						
						7: begin
							LCD_RS <= 1'b1;
							LCD_DATA <= 8'b01010101; // U
						end
						
						8: begin
							LCD_RS <= 1'b0;
							LCD_DATA <= 8'b11000010; // Set DDRAM address to 0x44, (0, 1) in LCD
						end
						
						9: begin
							LCD_RS <= 1'b1;
							case(MENU_STATE)
								CLOCK_SETUP: LCD_DATA <= 8'h43;
								TIMEZONE_SETUP: LCD_DATA <= 8'h54;
								ALARM_SETUP: LCD_DATA <= 8'h41;
								RETURN: LCD_DATA <= 8'h20;
							endcase
						end
						
						10: begin
							LCD_RS <= 1'b1;
							case(MENU_STATE)
								CLOCK_SETUP: LCD_DATA <= 8'h4C;
								TIMEZONE_SETUP: LCD_DATA <= 8'h49;
								ALARM_SETUP: LCD_DATA <= 8'h4C;
								RETURN: LCD_DATA <= 8'h20;
							endcase
						end
						
						11: begin
							LCD_RS <= 1'b1;
							case(MENU_STATE)
								CLOCK_SETUP: LCD_DATA <= 8'h4F;
								TIMEZONE_SETUP: LCD_DATA <= 8'h4D;
								ALARM_SETUP: LCD_DATA <= 8'h41;
								RETURN: LCD_DATA <= 8'h20;
							endcase
						end
						
						12: begin
							LCD_RS <= 1'b1;
							case(MENU_STATE)
								CLOCK_SETUP: LCD_DATA <= 8'h43;
								TIMEZONE_SETUP: LCD_DATA <= 8'h45;
								ALARM_SETUP: LCD_DATA <= 8'h52;
								RETURN: LCD_DATA <= 8'h52;
							endcase
						end
						
						13: begin
							LCD_RS <= 1'b1;
							case(MENU_STATE)
								CLOCK_SETUP: LCD_DATA <= 8'h4B;
								TIMEZONE_SETUP: LCD_DATA <= 8'h5A;
								ALARM_SETUP: LCD_DATA <= 8'h4D;
								RETURN: LCD_DATA <= 8'h45;
							endcase
						end
						
						14: begin
							LCD_RS <= 1'b1;
							case(MENU_STATE)
								CLOCK_SETUP: LCD_DATA <= 8'h20;
								TIMEZONE_SETUP: LCD_DATA <= 8'h4F;
								ALARM_SETUP: LCD_DATA <= 8'h20;
								RETURN: LCD_DATA <= 8'h54;
							endcase
						end
						
						15: begin
							LCD_RS <= 1'b1;
							case(MENU_STATE)
								CLOCK_SETUP: LCD_DATA <= 8'h53;
								TIMEZONE_SETUP: LCD_DATA <= 8'h4E;
								ALARM_SETUP: LCD_DATA <= 8'h53;
								RETURN: LCD_DATA <= 8'h55;
							endcase
						end
						
						16: begin
							LCD_RS <= 1'b1;
							case(MENU_STATE)
								CLOCK_SETUP: LCD_DATA <= 8'h45;
								TIMEZONE_SETUP: LCD_DATA <= 8'h45;
								ALARM_SETUP: LCD_DATA <= 8'h45;
								RETURN: LCD_DATA <= 8'h52;
							endcase
						end
						
						17: begin
							LCD_RS <= 1'b1;
							case(MENU_STATE)
								CLOCK_SETUP: LCD_DATA <= 8'h54;
								TIMEZONE_SETUP: LCD_DATA <= 8'h20;
								ALARM_SETUP: LCD_DATA <= 8'h54;
								RETURN: LCD_DATA <= 8'h4E;
							endcase
						end
						
						18: begin
							LCD_RS <= 1'b1;
							case(MENU_STATE)
								CLOCK_SETUP: LCD_DATA <= 8'h55;
								TIMEZONE_SETUP: LCD_DATA <= 8'h53;
								ALARM_SETUP: LCD_DATA <= 8'h55;
								RETURN: LCD_DATA <= 8'h20;
							endcase
						end
						
						19: begin
							LCD_RS <= 1'b1;
							case(MENU_STATE)
								CLOCK_SETUP: LCD_DATA <= 8'h50;
								TIMEZONE_SETUP: LCD_DATA <= 8'h45;
								ALARM_SETUP: LCD_DATA <= 8'h50;
								RETURN: LCD_DATA <= 8'h20;
							endcase
						end
						
						20: begin
							LCD_RS <= 1'b1;
							case(MENU_STATE)
								CLOCK_SETUP: LCD_DATA <= 8'h20;
								TIMEZONE_SETUP: LCD_DATA <= 8'h54;
								ALARM_SETUP: LCD_DATA <= 8'h20;
								RETURN: LCD_DATA <= 8'h20;
							endcase
						end
						
						21: begin
							LCD_RS <= 1'b1;
							case(MENU_STATE)
								CLOCK_SETUP: LCD_DATA <= 8'h20;
								TIMEZONE_SETUP: LCD_DATA <= 8'h55;
								ALARM_SETUP: LCD_DATA <= 8'h20;
								RETURN: LCD_DATA <= 8'h20;
							endcase
						end
						
						22: begin
							LCD_RS <= 1'b1;
							case(MENU_STATE)
								CLOCK_SETUP: LCD_DATA <= 8'h20;
								TIMEZONE_SETUP: LCD_DATA <= 8'h50;
								ALARM_SETUP: LCD_DATA <= 8'h20;
								RETURN: LCD_DATA <= 8'h20;
							endcase
						end
						
						default: begin
							LCD_RW <= 1'b1;
							LCD_RS <= 1'b1;
							LCD_DATA <= 8'bx;
						end
					endcase
				end
				
				TZ_SET: begin
					case(CHAR_CNT)
						0: begin
							if (~is_lcd_cleared) begin
								LCD_RW <= 1'b0;
								LCD_RS <= 1'b0;
								LCD_DATA <= 8'b00000001;
							end else begin
								LCD_RW <= 1'b0;
								LCD_RS <= 1'b0;
								LCD_DATA <= 8'b10000000;
							end
						end
						
						1: begin
							if (~is_lcd_cleared) begin
								LCD_RW <= 1'b0;
								LCD_RS <= 1'b0;
								LCD_DATA <= 8'b00000001;
							end else begin
								LCD_RW <= 1'b0;
								LCD_RS <= 1'b0;
								LCD_DATA <= 8'b10000000;
							end
						end

						2: begin
							if (~is_lcd_cleared) begin
								LCD_RW <= 1'b0;
								LCD_RS <= 1'b0;
								LCD_DATA <= 8'b00000001;
								is_lcd_cleared <= 1;
							end else begin
								LCD_RW <= 1'b0;
								LCD_RS <= 1'b0;
								LCD_DATA <= 8'b10000000;
							end
						end
						
						3: begin
							LCD_RS <= 1'b1;
							LCD_DATA <= 8'h20;
						end
						
						4: LCD_DATA <= 8'h54; // T
						5: LCD_DATA <= 8'h49; // I
						6: LCD_DATA <= 8'h4D; // M
						7: LCD_DATA <= 8'h45; // E
						8: LCD_DATA <= 8'h5A; // Z
						9: LCD_DATA <= 8'h4F; // O
						10: LCD_DATA <= 8'h4E; // N
						11: LCD_DATA <= 8'h45; // E
						12: LCD_DATA <= 8'h20;
						13: LCD_DATA <= 8'h53; // S
						14: LCD_DATA <= 8'h45; // E
						15: LCD_DATA <= 8'h54; // T
						16: LCD_DATA <= 8'h55; // U
						17: LCD_DATA <= 8'h50; // P
						
						18: begin
							LCD_RS <= 1'b0;
							LCD_DATA <= 8'b11000110;
						end
						
						19: begin
							LCD_RS <= 1'b1;
							LCD_DATA <= MEM_DATA[31:24]; // Display Timezone data, to be fixed?
						end
						
						20: LCD_DATA <= MEM_DATA[23:16];
						21: LCD_DATA <= MEM_DATA[15:8];
						22: LCD_DATA <= MEM_DATA[7:0];
						
						default: begin
							LCD_RW <= 1'b1;
							LCD_RS <= 1'b1;
							LCD_DATA <= 8'bx;
						end
							
					endcase
				end
				
				TIME_SET: begin
					case (CHAR_CNT)
						0: begin
							if (~is_lcd_cleared) begin
								LCD_RW <= 1'b0;
								LCD_RS <= 1'b0;
								LCD_DATA <= 8'b00000001;
							end else begin
								LCD_RW <= 1'b0;
								LCD_RS <= 1'b0;
								LCD_DATA <= 8'b10000000;
							end
						end
						
						1: begin
							if (~is_lcd_cleared) begin
								LCD_RW <= 1'b0;
								LCD_RS <= 1'b0;
								LCD_DATA <= 8'b00000001;
							end else begin
								LCD_RW <= 1'b0;
								LCD_RS <= 1'b0;
								LCD_DATA <= 8'b10000000;
							end
						end

						2: begin
							if (~is_lcd_cleared) begin
								LCD_RW <= 1'b0;
								LCD_RS <= 1'b0;
								LCD_DATA <= 8'b00000001;
								is_lcd_cleared <= 1;
							end else begin
								LCD_RW <= 1'b0;
								LCD_RS <= 1'b0;
								LCD_DATA <= 8'b10000000;
							end
						end
						
						3: begin
							LCD_RW <= 1'b0;
							LCD_RS <= 1'b0;
							LCD_DATA <= 8'b10000100;
						end
						
						4: begin
							LCD_RW <= 1'b0;
							LCD_RS <= 1'b0;
							LCD_DATA <= 8'b10000100;
						end
						
						5: begin
							LCD_RW <= 1'b0;
							LCD_RS <= 1'b1;
							LCD_DATA <= {4'b0000, CLOCK_DATA[23:20]} | 8'b00110000;
						end
						
						6: LCD_DATA <= {4'b0000, CLOCK_DATA[19:16]} | 8'b00110000;
						7: LCD_DATA <= 8'b00111010;
						8: LCD_DATA <= {4'b0000, CLOCK_DATA[15:12]} | 8'b00110000;
						9: LCD_DATA <= {4'b0000, CLOCK_DATA[11:8]} | 8'b00110000;
						10: LCD_DATA <= 8'b00111010;
						11: LCD_DATA <= {4'b0000, CLOCK_DATA[7:4]} | 8'b00110000;
						12: LCD_DATA <= {4'b0000, CLOCK_DATA[3:0]} | 8'b00110000;
						
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

			endcase
			
			PREVIOUS_STATE <= STATE;
		end
	end

endmodule
