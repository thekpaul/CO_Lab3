// forwarding.v

// This module determines if the values need to be forwarded to the EX stage.

// TODO: declare propoer input and output ports and implement the
// forwarding unit

module forwarding (
  // Input
  input [4 : 0] rs1,
  input [4 : 0] rs2,
  input [4 : 0] mem_rd,
  input [4 : 0] wb_rd,
  input mem_regwrite,
  input wb_regwrite,

  // Output
  output reg [1 : 0] fwdA, // Output is 00 01 10
  output reg [1 : 0] fwdB  // Output is 00 01 10
);

always @(*) begin

// fwdA
  if (  (rs1 != 5'b00000) & (rs1 == mem_rd) & (mem_regwrite)) fwdA <= 2'b01;
  else begin
    if ((rs1 != 5'b00000) & (rs1 == wb_rd)  & (wb_regwrite))  fwdA <= 2'b10;
    else fwdA <= 2'b00;
  end

// fwdB
  if (  (rs2 != 5'b00000) & (rs2 == mem_rd) & (mem_regwrite)) fwdB <= 2'b01;
  else begin
    if ((rs2 != 5'b00000) & (rs2 == wb_rd)  & (wb_regwrite))  fwdB <= 2'b10;
    else fwdB <= 2'b00;
  end
end

endmodule
