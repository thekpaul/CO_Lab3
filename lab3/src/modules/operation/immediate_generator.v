// immediate_generator.v

module immediate_generator #(
  parameter DATA_WIDTH = 32
)(
  input [DATA_WIDTH-1:0] instruction,

  output reg [DATA_WIDTH-1:0] sextimm
);

wire [6:0] opcode;
assign opcode = instruction[6:0];

always @(*) begin
  case (opcode)
    //////////////////////////////////////////////////////////////////////////
    // TODO : Generate sextimm using instruction

    // R -> NO IMM
    // I -> [31:20]
    7'b001_0011: sextimm = $signed(instruction[31:20]);

    // L -> [31:20]
    7'b000_0011: sextimm = $signed(instruction[31:20]);

    // S -> [31:24] + [11:7]
    7'b010_0011: sextimm = $signed({instruction[31:25], instruction[11:7]});

    // B -> [31] + [7] + [30:25] + [11:8] + 0
    7'b110_0011: sextimm = $signed({instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0});

    // J -> [31] + [19:12] + [20] + [30:21] + 0
    7'b110_1111: sextimm = $signed({instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0});

    // JALR
    7'b110_0111: sextimm = $signed({instruction[31], instruction[31:20]});

    //////////////////////////////////////////////////////////////////////////
    default:     sextimm = 32'h0000_0000;
  endcase
end


endmodule
