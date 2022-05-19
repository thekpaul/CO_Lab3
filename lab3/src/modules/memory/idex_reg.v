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
  output [DATA_WIDTH - 1 : 0] ex_PC,
  output [DATA_WIDTH - 1 : 0] ex_pc_plus_4,

  // ex control
  output ex_branch,
  output [1 : 0] ex_aluop,
  output ex_alusrc,
  output [1 : 0] ex_jump,

  // mem control
  output ex_memread,
  output ex_memwrite,

  // wb control
  output ex_memtoreg,
  output ex_regwrite,

  output [DATA_WIDTH - 1 : 0] ex_sextimm,
  output [6 : 0] ex_funct7,
  output [2 : 0] ex_funct3,
  output [DATA_WIDTH - 1 : 0] ex_readdata1,
  output [DATA_WIDTH - 1 : 0] ex_readdata2,
  output [4 : 0] ex_rs1,
  output [4 : 0] ex_rs2,
  output [4 : 0] ex_rd
);

// TODO: Implement ID/EX pipeline register module

  reg [DATA_WIDTH - 1 : 0] reg_PC;
  reg [DATA_WIDTH - 1 : 0] reg_pc_plus_4;
  reg [1 : 0] reg_jump;
  reg reg_branch;
  reg [1 : 0] reg_aluop;
  reg reg_alusrc;
  reg reg_memread;
  reg reg_memwrite;
  reg reg_memtoreg;
  reg reg_regwrite;
  reg [DATA_WIDTH - 1 : 0] reg_sextimm;
  reg [6 : 0] reg_funct7;
  reg [2 : 0] reg_funct3;
  reg [DATA_WIDTH - 1 : 0] reg_readdata1;
  reg [DATA_WIDTH - 1 : 0] reg_readdata2;
  reg [4 : 0] reg_rs1;
  reg [4 : 0] reg_rs2;
  reg [4 : 0] reg_rd;

always @(posedge clk) begin
  if (id_flush == 1'b1) begin
    reg_PC        <= 32'h0000_0000;
    reg_pc_plus_4 <= 32'h0000_0000;
    reg_jump      <= 2'b00;
    reg_branch    <= 1'b0;
    reg_aluop     <= 2'b00;
    reg_alusrc    <= 1'b0;
    reg_memread   <= 1'b0;
    reg_memwrite  <= 1'b0;
    reg_memtoreg  <= 1'b0;
    reg_regwrite  <= 1'b0;
    reg_sextimm   <= 32'h0000_0000;
    reg_funct7    <= 7'b000_0000;
    reg_funct3    <= 3'b000;
    reg_readdata1 <= 32'h0000_0000;
    reg_readdata2 <= 32'h0000_0000;
    reg_rs1       <= 5'b00000;
    reg_rs2       <= 5'b00000;
    reg_rd        <= 5'b00000;
  end
  else begin
    reg_PC        <= id_PC;
    reg_pc_plus_4 <= id_pc_plus_4;
    reg_jump      <= id_jump;
    reg_branch    <= id_branch;
    reg_aluop     <= id_aluop;
    reg_alusrc    <= id_alusrc;
    reg_memread   <= id_memread;
    reg_memwrite  <= id_memwrite;
    reg_memtoreg  <= id_memtoreg;
    reg_regwrite  <= id_regwrite;
    reg_sextimm   <= id_sextimm;
    reg_funct7    <= id_funct7;
    reg_funct3    <= id_funct3;
    reg_readdata1 <= id_readdata1;
    reg_readdata2 <= id_readdata2;
    reg_rs1       <= id_rs1;
    reg_rs2       <= id_rs2;
    reg_rd        <= id_rd;
  end
end

  assign ex_PC        = reg_PC;

  assign ex_pc_plus_4 = reg_pc_plus_4;

  assign ex_jump      = reg_jump;

  assign ex_branch    = reg_branch;

  assign ex_aluop     = reg_aluop;

  assign ex_alusrc    = reg_alusrc;

  assign ex_memread   = reg_memread;

  assign ex_memwrite  = reg_memwrite;

  assign ex_memtoreg  = reg_memtoreg;

  assign ex_regwrite  = reg_regwrite;

  assign ex_sextimm   = reg_sextimm;

  assign ex_funct7    = reg_funct7;

  assign ex_funct3    = reg_funct3;

  assign ex_readdata1 = reg_readdata1;

  assign ex_readdata2 = reg_readdata2;

  assign ex_rs1       = reg_rs1;

  assign ex_rs2       = reg_rs2;

  assign ex_rd        = reg_rd;

endmodule
