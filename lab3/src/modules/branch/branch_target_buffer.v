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

reg [54 : 0] btb [0 : NUM_ENTRIES - 1];

wire [21 : 0] a_tag;
wire [21 : 0] u_tag;
wire [7 : 0] a_idx;
wire [7 : 0] u_idx;

assign a_idx = pc[9 : 2];
assign u_idx = resolved_pc[9 : 2];
assign a_tag = pc[DATA_WIDTH - 1 : 10];
assign u_tag = resolved_pc[DATA_WIDTH - 1 : 10];

integer d;

always @(*) begin // Reset BHR and PHT - Whenever

  if (rstn == 1'b0) begin

    hit = 1'b0;
    target_address = 32'h0000_0000;
    for (d = 0; d < NUM_ENTRIES; d = d + 1) btb[d] = {55{1'b0}};

  end else begin

    if (btb[a_idx][53 : DATA_WIDTH] == a_tag) begin
      hit = btb[a_idx][54];
      target_address = btb[a_idx][DATA_WIDTH - 1 : 0];
    end

  end
end

always @(posedge clk) begin // Acculmulate Past Global History - Negative Clock
  if (update == 1'b1) begin

    // Save PC_Target based on Current ex_PC
    btb[u_idx][54] <= 1'b1; // VALID
    btb[u_idx][53 : DATA_WIDTH] <= u_tag;
    btb[u_idx][DATA_WIDTH - 1 : 0] <= resolved_pc_target;

  end
end

endmodule
