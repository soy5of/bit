`timescale 1ns / 1ps
 
module tb_ports;
 
    // Parameters
    `include "parameters.vh"
    
    // Testbench signals
    reg [WORD_SIZE-1:0] portaddr, portval;
    reg clk, get_enable, set_enable;
    wire [WORD_SIZE-1:0] portout;
 
    // Instantiate the ports module
    ports uut (
        .portaddr(portaddr),
        .portval(portval),
        .clk(clk),
        .get_enable(get_enable),
        .set_enable(set_enable),
        .portout(portout)
    );
 
    // Clock generation
    always begin
        #5 clk = ~clk;  // Toggle clock every 5ns
    end
 
    // Initial block to apply stimulus
    initial begin
        // Initialize signals
        clk = 0;
        get_enable = 0;
        set_enable = 0;
        portaddr = 0;
        portval = 0;
 
        // Apply test case 1: Set operation on port 1
        #10 portaddr = 1;
        portval = 32'hA5A5A5A5;  // Example value to set
        set_enable = 1;
        #10 set_enable = 0;  // Disable set operation
 
        // Apply test case 2: Get operation on port 1
        #10 portaddr = 1;
        get_enable = 1;
        #10 get_enable = 0;  // Disable get operation
 
        // Apply test case 3: Set operation on port 0 (this should halt the machine)
        #10 portaddr = 0;
        portval = 32'hDEADBEEF;  // Example value to set
        set_enable = 1;
        #10 set_enable = 0;  // Disable set operation
        
        // End simulation after halting (stop command will stop the simulation)
        #10 $finish;
    end
 
    // Monitor signals for debugging
    initial begin
        $monitor("At time %t: portaddr = %h, portval = %h, portout = %h, get_enable = %b, set_enable = %b", 
                 $time, portaddr, portval, portout, get_enable, set_enable);
    end
 
endmodule