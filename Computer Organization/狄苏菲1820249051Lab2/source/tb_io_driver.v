`timescale 1ns / 1ps
 
module tb_io_driver;
 
    // Testbench signals
    reg clk;
    reg [3:0] btn;
    reg [7:0] sw;
    wire [3:0] led;
    wire [31:0] ssd_bits;
    wire ssd_char_mode;
    reg port_read;
    reg port_write;
    reg [15:0] port_addr;
    reg [15:0] port_write_data;
    wire [15:0] port_read_data;
 
    // Instantiate the io_driver module
    io_driver uut (
        .clk(clk),
        .btn(btn),
        .sw(sw),
        .led(led),
        .ssd_bits(ssd_bits),
        .ssd_char_mode(ssd_char_mode),
        .port_read(port_read),
        .port_write(port_write),
        .port_addr(port_addr),
        .port_write_data(port_write_data),
        .port_read_data(port_read_data)
    );
 
    // Clock generation
    always begin
        #5 clk = ~clk; // 100 MHz clock period (10ns high, 10ns low)
    end
 
    // Initial block to apply stimulus
    initial begin
        // Initialize signals
        clk = 0;
        btn = 4'b0000;
        sw = 8'b00000000;
        port_read = 0;
        port_write = 0;
        port_addr = 16'h0000;
        port_write_data = 16'h0000;
 
        // Test 1: Write to LED port (PORT_IO_LED)
        #10;
        port_write = 1;
        port_addr = `PORT_IO_LED;
        port_write_data = 16'h000F;  // Set LEDs to 0xF (only lower 4 bits affect the LEDs)
        #10;
        port_write = 0;
 
        // Check LED state
        #10;
        if (led != 4'hF) $display("Test 1 Failed: LED output = %h, Expected = 0xF", led);
        else $display("Test 1 Passed: LED output = %h", led);
 
        // Test 2: Write to 7-segment display (PORT_IO_HEX)
        #10;
        port_write = 1;
        port_addr = `PORT_IO_HEX;
        port_write_data = 16'h1234;  // Write a hexadecimal value to display
        #10;
        port_write = 0;
 
        // Check SSD bits
        #10;
        if (ssd_bits != 32'h0001000200030004) $display("Test 2 Failed: SSD bits = %h", ssd_bits);
        else $display("Test 2 Passed: SSD bits = %h", ssd_bits);
 
        // Test 3: Write to 7-segment display in decimal format (PORT_IO_DEC)
        #10;
        port_write = 1;
        port_addr = `PORT_IO_DEC;
        port_write_data = 16'h1234;  // Write a value to be converted to BCD
        #10;
        port_write = 0;
 
        // Check SSD bits after decimal conversion
        #10;
        if (ssd_bits != 32'h0001000200030004) $display("Test 3 Failed: SSD bits = %h", ssd_bits);
        else $display("Test 3 Passed: SSD bits = %h", ssd_bits);
 
        // Test 4: Write to 7-segment display as characters (PORT_IO_CHAR)
        #10;
        port_write = 1;
        port_addr = `PORT_IO_CHAR;
        port_write_data = 16'h4142;  // ASCII codes for 'A' and 'B'
        #10;
        port_write = 0;
 
        // Check SSD bits for character display
        #10;
        if (ssd_bits != 32'h0000000041420000) $display("Test 4 Failed: SSD bits = %h", ssd_bits);
        else $display("Test 4 Passed: SSD bits = %h", ssd_bits);
 
        // Test 5: Read from switch port (PORT_IO_SWITCH)
        #10;
        port_read = 1;
        port_addr = `PORT_IO_SWITCH;
        #10;
        port_read = 0;
 
        // Check the read data from switches
        #10;
        if (port_read_data != 16'h00FF) $display("Test 5 Failed: Read switches = %h", port_read_data);
        else $display("Test 5 Passed: Read switches = %h", port_read_data);
 
        // Test 6: Read from button port (PORT_IO_BUTTON)
        #10;
        port_read = 1;
        port_addr = `PORT_IO_BUTTON;
        #10;
        port_read = 0;
 
        // Check the read data from buttons
        #10;
        if (port_read_data != 16'h00F0) $display("Test 6 Failed: Read buttons = %h", port_read_data);
        else $display("Test 6 Passed: Read buttons = %h", port_read_data);
 
        // Test complete
        #10;
        $finish;
    end
 
endmodule