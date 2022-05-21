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
  input [4 : 0] mem_rd,
  input [4 : 0] wb_rd,
  input ex_regwrite,
  input mem_regwrite,
  input wb_regwrite,
  input [DATA_WIDTH - 1 : 0] pc_plus_4,
  input [DATA_WIDTH - 1 : 0] pc_target,

  output if_flush,
  output id_flush,
  output do_stall
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

reg flush = 1'b0;   // Flush Signal
reg stall = 1'b0;   // Stall Signal
reg [2 : 0] use_rs; // use_rs1 = use_rs[1], use_rs2 = use_rs[2]

always @(*) begin

  // FLUSH
  if ((^pc_plus_4 === 1'bX) && (^pc_target === 1'bX) &&
      (pc_plus_4 != pc_target)) flush = 1'b1;

  // USAGE Determination
  casex (opcode)
    7'b011_0011: use_rs <= 3'b11X; // R
    7'b001_0011: use_rs <= 3'b01X; // I
    7'b000_0011: use_rs <= 3'b01X; // L
    7'b010_0011: use_rs <= 3'b11X; // S
    7'b110_0011: use_rs <= 3'b11X; // B
    7'b110_1111: use_rs <= 3'b00X; // J
    7'b110_0111: use_rs <= 3'b01X; // JALR
    7'b011_0111: use_rs <= 3'b00X; // LUI
    7'b001_0111: use_rs <= 3'b00X; // AUIPC
    default:     use_rs <= 3'bXXX; // ERROR
  endcase

  // STALL
  if (use_rs[1] && (id_rs1 != 5'b00000) && (^id_rs1 === 1'bX) &&
        ( (id_rs1 ==  ex_rd) &&  ex_regwrite ||
          (id_rs1 == mem_rd) && mem_regwrite ||
          (id_rs1 ==  wb_rd) &&  wb_regwrite ) ||
      use_rs[2] && (id_rs2 != 5'b00000) && (^id_rs2 === 1'bX) &&
        ( (id_rs2 ==  ex_rd) &&  ex_regwrite ||
          (id_rs2 == mem_rd) && mem_regwrite ||
          (id_rs2 ==  wb_rd) &&  wb_regwrite ) ) stall = 1'b1;
end

assign if_flush = flush;
assign id_flush = flush;
assign do_stall = stall;

endmodule
