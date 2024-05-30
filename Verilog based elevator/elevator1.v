`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:11:36 05/30/2024 
// Design Name: 
// Module Name:    elevator1 
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
module elevator_controller_tb;

    reg clk;
    reg rst;
    reg [3:0] floor_request;
    reg [7:0] weight;
    wire [1:0] current_floor;
    wire moving_up;
    wire moving_down;
    wire door_open;
    wire overload;

    elevator_controller uut (
        .clk(clk),
        .rst(rst),
        .floor_request(floor_request),
        .weight(weight),
        .current_floor(current_floor),
        .moving_up(moving_up),
        .moving_down(moving_down),
        .door_open(door_open),
        .overload(overload)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize inputs
        clk = 0;
        rst = 1;
        floor_request = 4'b0000;
        weight = 8'd0;

        // Reset the system
        #10 rst = 0;

        // Test sequence
        #10 floor_request = 4'b0001; // Request from floor 0
        #20 floor_request = 4'b0010; // Request from floor 1
        #30 floor_request = 4'b0100; // Request from floor 2
        #40 floor_request = 4'b1001;
        // Request from floor 3
        #10 floor_request=4'b0000;		  

        // Simulate overload
        #10 weight = 8'd200;         // Overload condition
        #20 weight = 8'd100;         // Normal weight

        // Observe the outputs
        #100 $stop;
    end
endmodule
