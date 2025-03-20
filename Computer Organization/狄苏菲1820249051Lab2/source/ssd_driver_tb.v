`timescale 1ns / 1ps
 
module ssd_driver_tb;
 
    // Inputs
    reg clk;
    reg [31:0] ssd_bits;
    reg ssd_char_mode;
 
    // Outputs
    wire [3:0] an;
    wire [6:0] seg;
    wire dp;
 
    // Instantiate the ssd_driver module
    ssd_driver uut (
        .clk(clk),
        .an(an),
        .seg(seg),
        .dp(dp),
        .ssd_bits(ssd_bits),
        .ssd_char_mode(ssd_char_mode)
    );
 
    // Clock generation
    always begin
        clk = 0; #5; clk = 1; #5;
    end
 
    // Stimulus
    initial begin
        // Initialize inputs
        clk = 0;
        ssd_bits = 32'b0;
        ssd_char_mode = 0;
 
        // Apply some test vectors
        #10;
        ssd_bits = 32'h01234567; // Test with some hex values
        ssd_char_mode = 0; // Test numeric mode
        #100;
 
        ssd_bits = 32'hA1B2C3D4; // Another test with hex values
        ssd_char_mode = 1; // Test character mode
        #100;
 
        ssd_bits = 32'hFFFFFFFF; // Test with all bits set
        ssd_char_mode = 0; // Numeric mode
        #100;
 
        // Test with a few different bit patterns in character mode
        ssd_bits = 32'h00000000; // All zeros
        ssd_char_mode = 1; // Character mode
        #100;
 
        ssd_bits = 32'h11111111; // Some values in character mode
        ssd_char_mode = 1;
        #100;
 
        // Stop simulation
        $finish;
    end
 
    // Monitor outputs
    initial begin
        $monitor("At time %t: ssd_bits = %h, ssd_char_mode = %b, an = %b, seg = %b, dp = %b", $time, ssd_bits, ssd_char_mode, an, seg, dp);
    end
 
endmodule