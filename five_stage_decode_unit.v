module five_stage_decode_unit #(
  parameter CORE            = 0,
  parameter DATA_WIDTH      = 32,
  parameter ADDRESS_BITS    = 20,
  parameter SCAN_CYCLES_MIN = 0,
  parameter SCAN_CYCLES_MAX = 1000
) (
  // Base Decode Signals
  input  clock,
  input  reset,

  input  [ADDRESS_BITS-1:0] PC,
  input  [31:0] instruction,
  input  [1:0] extend_sel,
  input  write,
  input  [4:0]  write_reg,
  input  [31:0] write_data,

  output [31:0] rs1_data,
  output [31:0] rs2_data,
  output [4:0]  rd,
  output [6:0]  opcode,
  output [6:0]  funct7,
  output [2:0]  funct3,
  output [31:0] extend_imm,
  output [ADDRESS_BITS-1:0] branch_target,
  output [ADDRESS_BITS-1:0] JAL_target,

  // Data Bypassing Signals
  input [1:0] rs1_data_bypass,
  input [1:0] rs2_data_bypass,
  input [DATA_WIDTH-1:0] ALU_result_execute,
  input [DATA_WIDTH-1:0] ALU_result_memory,
  input [DATA_WIDTH-1:0] ALU_result_writeback,

  input scan

);

wire [DATA_WIDTH-1:0] rs1_data_decode;
wire [DATA_WIDTH-1:0] rs2_data_decode;

// Select signal for data bypassing
assign rs1_data = (rs1_data_bypass == 2'b00)? rs1_data_decode      :
                  (rs1_data_bypass == 2'b01)? ALU_result_execute   :
                  (rs1_data_bypass == 2'b10)? ALU_result_memory    :
                  (rs1_data_bypass == 2'b11)? ALU_result_writeback :
                  {DATA_WIDTH{1'b0}};

assign rs2_data = (rs2_data_bypass == 2'b00)? rs2_data_decode      :
                  (rs2_data_bypass == 2'b01)? ALU_result_execute   :
                  (rs2_data_bypass == 2'b10)? ALU_result_memory    :
                  (rs2_data_bypass == 2'b11)? ALU_result_writeback :
                  {DATA_WIDTH{1'b0}};

decode_unit #(
  .CORE(CORE),
  .ADDRESS_BITS(ADDRESS_BITS),
  .SCAN_CYCLES_MIN(SCAN_CYCLES_MIN),
  .SCAN_CYCLES_MAX(SCAN_CYCLES_MAX)
) base_decode (
  .clock(clock),
  .reset(reset),

  .PC(PC),
  .instruction(instruction),
  .extend_sel(extend_sel),
  .write(write),
  .write_reg(write_reg),
  .write_data(write_data),

  .rs1_data(rs1_data_decode),
  .rs2_data(rs2_data_decode),
  .rd(rd),
  .opcode(opcode),
  .funct7(funct7),
  .funct3(funct3),
  .extend_imm(extend_imm),
  .branch_target(branch_target),
  .JAL_target(JAL_target),

  .scan(scan)
);


endmodule
