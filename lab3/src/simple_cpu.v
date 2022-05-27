
// simple_cpu.v
// a pipelined RISC-V microarchitecture (RV32I)

///////////////////////////////////////////////////////////////////////////////
// [*] In simple_cpu.v, connect the correct wires to the correct ports
//     - All modules are given so there is no need to make new modules
//       (it does not mean you do not need to instantiate new modules)
//     - However, you may have to fix or add in / out ports for some modules
//     - In addition, you are still free to instantiate simple modules like
//       multiplexers, adders, etc.
///////////////////////////////////////////////////////////////////////////////

module simple_cpu
#(parameter DATA_WIDTH = 32)(
  input clk,
  input rstn
);

///////////////////////////////////////////////////////////////////////////////
// TODO:  Declare all wires / registers that are needed

wire flush; // Super-stage Flush Signal
wire stall; // Super-stage Stall Signal

///////////////////////////////////////////
//        IF WIRES                       //
///////////////////////////////////////////

wire [DATA_WIDTH - 1 : 0] if_PC;
wire [DATA_WIDTH - 1 : 0] if_pc_plus_4;
wire [DATA_WIDTH - 1 : 0] if_instruction;

///////////////////////////////////////////
//        ID WIRES                       //
///////////////////////////////////////////

wire [DATA_WIDTH - 1 : 0] id_PC;
wire [DATA_WIDTH - 1 : 0] id_pc_plus_4;
wire [DATA_WIDTH - 1 : 0] id_instruction;

// ex control
wire [1 : 0] id_ui;
wire [1 : 0] id_jump;
wire id_branch;
wire [1 : 0] id_aluop;
wire id_alusrc;

// mem control
wire id_memread;
wire id_memwrite;

// wb control
wire id_memtoreg;
wire id_regwrite;

wire [DATA_WIDTH - 1 : 0] id_sextimm;
wire [6 : 0] opcode;
wire [6 : 0] id_funct7;
wire [2 : 0] id_funct3;
wire [DATA_WIDTH - 1 : 0] id_readdata1;
wire [DATA_WIDTH - 1 : 0] id_readdata2;
wire [4 : 0] id_rs1;
wire [4 : 0] id_rs2;
wire [4 : 0] id_rd;

///////////////////////////////////////////
//        EX WIRES                       //
///////////////////////////////////////////

wire [DATA_WIDTH - 1 : 0] ex_PC;

wire [1 : 0] ex_ui;
wire [1 : 0] ex_jump;
wire ex_branch;
wire [1 : 0] ex_aluop;
wire ex_alusrc;

wire [DATA_WIDTH - 1 : 0] ex_sextimm;
wire [6 : 0] ex_funct7;
wire [DATA_WIDTH - 1 : 0] ex_readdata1;
wire [DATA_WIDTH - 1 : 0] ex_readdata2;
wire [4 : 0] ex_rs1;
wire [4 : 0] ex_rs2;

wire [DATA_WIDTH - 1 : 0] ex_pc_plus_4;
wire [DATA_WIDTH - 1 : 0] ex_pc_target;
wire ex_taken;

wire ex_memread;
wire ex_memwrite;

wire ex_memtoreg;
wire ex_regwrite;

wire [DATA_WIDTH - 1 : 0] ex_alu_result;
wire [DATA_WIDTH - 1 : 0] ex_writedata;
wire [2 : 0] ex_funct3;
wire [4 : 0] ex_rd;

///////////////////////////////////////////
//        MEM WIRES                      //
///////////////////////////////////////////

wire [DATA_WIDTH - 1 : 0] mem_pc_plus_4;
wire mem_taken;

wire mem_memread;
wire mem_memwrite;

wire [1 : 0] mem_jump;
wire mem_memtoreg;
wire mem_regwrite;

wire [DATA_WIDTH - 1 : 0] mem_alu_result;
wire [DATA_WIDTH - 1 : 0] mem_writedata;
wire [2 : 0] mem_funct3;
wire [4 : 0] mem_rd;

wire [DATA_WIDTH - 1 : 0] mem_readdata;

///////////////////////////////////////////
//        WB WIRES                       //
///////////////////////////////////////////

wire [DATA_WIDTH - 1 : 0] wb_pc_plus_4;

// wb control
wire [1 : 0] wb_jump;
wire wb_memtoreg;
wire wb_regwrite;

wire [DATA_WIDTH - 1 : 0] wb_readdata;
wire [DATA_WIDTH - 1 : 0] wb_alu_result;
wire [4 : 0] wb_rd;

///////////////////////////////////////////////////////////////////////////////
// e.g., wire [DATA_WIDTH - 1 : 0] if_pc_plus_4;
// 1) Pipeline registers (wires to / from pipeline register modules)
// 2) In / Out ports for other modules
// 3) Additional wires for multiplexers or other modules you instantiate

///////////////////////////////////////////////////////////////////////////////
// Instruction Fetch (IF)
///////////////////////////////////////////////////////////////////////////////

reg [DATA_WIDTH - 1 : 0] PC;    // program counter (32 bits)

/* m_next_pc_adder */
adder m_pc_plus_4_adder(
  .in_a   (PC),
  .in_b   (32'h0000_0004),

  .result (if_pc_plus_4)
);

wire [DATA_WIDTH - 1 : 0] next_pc;

always @(posedge clk) begin
  if (rstn == 1'b0) PC <= 32'h00000000;
  else PC <= next_pc;
end

assign if_PC = PC;

/* instruction: read current instruction from inst mem */
instruction_memory m_instruction_memory(
  .address     (if_PC),

  .instruction (if_instruction)
);

/* Branch Hardware */
wire hit;
wire pred;
wire [DATA_WIDTH - 1 : 0] bp_target;

// assign hit  = 1'b0;
// assign pred = 1'b0;

branch_hardware m_branch_hardware (
  // Input
  .clk                (clk),
  .rstn               (rstn),
  .pc                 (if_PC),

  .update_predictor   (ex_branch),
  .update_btb         (flush),
  .actually_taken     (ex_taken),
  .resolved_pc        (ex_PC),
  .resolved_pc_target (ex_pc_target),

  // Output
  .hit                (hit),
  .pred               (pred),
  .branch_target      (bp_target)
);

wire [DATA_WIDTH - 1 : 0] guess_PC;

mux_2x1 bpPC((hit && pred),
  if_pc_plus_4, // 0 => No Prediction, move to PC + 4
  bp_target,    // 1 => Prediction, move to predicted PC
  guess_PC      // Guessed PC without branch resolve
);

mux_3x1 next({flush, (~flush && stall)},
  guess_PC,     // 00 => Default Incrementation
  PC,           // 01 => Stall
  ex_pc_target, // 10 => Next PC Changed => Detect by Flush
  next_pc
);

wire [31:0] NUM_COND_BRANCHES;
hardware_counter m_branch_count(
  .clk  (clk),
  .rstn (rstn),
  .cond (ex_branch),

  .counter(NUM_COND_BRANCHES)
);

wire [31:0] NUM_UNCOND_BRANCHES;
hardware_counter m_jump_count(
  .clk  (clk),
  .rstn (rstn),
  .cond (ex_jump[0]),

  .counter(NUM_UNCOND_BRANCHES)
);

wire [31:0] BP_CORRECT;
hardware_counter m_bp_correct(
  .clk  (clk),
  .rstn (rstn),
  .cond ((ex_branch || ex_jump[0]) && ~flush),

  .counter(BP_CORRECT)
);

wire [31:0] BP_INCORRECT;
hardware_counter m_bp_incorrect(
  .clk  (clk),
  .rstn (rstn),
  .cond (flush),

  .counter(BP_INCORRECT)
);

/* forward to IF/ID stage registers */
ifid_reg m_ifid_reg(
  // TODO: Add flush or stall signal if it is needed
  .clk            (clk),
  .if_flush       (flush),
  .do_stall       (stall),

  .if_PC          (if_PC),
  .if_pc_plus_4   (if_pc_plus_4),
  .if_instruction (if_instruction),

  .id_PC          (id_PC),
  .id_pc_plus_4   (id_pc_plus_4),
  .id_instruction (id_instruction)
);


///////////////////////////////////////////////////////////////////////////////
// Instruction Decode (ID)
///////////////////////////////////////////////////////////////////////////////

// instruction fields
assign opcode = id_instruction[6 : 0];
assign id_funct7 = id_instruction[31 : 25];
assign id_funct3 = id_instruction[14 : 12];

// R type
assign id_rs1 = id_instruction[19 : 15];
assign id_rs2 = id_instruction[24 : 20];
assign id_rd  = id_instruction[11 : 7];


/* m_hazard: hazard detection unit */
wire [DATA_WIDTH - 1 : 0] haza_detect;

mux_2x1 haza(stall,
  id_PC,         // 0 => NOT STALLED
  32'h0000_0000, // 1 => STALLED
  haza_detect
);

hazard m_hazard(
  // TODO: implement hazard detection unit & do wiring
  .rstn         (rstn),
  .id_rs1       (id_rs1),
  .id_rs2       (id_rs2),
  .opcode       (opcode),
  .ex_rd        (ex_rd),
  .ex_memread   (ex_memread),
  .pc_plus_4    (haza_detect),
  .pc_target    (ex_pc_target),

  .flush        (flush),
  .stall        (stall)
);

/* m_control: control unit */

control m_control(
  .opcode     (opcode),

  .ui         (id_ui),
  .jump       (id_jump),
  .branch     (id_branch),
  .alu_op     (id_aluop),
  .alu_src    (id_alusrc),
  .mem_read   (id_memread),
  .mem_to_reg (id_memtoreg),
  .mem_write  (id_memwrite),
  .reg_write  (id_regwrite)
);

/* m_imm_generator: immediate generator */
immediate_generator m_immediate_generator(
  .instruction(id_instruction),

  .sextimm    (id_sextimm)
);

wire [DATA_WIDTH - 1 : 0] write_data;

/* m_register_file: register file */
register_file m_register_file(
  .clk       (clk),
  .readreg1  (id_rs1),
  .readreg2  (id_rs2),
  .writereg  (wb_rd),
  .wen       (wb_regwrite),
  .writedata (write_data),

  .readdata1 (id_readdata1),
  .readdata2 (id_readdata2)
);

/* forward to ID/EX stage registers */
idex_reg m_idex_reg(
  // TODO: Add flush or stall signal if it is needed
  .clk          (clk),
  .id_flush     (flush),
  .do_stall     (stall),

  .id_PC        (id_PC),
  .id_pc_plus_4 (id_pc_plus_4),
  .id_ui        (id_ui),
  .id_jump      (id_jump),
  .id_branch    (id_branch),
  .id_aluop     (id_aluop),
  .id_alusrc    (id_alusrc),
  .id_memread   (id_memread),
  .id_memwrite  (id_memwrite),
  .id_memtoreg  (id_memtoreg),
  .id_regwrite  (id_regwrite),
  .id_sextimm   (id_sextimm),
  .id_funct7    (id_funct7),
  .id_funct3    (id_funct3),
  .id_readdata1 (id_readdata1),
  .id_readdata2 (id_readdata2),
  .id_rs1       (id_rs1),
  .id_rs2       (id_rs2),
  .id_rd        (id_rd),

  .ex_PC        (ex_PC),
  .ex_pc_plus_4 (ex_pc_plus_4),
  .ex_ui        (ex_ui),
  .ex_jump      (ex_jump),
  .ex_branch    (ex_branch),
  .ex_aluop     (ex_aluop),
  .ex_alusrc    (ex_alusrc),
  .ex_memread   (ex_memread),
  .ex_memwrite  (ex_memwrite),
  .ex_memtoreg  (ex_memtoreg),
  .ex_regwrite  (ex_regwrite),
  .ex_sextimm   (ex_sextimm),
  .ex_funct7    (ex_funct7),
  .ex_funct3    (ex_funct3),
  .ex_readdata1 (ex_readdata1),
  .ex_readdata2 (ex_readdata2),
  .ex_rs1       (ex_rs1),
  .ex_rs2       (ex_rs2),
  .ex_rd        (ex_rd)
);

///////////////////////////////////////////////////////////////////////////////
// Execute (EX)
///////////////////////////////////////////////////////////////////////////////

wire [1 : 0] fwdA, fwdB;

forwarding m_forwarding(
  // TODO: implement forwarding unit & do wiring
  // Input
  .rs1          (ex_rs1),
  .rs2          (ex_rs2),
  .mem_rd       (mem_rd),
  .wb_rd        (wb_rd),
  .mem_regwrite (mem_regwrite),
  .wb_regwrite  (wb_regwrite),

  // Output
  .fwdA         (fwdA),
  .fwdB         (fwdB)
);

wire [DATA_WIDTH - 1 : 0] fwd_data1, fwd_data2;

mux_3x1 muxA(fwdA,
  ex_readdata1,   // NO Forwarding
  mem_alu_result, // WRITE_BACK from MEM
  write_data,     // WRITE_BACK from WB
  fwd_data1       // Target Var
);

mux_3x1 muxB(fwdB,
  ex_readdata2,   // NO Forwarding
  mem_alu_result, // WRITE_BACK from MEM
  write_data,     // WRITE_BACK from WB
  fwd_data2       // Target Var
);

/* alu control: generates alu_func signal */
wire [3 : 0] alu_func;

alu_control m_alu_control(
  .alu_op   (ex_aluop),
  .funct7   (ex_funct7),
  .funct3   (ex_funct3),

  .alu_func (alu_func)
);

/* m_alu */
wire [31 : 0] alu_in1, alu_in2;
wire alu_check;

mux_3x1 muxu(ex_ui,
  fwd_data1,     // 00 => Proceed as Normal, NOT U-TYPE
  32'h0000_0000, // 01 => U-type & LUI
  ex_PC,         // 10 => U-type & AUIPC
  alu_in1
);

assign alu_in2 = (ex_alusrc == 1'b0) ? fwd_data2 : ex_sextimm;

alu m_alu(
  .alu_func (alu_func),
  .in_a     (alu_in1),
  .in_b     (alu_in2), // is input with reg allowed??

  .result   (ex_alu_result),
  .check    (alu_check)
);

/* m_PC_target_adder: PC + imm for branch address */
wire [DATA_WIDTH - 1 : 0] ex_move_dest;
wire [DATA_WIDTH - 1 : 0] ex_recipe;

mux_2x1 jalr(ex_jump[1],
  ex_PC,        // 0 => Branch or JAL, add PC with sextimm
  ex_readdata1, // 1 => JALR, add rs1 with sextimm
  ex_recipe
);

adder m_PC_target_adder(
  .in_a   (ex_recipe),
  .in_b   (ex_sextimm),

  .result (ex_move_dest) // = (ex_PC || ex_readdata) + ex_sextimm => next_PC
);

/* m_branch_control: checks T/NT */
wire fun_check;
assign fun_check = (alu_check == ex_funct3[0]);

branch_control m_branch_control(
  .branch (ex_branch),
  .check  (fun_check),

  .taken  (ex_taken)
);

mux_2x1 dest(ex_taken || ex_jump[0],
  ex_pc_plus_4, // 0 => Not Branching, PC + 4 is fed
  ex_move_dest, // 1 => Branch or Jump, Branch Target or Jump Address is fed
  ex_pc_target
);

assign ex_writedata = fwd_data2;

/* forward to EX/MEM stage registers */
exmem_reg m_exmem_reg(
  // TODO: Add flush or stall signal if it is needed
  .clk            (clk),

  .ex_pc_plus_4   (ex_pc_plus_4),
  .ex_jump        (ex_jump),
  .ex_memread     (ex_memread),
  .ex_memwrite    (ex_memwrite),
  .ex_memtoreg    (ex_memtoreg),
  .ex_regwrite    (ex_regwrite),
  .ex_alu_result  (ex_alu_result),
  .ex_writedata   (ex_writedata),
  .ex_funct3      (ex_funct3),
  .ex_rd          (ex_rd),

  .mem_pc_plus_4  (mem_pc_plus_4),
  .mem_jump       (mem_jump),
  .mem_memread    (mem_memread),
  .mem_memwrite   (mem_memwrite),
  .mem_memtoreg   (mem_memtoreg),
  .mem_regwrite   (mem_regwrite),
  .mem_alu_result (mem_alu_result),
  .mem_writedata  (mem_writedata),
  .mem_funct3     (mem_funct3),
  .mem_rd         (mem_rd)
);


///////////////////////////////////////////////////////////////////////////////
// Memory (MEM)
///////////////////////////////////////////////////////////////////////////////

/* m_data_memory: main memory module */
data_memory m_data_memory(
  .clk        (clk),
  .address    (mem_alu_result),
  .write_data (mem_writedata),
  .mem_read   (mem_memread),
  .mem_write  (mem_memwrite),
  .maskmode   (mem_funct3[1 : 0]),
  .sext       (mem_funct3[2]),

  .read_data  (mem_readdata)
);

/* forward to MEM/WB stage registers */
memwb_reg m_memwb_reg(
  // TODO: Add flush or stall signal if it is needed
  .clk            (clk),
  .mem_pc_plus_4  (mem_pc_plus_4),
  .mem_jump       (mem_jump),
  .mem_memtoreg   (mem_memtoreg),
  .mem_regwrite   (mem_regwrite),
  .mem_readdata   (mem_readdata),
  .mem_alu_result (mem_alu_result),
  .mem_rd         (mem_rd),

  .wb_pc_plus_4   (wb_pc_plus_4),
  .wb_jump        (wb_jump),
  .wb_memtoreg    (wb_memtoreg),
  .wb_regwrite    (wb_regwrite),
  .wb_readdata    (wb_readdata),
  .wb_alu_result  (wb_alu_result),
  .wb_rd          (wb_rd)
);

///////////////////////////////////////////////////////////////////////////////
// Write Back (WB)
///////////////////////////////////////////////////////////////////////////////

// TODO: Implement Write-Back on Top Module

mux_4x1 muxw({wb_jump[0], {wb_memtoreg}},
  wb_alu_result, // Jump 0, MemToReg 0 => Write memory data
  wb_readdata,   // Jump 0, MemToReg 1 => Write ALU result
  wb_pc_plus_4,  // Jump 1, MemToReg X => Write Jump Previous PC + 4
  wb_pc_plus_4,  // Jump 1, MemToReg X => Write Jump Previous PC + 4
  write_data
);

wire [31:0] CORE_CYCLE;
hardware_counter m_core_cycle(
  .clk(clk),
  .rstn(rstn),
  .cond(1'b1),

  .counter(CORE_CYCLE)
);

endmodule
