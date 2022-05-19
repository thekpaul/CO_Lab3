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
  output reg [DATA_WIDTH-1:0] mem_pc_plus_4,

  // mem control
  output reg mem_memread,
  output reg mem_memwrite,

  // wb control
  output reg [1:0] mem_jump,
  output reg mem_memtoreg,
  output reg mem_regwrite,

  output reg [DATA_WIDTH-1:0] mem_alu_result,
  output reg [DATA_WIDTH-1:0] mem_writedata,
  output reg [2:0] mem_funct3,
  output reg [4:0] mem_rd
);

// TODO: Implement EX / MEM pipeline register module

reg [DATA_WIDTH - 1 : 0] reg_pc_plus_4;
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
    mem_pc_plus_4  <= 32'h0000_0000;
    mem_memread    <= 1'b0;
    mem_memwrite   <= 1'b0;
    mem_jump       <= 2'b00;
    mem_memtoreg   <= 1'b0;
    mem_regwrite   <= 1'b0;
    mem_alu_result <= 32'h0000_0000;
    mem_writedata  <= 32'h0000_0000;
    mem_funct3     <= 3'b000;
    mem_rd         <= 5'b00000;
  end
  else begin
    mem_pc_plus_4  <= ex_pc_plus_4;
    mem_memread    <= ex_memread;
    mem_memwrite   <= ex_memwrite;
    mem_jump       <= ex_jump;
    mem_memtoreg   <= ex_memtoreg;
    mem_regwrite   <= ex_regwrite;
    mem_alu_result <= ex_alu_result;
    mem_writedata  <= ex_writedata;
    mem_funct3     <= ex_funct3;
    mem_rd         <= ex_rd;
  end
end

endmodule
