// control.v

// The main control module takes as input the opcode field of an instruction
// (i.e., instruction[6 : 0]) and generates a set of control signals.

module control(
  input [6 : 0] opcode,

  output [1 : 0] ui,
  output [1 : 0] jump,
  output branch,
  output mem_read,
  output mem_to_reg,
  output [1 : 0] alu_op,
  output mem_write,
  output alu_src,
  output reg_write
);

reg [11 : 0] controls;

// combinational logic
always @(*) begin
  casex (opcode)
    7'b011_0011: controls = 10'b00_000_10_001; // R-type

    //////////////////////////////////////////////////////////////////////////
    // TODO : Implement signals for other instruction types

    7'b001_0011: controls = 12'b00_00_000_11_011; // I-type

    7'b000_0011: controls = 12'b00_00_011_00_011; // I-type Load

    7'b010_0011: controls = 12'b00_00_000_00_110; // S-type

    7'b110_0011: controls = 12'b00_00_10X_01_000; // B-type

    7'b110_1111: controls = 12'b00_01_000_XX_011; // J-type

    7'b110_0111: controls = 12'b00_11_000_XX_011; // JALR

    7'b011_0111: controls = 12'b01_00_000_00_011; // LUI

    7'b001_0111: controls = 12'b10_00_000_00_011; // AUIPC

    //////////////////////////////////////////////////////////////////////////

    default:     controls = 12'b00_00_000_00_000;
  endcase
end

assign {ui, jump, branch, mem_read, mem_to_reg,
        alu_op, mem_write, alu_src, reg_write} = controls;

endmodule
