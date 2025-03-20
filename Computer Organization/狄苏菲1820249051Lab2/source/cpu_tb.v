`timescale 1ns / 1ps

module cpu_tb;

  // Parameters
  parameter DATA_WIDTH = 32;
  parameter ADDR_WIDTH = 10;  // Adjust as needed
    
  // Clock and Reset
  reg clk;
  reg reset;

  // Instruction Pointer Signals
  wire [ADDR_WIDTH-1:0] pc;
  reg                  branch_taken;
  reg [ADDR_WIDTH-1:0] branch_target;
  reg                  jump_taken;
  reg [ADDR_WIDTH-1:0] jump_target;
  
  // Instruction Fetch Signals
    wire [DATA_WIDTH-1:0] instr;

    // Instruction Memory (IMem) Signals
  reg  [ADDR_WIDTH-1:0]  imem_addr;
  wire [DATA_WIDTH-1:0]  imem_data;

   // Data Memory (DMem) Signals
  reg [ADDR_WIDTH-1:0]  dmem_addr;
  reg [DATA_WIDTH-1:0]  dmem_data_in;
  reg                     dmem_we;
  wire [DATA_WIDTH-1:0]   dmem_data_out;

  // Instruction Decode Signals
  wire [5:0] opcode;
  wire [4:0] rs, rt, rd;
  wire [15:0] imm;

  // Register Stack Signals
  wire [DATA_WIDTH-1:0] read_data_1;
  wire [DATA_WIDTH-1:0] read_data_2;
  reg  reg_write;
  reg  [4:0] write_reg;
  reg [DATA_WIDTH-1:0] write_data;
  reg  [4:0] read_reg_1, read_reg_2;

  // ALU Signals
    wire [DATA_WIDTH-1:0] alu_result;
    wire zero_flag;
    wire [3:0] alu_op;

  // Control Signals
  wire reg_write_ctrl, branch, mem_write;

  //-----------------------------------
  // Instantiate Modules
  //-----------------------------------

  // Instruction Pointer
  instr_pointer u_instr_pointer (
    .clk(clk),
    .reset(reset),
    .branch_taken(branch_taken),
    .branch_target(branch_target),
    .jump_taken(jump_taken),
    .jump_target(jump_target),
    .pc(pc)
  );

  // Instruction Fetch
  instr_fetch #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
  )u_instr_fetch (
    .clk(clk),
    .reset(reset),
    .pc(pc),
	.imem_addr(imem_addr),
    .imem_data(imem_data),
    .instr(instr)
  );
  
  // Instruction Memory (Simple Example)
  reg [DATA_WIDTH-1:0] memory_imem [0:((1 << ADDR_WIDTH)-1)];
  assign imem_data = memory_imem[imem_addr];

  // Instruction Decode
  instr_decode u_instr_decode (
    .instr(instr),
    .opcode(opcode),
    .rs(rs),
    .rt(rt),
    .rd(rd),
    .imm(imm)
  );

  // Register Stack
  reg_stack #(
    .DATA_WIDTH(DATA_WIDTH)
  ) u_reg_stack (
    .clk(clk),
    .reset(reset),
    .write_enable(reg_write),
    .write_reg(write_reg),
    .write_data(write_data),
    .read_reg_1(read_reg_1),
    .read_reg_2(read_reg_2),
    .read_data_1(read_data_1),
    .read_data_2(read_data_2)
  );
    
  // Data Memory (Simple Example)
    reg [DATA_WIDTH-1:0] memory_dmem [0:((1 << ADDR_WIDTH)-1)];
  assign dmem_data_out = memory_dmem[dmem_addr];
  
    always @(posedge clk) begin
		if(dmem_we)
			memory_dmem[dmem_addr] <= dmem_data_in;
	end


  // ALU
  alu #(
    .DATA_WIDTH(DATA_WIDTH)
  )u_alu (
    .alu_op(alu_op),
    .operand_1(read_data_1),
    .operand_2(read_data_2),
    .alu_result(alu_result),
    .zero_flag(zero_flag)
  );

  // Control Unit
  control u_control (
      .opcode(opcode),
      .reg_write(reg_write_ctrl),
      .alu_op(alu_op),
      .branch(branch),
      .mem_write(mem_write)
  );


  //-----------------------------------
  // Testbench Logic
  //-----------------------------------
  
  // Clock Generation
  always #5 clk = ~clk;

  initial begin
    clk = 0;
    reset = 1;
		
	//Initialize Instruction Memory
    memory_imem[0] = 32'h00000002;  //addi $t0, $zero, 2;   // add immediate r1 = 2
    memory_imem[1] = 32'h00420820;  //add  $t1, $t0, $zero   //add r2 = r1+0
	memory_imem[2] = 32'h0000000a; //addi $t2, $zero, 10     // r3=10
    memory_imem[3] = 32'h000a1020; //add  $t2, $t0, $t2;      //r4 = r3+r1 = 12
    memory_imem[4] = 32'h0000000f; //addi $t3, $zero, 15     //r5 =15
    memory_imem[5] = 32'h00c51824; //sub $t3, $t4, $t5;    //r6=r4-r5 = -3
	memory_imem[6] = 32'h0005000f;//lw $t0, 0($t0);
	memory_imem[7] = 32'h0005000f;//sw $t0, 0($t0);
    
	//Initialize Data memory
	memory_dmem[0] = 32'h55;

    #10;
    reset = 0;

    // Test Instructions
    //Read Register 1 and 2
    read_reg_1 = 5'h1;
    read_reg_2 = 5'h0;
	//Load Word example
    dmem_addr = {22'b0, 10'b0};
    dmem_we = 0;

    #1000;
    $finish;
  end
  
  initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, cpu_tb);
  end
endmodule
