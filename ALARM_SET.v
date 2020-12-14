`timescale 1ns / 1ps

module ALARM_SET(
    input RESETN,
    input CLK,
    input [3:0] STATE,
    input [4:0] BUTTONS,
    input [17:0] RTC_DATA,
    input ALARM_TIME_SET,
    output reg [17:0] ALARM_SET_DATA,
    output reg ALARM_SET_FLAG
    );

    parameter ALARM_SET = 4'b0111;
    parameter UP = 5'b10000,
              DOWN = 5'b01000,
              CENTER = 5'b00100,
              LEFT = 5'b00010,
              RIGHT = 5'b00001;

    reg [4:0] BUTTONS_PREV;

    reg [2:0] cursor_position;
    reg [4:0] hour;
    reg [5:0] min, sec;
    reg is_time_loaded;

    always @(negedge RESETN, posedge CLK) begin
        if (~RESETN) begin
            ALARM_SET_FLAG <= 0;
            BUTTONS_PREV <= 0;
            cursor_position <= 0;
            
            hour <= 0;
            min <= 0;
            sec <= 0;
            is_time_loaded <= 0;
        end else begin
            if (STATE == ALARM_SET) begin 
                if ((~ALARM_SET_FLAG) && (~is_time_loaded)) begin
						hour <= RTC_DATA[16:12];
						min <= RTC_DATA[11:6];
						sec <= RTC_DATA[5:0];
						is_time_loaded <= 1;
                end

                case ((BUTTONS ^ BUTTONS_PREV) & BUTTONS)
                    UP: begin
                        if (~ALARM_TIME_SET) begin
                           case(cursor_position)
                                0: if (sec < 59) sec <= sec + 1; else sec <= 0;
                                1: if (sec < 49) sec <= sec + 10; else sec <= sec - 50;
                                2: if (min < 59) min <= min + 1; else min <= 0;
                                3: if (min < 49) min <= min + 10; else min <= min - 50;
                                4: if (hour < 23) hour <= hour + 1; else hour <= 0;
                           endcase 
                        end
                    end

                    DOWN: begin
                        if (~ALARM_TIME_SET) begin
                           case(cursor_position)
                                0: if (sec < 59) sec <= sec + 1; else sec <= 0;
                                1: if (sec < 49) sec <= sec + 10; else sec <= sec - 50;
                                2: if (min < 59) min <= min + 1; else min <= 0;
                                3: if (min < 49) min <= min + 10; else min <= min - 50;
                                4: if (hour < 23) hour <= hour + 1; else hour <= 0;
                           endcase 
                        end
                    end

                    LEFT: begin
                        if (~ALARM_TIME_SET) begin
                            if (cursor_position < 4)
                                cursor_position <= cursor_position + 1;
                            else
                                cursor_position <= 0;
                        end else
                            ALARM_SET_FLAG <= ~ALARM_SET_FLAG;
                    end

                    RIGHT: begin
                        if (~ALARM_TIME_SET) begin
                            if (cursor_position > 0)
                                cursor_position <= 4;
                            else
                                cursor_position <= cursor_position - 1;
                        end else
                            ALARM_SET_FLAG <= ~ALARM_SET_FLAG;
                    end
                endcase
            end else
                is_time_loaded <= 0;

            BUTTONS_PREV <= BUTTONS;
            ALARM_SET_DATA <= {1'b0, hour, min, sec};
        end
    end
endmodule
