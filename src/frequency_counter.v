`default_nettype none
`timescale 1ns/1ps
module frequency_counter #(
    // If a module starts with #() then it is parametisable. It can be instantiated with different settings
    // for the localparams defined here. So the default is an UPDATE_PERIOD of 1200 and BITS = 12
    localparam UPDATE_PERIOD = 1200,
    localparam BITS = 12
)(
    input wire              clk,
    input wire              reset,
    input wire              signal,

    input wire [BITS-1:0]   period,
    input wire              period_load,

    output wire [6:0]       segments,
    output wire             digit
    );

    // states
    localparam STATE_COUNT  = 0;
    localparam STATE_TENS   = 1;
    localparam STATE_UNITS  = 2;

    reg [2:0] state;
    reg [6:0] edge_counter;
    reg [BITS-1:0] clock_counter;
    
    reg [3:0] tens_counter,units_counter;
    
    wire leading_edge_wire;
    edge_detect edgeDetector(.clk(clk), .signal(signal), .leading_edge_detect(leading_edge_wire));
    
    //seven_segment sevenSegment(.clk(clk), .reset(reset), .load(period_load), .ten_count(), .unit_count(), .segments(), .digit());

    always @(posedge clk) begin
        if(reset) begin
            // reset things here
            state <= STATE_COUNT;
            edge_counter <= 0;
            clock_counter <= 0; 
            units_counter <= 0;
            tens_counter <= 0;
        end else begin
            case(state)
                STATE_COUNT: begin
                    // if clock cycles > UPDATE_PERIOD then go to next state
                    if(clock_counter > UPDATE_PERIOD) begin
                        state <= STATE_TENS;
                    end else begin
                        clock_counter <= clock_counter + 1;
                    end
                    // count edges and clock cycles
                    if(leading_edge_wire)
                        edge_counter = edge_counter + 1;
                end

                STATE_TENS: begin
                    // count number of tens by subtracting 10 while edge counter >= 10
                    if (edge_counter >= 10) begin
                        edge_counter <= edge_counter - 4'd10;
                        tens_counter <= tens_counter + 1'b1;
                    end else begin
                        // then go to next state
                        state <= STATE_UNITS;
                    end
                    
                end

                STATE_UNITS: begin
                    // what is left in edge counter is units
                    units_counter <= edge_counter;
                    // update the display

                    // go back to counting
                    state <= state + 1'b1;
                    

                end

                default:
                    begin
                        edge_counter <= 0;
                        clock_counter <= 0;
                        units_counter <= 0;
                        tens_counter <= 0;
                        state <= STATE_COUNT;
                    end
            endcase
        end
    end

endmodule
