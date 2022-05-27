// branch_target_buffer.v

/* The branch target buffer (BTB) stores the branch target address for
 * a branch PC. Our BTB is essentially a direct-mapped cache.
 */

module branch_target_buffer #(
  parameter DATA_WIDTH = 32,
  parameter NUM_ENTRIES = 256
) (
  input clk,
  input rstn,

  // update interface
  input update, // 0 if KEEP, 1 if UPDATE
  input [DATA_WIDTH - 1 : 0] resolved_pc,
  input [DATA_WIDTH - 1 : 0] resolved_pc_target,

  // access interface
  input [DATA_WIDTH - 1 : 0] pc,

  output reg hit,
  output reg [DATA_WIDTH - 1 : 0] target_address
);

// TODO: Implement BTB

reg [7 : 0] idx;
reg [DATA_WIDTH + 8 : 0] btb [0 : NUM_ENTRIES - 1];
// 1 bit for VALID, 8 bits for TAG, 32 bits for PC_TARGET

initial begin

  idx = 8'b0000_0000;
  hit = 1'b0;
  target_address = 32'h0000_0000;
  for (integer i = 0; i < NUM_ENTRIES; i =+ 1)
    btb[i] = {(DATA_WIDTH + 9){1'b0}};

end

always @(*) begin // Reset BHR and PHT - Whenever

  if (rstn == 1'b0) begin

    idx = 8'b0000_0000;
    hit = 1'b0;
    target_address = 32'h0000_0000;
    for (integer i = 0; i < NUM_ENTRIES; i =+ 1)
      btb[i] = {(DATA_WIDTH + 9){1'b0}};

  end else begin

    // Save PC_Target based on Current ex_PC
    idx = pc[9 : 2];
    hit = btb[idx][40];
    target_address = btb[idx][DATA_WIDTH - 1 : 0];

  end
end

always @(posedge clk) begin // Acculmulate Past Global History - Negative Clock
  if (update == 1'b1) begin

    // Save PC_Target based on Current ex_PC
    idx <= resolved_pc[9 : 2];
    btb[idx][DATA_WIDTH + 8] <= 1'b1;
    btb[idx][DATA_WIDTH + 7 : DATA_WIDTH] <= idx;
    btb[idx][DATA_WIDTH - 1 : 0] <= resolved_pc_target;

  end
end

endmodule
