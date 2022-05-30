// gshare.v

/* The Gshare predictor consists of the global branch history register (BHR)
 * and a pattern history table (PHT). Note that PC[1:0] is not used for
 * indexing.
 */

module gshare #(
  parameter DATA_WIDTH = 32,
  parameter COUNTER_WIDTH = 2,
  parameter NUM_ENTRIES = 256
) (
  input clk,
  input rstn,

  // update interface
  input update,         // 0 if KEEP, 1 if UPDATE
  input actually_taken, // 0 if NOT TAKEN (-1), 1 if TAKEN (+1)
  input [DATA_WIDTH - 1 : 0] resolved_pc,

  // access interface
  input [DATA_WIDTH - 1 : 0] pc,

  output reg pred // 0 if NOT TAKEN, 1 if TAKEN
);

// TODO: Implement gshare branch predictor

reg [7 : 0] bhr;
reg [COUNTER_WIDTH - 1 : 0] pht [0 : NUM_ENTRIES - 1];
wire [7 : 0] a_idx;
wire [7 : 0] u_idx;

assign a_idx = pc[9 : 2] ^ bhr;
assign u_idx = resolved_pc[9 : 2] ^ bhr;

integer c;

always @(*) begin // Reset BHR and PHT - Whenever

  if (rstn == 1'b0) begin

    bhr = 8'b0000_0000; // All Entries  in BHR are initialised to 1'b0
    for (c = 0; c < NUM_ENTRIES; c = c + 1) pht[c] = 2'b01;
      // All Counters in PHT are initialised to 2'b01

  end else begin

    // Return Corresponding Count in Relation to `PRED`
    pred = pht[a_idx][1]; // Larger bit represents TAKEN value
  end
end

always @(posedge clk) begin // Acculmulate Past Global History - Negative Clock
  if (update == 1'b1) begin

    // Shift existing BHR by ONE UNIT and ADD `TAKEN`
    bhr <= (bhr << 1);
    bhr[0] <= (actually_taken == 1'b1) ? 1'b1 : 1'b0;

    // Update Corresponding Count in Relation to `TAKEN`
    case (actually_taken)
      1'b1: pht[u_idx] <= ( 2'b11 == (pht[u_idx]) )
                          ? 2'b11 :  (pht[u_idx] + 2'b01);
                // TAKEN     => Add 1 unless MAX
      1'b0: pht[u_idx] <= ( 2'b00 == (pht[u_idx]) )
                          ? 2'b00 :  (pht[u_idx] - 2'b01);
                // NOT TAKEN => Subtract 1 unless MIN
      default: pht[u_idx] <= pht[u_idx];
                // ERROR => Keep Original Value
    endcase

  end

end

endmodule
