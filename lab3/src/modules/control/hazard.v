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
  input [DATA_WIDTH - 1 : 0] pc_plus_4,
  input [DATA_WIDTH - 1 : 0] pc_target,

  output if_flush,
  output id_flush,
  output ex_flush,
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
  if (pc_plus_4 != pc_target) flush = 1'b1;

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
  if ( use_rs[1] && ( (id_rs1 ==  ex_rd) &&  ex_regwrite ||
                      (id_rs1 == mem_rd) && mem_regwrite ||
                      (id_rs1 ==  wb_rd) &&  wb_regwrite ) ||
       use_rs[2] && ( (id_rs2 ==  ex_rd) &&  ex_regwrite ||
                      (id_rs2 == mem_rd) && mem_regwrite ||
                      (id_rs2 ==  wb_rd) &&  wb_regwrite ) ) stall = 1'b1;
end

assign if_flush = flush;
assign id_flush = flush;
assign ex_flush = flush;
assign do_stall = stall;

endmodule

// module hazard (
//   input [2:0] id_funct3,
//   input [32-1:0] id_instruction,
//   input [32-1:0] id_readdata1,
//   input [32-1:0] id_readdata2,
//   input [4:0] id_rs1, // source reg for current inst
//   input [4:0] id_rs2, // source reg for currnet inst
//   input hazard_ex_memread, //to determine if the previous instruction is LW and, if so, which register it will write to.
//   input hazard_mem_memread,
//   input hazard_wb_regwrite,
//   input [4:0]hazard_ex_rd, //to determine if the previous instruction is LW and, if so, which register it will write to.
//   input [4:0]hazard_mem_rd,
//   input [4:0]hazard_wb_rd,
//
//   output flush_taken,
//   output control_select,
//   output pc_write, // decice wheter to stall or continue
//   output if_id_write// decice wheter to stall or continue
//
// );
//
//
// reg reg_flush_taken;
// assign flush_taken = reg_flush_taken;
//
// reg pc_write;
// reg if_id_write;
// reg control_select;
//
// wire [6:0] opcode = id_instruction[6:0];
//
// always @(*) begin
//   case(opcode)
//     7'b1100011 :
//       case(id_funct3)
//         3'b000 : reg_flush_taken = (id_readdata1==id_readdata2)? 1'b1 : 1'b0;
//         3'b001 : reg_flush_taken = (id_readdata1!=id_readdata2)? 1'b1 : 1'b0;
//         3'b100 : reg_flush_taken = ($signed(id_readdata1) < $signed(id_readdata2))? 1'b1 : 1'b0;
//         3'b101 : reg_flush_taken = ($signed(id_readdata1) >= $signed(id_readdata2))? 1'b1 : 1'b0;
//         3'b110 : reg_flush_taken = ($unsigned(id_readdata1) < $unsigned(id_readdata2)) ? 1'b1 : 1'b0;
//         3'b111 : reg_flush_taken = ($unsigned(id_readdata1) >= $unsigned(id_readdata2)) ? 1'b1 : 1'b0;
//         default : reg_flush_taken = 1'b0;
//       endcase
//     7'b1101111 : reg_flush_taken = 1'b1; //jal
//     7'b1100111 : reg_flush_taken = 1'b1; //jalr
//     default : reg_flush_taken =1'b0;
//   endcase
// end
//
// always @(*) begin //매 순간 체크해서 stall끝날때 까지 계속 stall signal 보냄
//
//   if (
//     (( ((id_rs1 == hazard_ex_rd)||(id_rs2 == hazard_ex_rd)) && hazard_ex_memread))   //stall 3
//      //(( ((id_rs1 == hazard_mem_rd)||(id_rs2 == hazard_mem_rd)) && hazard_mem_memread)) || //stall 2
//      // (( ((id_rs1 == hazard_wb_rd)||(id_rs2 == hazard_wb_rd)) && hazard_wb_regwrite))  //stall 1
//   )
//
//   begin
//     pc_write =(~flush_taken);
//     if_id_write = (~flush_taken);
//     control_select = (~flush_taken);
//   end
//
//   else begin
//     pc_write =1'b0;
//     if_id_write = 1'b0;
//     control_select = 1'b0;
//   end
//
// end
//
// endmodule
