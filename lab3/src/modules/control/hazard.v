
// hazard.v

// This module determines if pipeline stalls or flushing are required

// TODO: declare propoer input and output ports and implement the
// hazard detection unit

module hazard #(
  parameter DATA_WIDTH = 32
)(
  input [4 : 0] id_rs1,
  input [4 : 0] id_rs2,
  input [6 : 0] opcode,
  input [4 : 0] ex_rd,
  input ex_memread,
  input [DATA_WIDTH - 1 : 0] pc_plus_4,
  input [DATA_WIDTH - 1 : 0] pc_target,

  output flush,
  output stall
);

/* Algorithm Flow
*
* FLUSH: PC Dependence Resolution
* - Necessity: PC is updated with new value at end of WB
* - Condition: Condition-met branch & jumps
* - Operation: `Flush` instructions if condition is fulfilled
*
* Determine Register Operand USAGE:
* - RS1 Used in: ALL except JAL and (U & UJ)
* - RS2 Used in: R and (S & SB)
*
* STALL: Data Dependence Resolution
* - Necessity: Register is updated with new value at end of WB
* - Condition: Used register operand is updated in unresolved previous inst.
* - Operation: Stall three cycles
*
*/

reg reg_flush = 1'b0;
reg reg_stall = 1'b0;
reg [2 : 0] use_rs = 3'bXXX; // use_rs1 = use_rs[1], use_rs2 = use_rs[2]

always @(*) begin

  // FLUSH
  if (pc_plus_4 != pc_target) reg_flush <= 1'b1;
  else reg_flush <= 1'b0;

  // USAGE Determination
  casex (opcode)
    7'b011_0011: use_rs <= 3'b110; // R
    7'b001_0011: use_rs <= 3'b010; // I
    7'b000_0011: use_rs <= 3'b010; // L
    7'b010_0011: use_rs <= 3'b110; // S
    7'b110_0011: use_rs <= 3'b110; // B
    7'b110_1111: use_rs <= 3'b000; // J
    7'b110_0111: use_rs <= 3'b010; // JALR
    7'b011_0111: use_rs <= 3'b000; // LUI
    7'b001_0111: use_rs <= 3'b000; // AUIPC
    default:     use_rs <= 3'bXXX; // ERROR
  endcase

  // STALL
  if ( (use_rs[1] == 1'b1 && (id_rs1 != 5'b00000) &&
          (id_rs1 ==  ex_rd) &&  ex_memread == 1'b1 ) ||
       (use_rs[2] == 1'b1 && (id_rs2 != 5'b00000) &&
          (id_rs2 ==  ex_rd) &&  ex_memread == 1'b1 ) ) reg_stall <= 1'b1;
  else reg_stall <= 1'b0;
end

assign flush = reg_flush;
assign stall = reg_stall;

endmodule
