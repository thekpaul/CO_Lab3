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
  input [DATA_WIDTH - 1 : 0] target_pc,

  input [DATA_WIDTH - 1 : 0] if_PC,
  input [DATA_WIDTH - 1 : 0] if_pc_plus_4,
  input [DATA_WIDTH - 1 : 0] if_instruction,

  //////////////////////////////////////
  // Outputs
  //////////////////////////////////////
  output [DATA_WIDTH - 1 : 0] id_PC,
  output [DATA_WIDTH - 1 : 0] id_pc_plus_4,
  output [DATA_WIDTH - 1 : 0] id_instruction
);

// TODO: Implement IF/ID pipeline register module

reg [DATA_WIDTH - 1 : 0] reg_PC;
reg [DATA_WIDTH - 1 : 0] reg_pc_plus_4;
reg [DATA_WIDTH - 1 : 0] reg_instruction;

always @(posedge clk) begin
  if (if_flush == 1'b1) begin
    reg_PC          <= target_pc;
    reg_pc_plus_4   <= 32'b0000_0000;
    reg_instruction <= 32'b0000_0000;
  end
  else begin
    reg_PC          <= if_PC;
    reg_pc_plus_4   <= if_pc_plus_4;
    reg_instruction <= if_instruction;
  end
end

assign id_PC          = reg_PC;

assign id_pc_plus_4   = reg_pc_plus_4;

assign id_instruction = reg_instruction;

endmodule
