//exmem_reg.v


module exmem_reg #(
  parameter DATA_WIDTH = 32
)(
  // TODO: Add flush or stall signal if it is needed

  //////////////////////////////////////
  // Inputs
  //////////////////////////////////////
  input clk,
  input ex_flush,

  input [DATA_WIDTH-1:0] ex_pc_plus_4,
  input [DATA_WIDTH-1:0] ex_pc_target,
  input ex_taken,

  // mem control
  input ex_memread,
  input ex_memwrite,

  // wb control
  input [1:0] ex_jump,
  input ex_memtoreg,
  input ex_regwrite,

  input [DATA_WIDTH-1:0] ex_alu_result,
  input [DATA_WIDTH-1:0] ex_writedata,
  input [2:0] ex_funct3,
  input [4:0] ex_rd,

  //////////////////////////////////////
  // Outputs
  //////////////////////////////////////
  output [DATA_WIDTH-1:0] mem_pc_plus_4,
  output [DATA_WIDTH-1:0] mem_pc_target,
  output mem_taken,

  // mem control
  output mem_memread,
  output mem_memwrite,

  // wb control
  output [1:0] mem_jump,
  output mem_memtoreg,
  output mem_regwrite,

  output [DATA_WIDTH-1:0] mem_alu_result,
  output [DATA_WIDTH-1:0] mem_writedata,
  output [2:0] mem_funct3,
  output [4:0] mem_rd
);

// TODO: Implement EX / MEM pipeline register module

reg [DATA_WIDTH - 1 : 0] reg_pc_plus_4;
reg [DATA_WIDTH - 1 : 0] reg_pc_target;
reg reg_taken;
reg reg_memread;
reg reg_memwrite;
reg [1 : 0] reg_jump;
reg reg_memtoreg;
reg reg_regwrite;
reg [DATA_WIDTH - 1 : 0] reg_alu_result;
reg [DATA_WIDTH - 1 : 0] reg_writedata;
reg [2 : 0] reg_funct3;
reg [4 : 0] reg_rd;

always @(posedge clk) begin
  if (ex_flush == 1'b1) begin
    reg_pc_plus_4  <= 32'h0000_0000;
    reg_pc_target  <= 32'h0000_0000;
    reg_taken      <= 1'b0;
    reg_memread    <= 1'b0;
    reg_memwrite   <= 1'b0;
    reg_jump       <= 2'b00;
    reg_memtoreg   <= 1'b0;
    reg_regwrite   <= 1'b0;
    reg_alu_result <= 32'h0000_0000;
    reg_writedata  <= 32'h0000_0000;
    reg_funct3     <= 3'b000;
    reg_rd         <= 5'b00000;
  end
  else begin
    reg_pc_plus_4  <= ex_pc_plus_4;
    reg_pc_target  <= ex_pc_target;
    reg_taken      <= ex_taken;
    reg_memread    <= ex_memread;
    reg_memwrite   <= ex_memwrite;
    reg_jump       <= ex_jump;
    reg_memtoreg   <= ex_memtoreg;
    reg_regwrite   <= ex_regwrite;
    reg_alu_result <= ex_alu_result;
    reg_writedata  <= ex_writedata;
    reg_funct3     <= ex_funct3;
    reg_rd         <= ex_rd;
  end
end

  assign mem_pc_plus_4  = reg_pc_plus_4;

  assign mem_pc_target  = reg_pc_target;

  assign mem_taken      = reg_taken;

  assign mem_memread    = reg_memread;

  assign mem_memwrite   = reg_memwrite;

  assign mem_jump       = reg_jump;

  assign mem_memtoreg   = reg_memtoreg;

  assign mem_regwrite   = reg_regwrite;

  assign mem_alu_result = reg_alu_result;

  assign mem_writedata  = reg_writedata;

  assign mem_funct3     = reg_funct3;

  assign mem_rd         = reg_rd;

endmodule
