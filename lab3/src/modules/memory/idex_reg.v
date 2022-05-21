// idex_reg.v
// This module is the ID/EX pipeline register.


module idex_reg #(
  parameter DATA_WIDTH = 32
)(
  // TODO: Add flush or stall signal if it is needed

  //////////////////////////////////////
  // Inputs
  //////////////////////////////////////
  input clk,
  input id_flush,

  input [DATA_WIDTH - 1 : 0] id_PC,
  input [DATA_WIDTH - 1 : 0] id_pc_plus_4,

  // ex control
  input [1 : 0] id_jump,
  input id_branch,
  input [1 : 0] id_aluop,
  input id_alusrc,

  // mem control
  input id_memread,
  input id_memwrite,

  // wb control
  input id_memtoreg,
  input id_regwrite,

  input [DATA_WIDTH - 1 : 0] id_sextimm,
  input [6 : 0] id_funct7,
  input [2 : 0] id_funct3,
  input [DATA_WIDTH - 1 : 0] id_readdata1,
  input [DATA_WIDTH - 1 : 0] id_readdata2,
  input [4 : 0] id_rs1,
  input [4 : 0] id_rs2,
  input [4 : 0] id_rd,

  //////////////////////////////////////
  // Outputs
  //////////////////////////////////////
  output reg [DATA_WIDTH - 1 : 0] ex_PC,
  output reg [DATA_WIDTH - 1 : 0] ex_pc_plus_4,

  // ex control
  output reg ex_branch,
  output reg [1 : 0] ex_aluop,
  output reg ex_alusrc,
  output reg [1 : 0] ex_jump,

  // mem control
  output reg ex_memread,
  output reg ex_memwrite,

  // wb control
  output reg ex_memtoreg,
  output reg ex_regwrite,

  output reg [DATA_WIDTH - 1 : 0] ex_sextimm,
  output reg [6 : 0] ex_funct7,
  output reg [2 : 0] ex_funct3,
  output reg [DATA_WIDTH - 1 : 0] ex_readdata1,
  output reg [DATA_WIDTH - 1 : 0] ex_readdata2,
  output reg [4 : 0] ex_rs1,
  output reg [4 : 0] ex_rs2,
  output reg [4 : 0] ex_rd
);

// TODO: Implement ID/EX pipeline register module

always @(posedge clk) begin

  if (id_flush == 1'b1) begin
    ex_PC        <= (~id_flush) ? id_PC        : 32'hXXXX_XXXX;
    ex_pc_plus_4 <= (~id_flush) ? id_pc_plus_4 : 32'hXXXX_XXXX;
    ex_jump      <= (~id_flush) ? id_jump      : 2'bXX;
    ex_branch    <= (~id_flush) ? id_branch    : 1'bX;
    ex_aluop     <= (~id_flush) ? id_aluop     : 2'bXX;
    ex_alusrc    <= (~id_flush) ? id_alusrc    : 1'bX;
    ex_memread   <= (~id_flush) ? id_memread   : 1'bX;
    ex_memwrite  <= (~id_flush) ? id_memwrite  : 1'bX;
    ex_memtoreg  <= (~id_flush) ? id_memtoreg  : 1'bX;
    ex_regwrite  <= (~id_flush) ? id_regwrite  : 1'bX;
    ex_sextimm   <= (~id_flush) ? id_sextimm   : 32'hXXXX_XXXX;
    ex_funct7    <= (~id_flush) ? id_funct7    : 7'bXXX_XXXX;
    ex_funct3    <= (~id_flush) ? id_funct3    : 3'bXXX;
    ex_readdata1 <= (~id_flush) ? id_readdata1 : 32'hXXXX_XXXX;
    ex_readdata2 <= (~id_flush) ? id_readdata2 : 32'hXXXX_XXXX;
    ex_rs1       <= (~id_flush) ? id_rs1       : 5'bXXXXX;
    ex_rs2       <= (~id_flush) ? id_rs2       : 5'bXXXXX;
    ex_rd        <= (~id_flush) ? id_rd        : 5'bXXXXX;
  end
end

endmodule
