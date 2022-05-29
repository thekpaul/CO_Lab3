// branch_hardware.v

/* This module comprises a branch predictor and a branch target buffer.
 * Our CPU will use the branch target address only when BTB is hit.
 */

module branch_hardware #(
  parameter DATA_WIDTH = 32,
  parameter COUNTER_WIDTH = 2,
  parameter NUM_ENTRIES = 256 // 2^8
) (
  input clk,
  input rstn,

  // update interface
  input update_predictor, // 0 if KEEP, 1 if UPDATE
  input update_btb,       // 0 if KEEP, 1 if UPDATE
  input actually_taken,   // 0 if NOT TAKEN (-1), 1 if TAKEN (+1)
  input [DATA_WIDTH - 1 : 0] resolved_pc,        // ex_PC
  input [DATA_WIDTH - 1 : 0] resolved_pc_target, // ex_pc_target
    // actual target address when the branch is resolved.

  // access interface
  input [DATA_WIDTH - 1 : 0] pc,

  output reg hit,          // 0 if NOT IN BTB, 1 if IN BTB
  output reg pred,         // 0 if NOT TAKEN, 1 if TAKEN
  output reg [DATA_WIDTH - 1 : 0] branch_target
    // branch target address for a hit
);

// TODO: Instantiate a branch predictor and a BTB.

initial begin

  hit  = 1'b0;
  pred = 1'b0;
  branch_target = 32'h0000_0000;

end

wire in_hit;
wire in_pred;
wire [DATA_WIDTH - 1 : 0] pc_target;

// always @(posedge clk) begin
//   if (update_predictor == 1'b1) begin
//   end
//   if (update_btb == 1'b1) begin
//   end

// branch_target_buffer m_btb (
//   // Input
//   .clk                (clk),
//   .rstn               (rstn),
//
//   .update             (update_btb),
//   .resolved_pc        (resolved_pc),
//   .resolved_pc_target (resolved_pc_target),
//
//   .pc                 (pc),
//
//   // Output
//   .hit                (in_hit),
//   .target_address     (pc_target)
// );

// gshare m_gshare (
//   // Input
//   .clk            (clk),
//   .rstn           (rstn),
//
//   .update         (update_predictor),
//   .actually_taken (ex_taken),
//   .resolved_pc    (resolved_pc),
//
//   .pc             (pc),
//
//   // Output
//   .pred           (in_pred)
// );

always @(*) begin // Reset BHR and PHT - Whenever

  if (rstn == 1'b0) begin

    hit  = 1'b0;
    pred = 1'b0;
    branch_target = 32'h0000_0000;

  end else begin

    hit  = in_hit;
    pred = in_pred;
    branch_target = pc_target;

  end
end

endmodule
