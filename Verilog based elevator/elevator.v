`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:42:41 05/30/2024 
// Design Name: 
// Module Name:    elevator 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module elevator_controller(
    input clk,
    input rst,
    input [3:0] floor_request,  // 4-bit input, each bit represents a request from a floor (floor 0, 1, 2, 3)
    input [7:0] weight,         // 8-bit input representing the weight sensor reading
    output reg [1:0] current_floor, // 2-bit output representing the current floor (0, 1, 2, 3)
    output reg moving_up,       // Indicator if elevator is moving up
    output reg moving_down,     // Indicator if elevator is moving down
    output reg door_open,       // Indicator if door is open
    output reg overload         // Indicator if the elevator is overloaded
);

    // State encoding for elevator FSM
    parameter IDLE = 3'b000;
    parameter MOVE_UP = 3'b001;
    parameter MOVE_DOWN = 3'b010;
    parameter OPEN_DOOR = 3'b011;
    parameter CLOSE_DOOR = 3'b100;
    parameter OVERLOAD = 3'b101;

    // Elevator state variables
    reg [2:0] current_state, next_state;
    reg [3:0] request_pending;
    parameter WEIGHT_THRESHOLD = 8'd150; // Example threshold for overload detection

    // Initialization
    initial begin
        current_floor = 2'b00;
        moving_up = 0;
        moving_down = 0;
        door_open = 0;
        overload = 0;
        current_state = IDLE;
        request_pending = 4'b0000;
    end

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            current_floor <= 2'b00;
            moving_up <= 0;
            moving_down <= 0;
            door_open <= 0;
            overload <= 0;
            request_pending <= 4'b0000;
        end else begin
            current_state <= next_state;

            // Handle floor requests
            if (floor_request != 4'b0000) begin
                request_pending <= floor_request;
            end

            // Check for overload
            if (weight > WEIGHT_THRESHOLD) begin
                overload <= 1;
            end else begin
                overload <= 0;
            end
        end
    end

    // Next state logic
    always @(*) begin
        next_state=current_state;
        moving_up = 0;
        moving_down = 0;
        door_open = 0;

        case (current_state)
            IDLE: begin
                if (overload) begin
                    next_state = OVERLOAD;
                end else if (request_pending[current_floor]) begin
                    next_state = OPEN_DOOR;
                end else if (request_pending > current_floor) begin
                    next_state = MOVE_UP;
                    moving_up = 1;
                end else if (request_pending < current_floor) begin
                    next_state = MOVE_DOWN;
                    moving_down = 1;
                end
            end
            MOVE_UP: begin
                if (!overload && current_floor < 2'b11) begin
                    next_state = IDLE;
                    current_floor = current_floor + 1;
                end else if (overload) begin
                    next_state = OVERLOAD;
                end
            end
            MOVE_DOWN: begin
                if (!overload && current_floor > 2'b00) begin
                    next_state = IDLE;
                    current_floor = current_floor - 1;
                end else if (overload) begin
                    next_state = OVERLOAD;
                end
            end
            OPEN_DOOR: begin
                if (!overload) begin
                    door_open = 1;
                    next_state = CLOSE_DOOR;
                end else begin
                    next_state = OVERLOAD;
                end
            end
            CLOSE_DOOR: begin
                if (!overload) begin
                    door_open = 0;
                    request_pending[current_floor] = 0;
                    next_state = IDLE;
                end else begin
                    next_state = OVERLOAD;
                end
            end
            OVERLOAD: begin
                if (weight <= WEIGHT_THRESHOLD) begin
                    overload = 0;
                    next_state = IDLE;
                end else begin
                    door_open = 1; // Keep the door open during overload
                end
            end
        endcase
    end

endmodule
