// memwb_reg.v
// This module is the MEM/WB pipeline register.


module memwb_reg #(
  parameter DATA_WIDTH = 32
)(
  // TODO: Add flush or stall signal if it is needed

  //////////////////////////////////////
  // Inputs
  //////////////////////////////////////
  input clk,

  input [DATA_WIDTH - 1 : 0] mem_pc_plus_4,

  // wb control
  input [1 : 0] mem_jump,
  input mem_memtoreg,
  input mem_regwrite,

  input [DATA_WIDTH - 1 : 0] mem_readdata,
  input [DATA_WIDTH - 1 : 0] mem_alu_result,
  input [4 : 0] mem_rd,

  //////////////////////////////////////
  // Outputs
  //////////////////////////////////////
  output [DATA_WIDTH - 1 : 0] wb_pc_plus_4,

  // wb control
  output [1 : 0] wb_jump,
  output wb_memtoreg,
  output wb_regwrite,

  output [DATA_WIDTH - 1 : 0] wb_readdata,
  output [DATA_WIDTH - 1 : 0] wb_alu_result,
  output [4 : 0] wb_rd
);

// TODO: Implement MEM/WB pipeline register module

reg [DATA_WIDTH - 1 : 0] reg_pc_plus_4;
reg [1 : 0] reg_jump;
reg reg_memtoreg;
reg reg_regwrite;
reg [DATA_WIDTH - 1 : 0] reg_readdata;
reg [DATA_WIDTH - 1 : 0] reg_alu_result;
reg [4 : 0] reg_rd;

always @(posedge clk) begin
  reg_pc_plus_4  <= mem_pc_plus_4;
  reg_jump       <= mem_jump;
  reg_memtoreg   <= mem_memtoreg;
  reg_regwrite   <= mem_regwrite;
  reg_readdata   <= mem_readdata;
  reg_alu_result <= mem_alu_result;
  reg_rd         <= mem_rd;
end

assign wb_pc_plus_4  = reg_pc_plus_4;

assign wb_jump       = reg_jump;

assign wb_memtoreg   = reg_memtoreg;

assign wb_regwrite   = reg_regwrite;

assign wb_readdata   = reg_readdata;

assign wb_alu_result = reg_alu_result;

assign wb_rd         = reg_rd;

endmodule
