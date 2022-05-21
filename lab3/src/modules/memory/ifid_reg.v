// ifid_reg.v
// This module is the IF/ID pipeline register.


module ifid_reg #(
  parameter DATA_WIDTH = 32
)(
  // TODO: Add flush or stall signal if it is needed

  //////////////////////////////////////
  // Inputs
  //////////////////////////////////////
  input clk,
  input if_flush,

  input [DATA_WIDTH - 1 : 0] if_PC,
  input [DATA_WIDTH - 1 : 0] if_pc_plus_4,
  input [DATA_WIDTH - 1 : 0] if_instruction,

  //////////////////////////////////////
  // Outputs
  //////////////////////////////////////
  output reg [DATA_WIDTH - 1 : 0] id_PC,
  output reg [DATA_WIDTH - 1 : 0] id_pc_plus_4,
  output reg [DATA_WIDTH - 1 : 0] id_instruction
);

// TODO: Implement IF/ID pipeline register module

reg [DATA_WIDTH - 1 : 0] reg_PC;
reg [DATA_WIDTH - 1 : 0] reg_pc_plus_4;
reg [DATA_WIDTH - 1 : 0] reg_instruction;

always @(posedge clk) begin
  id_PC          <= (~if_flush) ? if_PC          : 32'hXXXX_XXXX;
  id_pc_plus_4   <= (~if_flush) ? if_pc_plus_4   : 32'hXXXX_XXXX;
  id_instruction <= (~if_flush) ? if_instruction : 32'hXXXX_XXXX;
end

endmodule
