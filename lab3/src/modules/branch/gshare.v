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
reg [1 : 0] pht [0 : NUM_ENTRIES - 1];
reg [7 : 0] idx;

initial begin
  pred <= 1'b0;
  bhr <= 8'b0000_0000;
  for (integer i = 0; i < NUM_ENTRIES; i =+ 1) pht[i] <= 2'b01;
  idx <= 8'b0000_0000;
end

always @(*) begin // Reset BHR and PHT - Whenever

  if (rstn == 1'b1) begin

    bhr <= 8'b0000_0000; // All Entries  in BHR are initialised to 1'b0
    for (integer i = 0; i < NUM_ENTRIES; i =+ 1) pht[i] <= 2'b01;
      // All Counters in PHT are initialised to 2'b01

  end
end

always @(negedge clk) begin // Acculmulate Past Global History - Negative Clock
  if (update == 1'b1) begin

    // Shift existing BHR by ONE UNIT and ADD `TAKEN`
    bhr <= (bhr << 1'b1) + ((actually_taken == 1'b1) ? 1'b1 : 1'b0);

    // Locate Corresponding Count by XOR
    for (integer a = 8; a > 0; a =- 1) begin
      idx[a - 1] <= resolved_pc[a + 1] ^ bhr[a - 1];
    end

    // Update Corresponding Count in Relation to `TAKEN`
    case (actually_taken)
      1'b1: pht[idx] <= (2'b11 < pht[idx] + 1'b1) ? 2'b11 : (pht[idx] + 1'b1);
            // TAKEN     => Add 1 unless MAX
      1'b0: pht[idx] <= (2'b00 > pht[idx] - 1'b1) ? 2'b00 : (pht[idx] - 1'b1);
            // NOT TAKEN => Subtract 1 unless MIN
      default: pht[idx] <= pht[idx] + 1'b1; // ERROR => Keep Original Value
    endcase

  end
end

always @(posedge clk) begin // Access Global History with ALL new PC - Positive

  // Locate Corresponding Count by XOR
  for (integer b = 8; b > 0; b =- 1) begin
    idx[b - 1] <= pc[b + 1] ^ bhr[b - 1];
  end

  // Return Corresponding Count in Relation to `PRED`
  pred <= pht[idx][1]; // Larger bit represents TAKEN value

end

endmodule
