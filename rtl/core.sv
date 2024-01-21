`include "brisc_pkg.svh"

module core
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,

    input  mem_resp_t mem_resp,
    output mem_req_t  mem_req
);

  logic stall_F;
  pc_src_e pc_src_A_F;
  logic [XLEN-1:0] pc_F;
  logic [XLEN-1:0] pc_plus4_F;
  logic [ILEN-1:0] instr_F;

  logic stall_D;
  logic flush_D;
  logic [REG_BITS-1:0] rd_D;
  logic [REG_BITS-1:0] rs1_D;
  logic [REG_BITS-1:0] rs2_D;
  logic [XLEN-1:0] rs1_data_D;
  logic [XLEN-1:0] rs2_data_D;
  logic [XLEN-1:0] imm_D;
  logic [XLEN-1:0] pc_D;
  logic [XLEN-1:0] pc_plus4_D;
  logic reg_write_D;
  result_src_e result_src_D;
  logic mem_write_D;
  logic is_branch_D;
  logic is_jump_D;
  alu_ctrl_e alu_ctrl_D;
  alu_src1_e alu_src1_D;
  alu_src2_e alu_src2_D;
  data_size_e data_size_D;
  xcpt_e xcpt_D;

  logic [XLEN-1:0] pc_delta_A;
  logic [REG_BITS-1:0] rd_A;
  logic [REG_BITS-1:0] rs1_A;
  logic [REG_BITS-1:0] rs2_A;
  logic [XLEN-1:0] write_data_A;
  logic [XLEN-1:0] pc_plus4_A;
  logic [XLEN-1:0] alu_res_A;
  fwd_src_e fwd_src1_A;
  fwd_src_e fwd_src2_A;
  logic flush_A;
  logic reg_write_A;
  result_src_e result_src_A;
  logic mem_write_A;
  data_size_e data_size_A;
  logic stall_A;
  xcpt_e xcpt_A;

  logic [XLEN-1:0] pc_delta_C;
  logic [XLEN-1:0] read_data_C;
  logic [XLEN-1:0] alu_res_C;
  logic [REG_BITS-1:0] rd_C;
  logic reg_write_C;
  result_src_e result_src_C;
  logic [XLEN-1:0] pc_plus4_C;
  logic stall_C;

  logic [XLEN-1:0] result_WB;
  logic [REG_BITS-1:0] rd_WB;
  logic reg_write_WB;
  logic flush_WB;

  mem_req_t arb_req_icache, arb_req_dcache;
  logic igrant, dgrant;
  logic icache_ready, dcache_ready;

  fetch_stage fetch (
      .clk(clk),
      .reset(reset),
      .xcpt_in(),
      .stall_in(stall_F),
      .pc_src_in(pc_src_A_F),
      .pc_target_in(pc_delta_A),
      .pc_out(pc_F),
      .instr_out(instr_F),
      .pc_plus4_out(pc_plus4_F),

      // Cache
      .arbiter_grant_in(igrant),
      .icache_ready_out(icache_ready),
      .mem_req_out(arb_req_icache),

      // Memory
      .mem_resp_in(mem_resp)
  );

  decode_stage decode (
      .clk(clk),
      .reset(reset),
      .flush_in(flush_D),
      .stall_in(stall_D),
      .instr_in(instr_F),
      .pc_in(pc_F),

      .result_WB_in(result_WB),
      .rd_WB_in(rd_WB),
      .reg_write_WB_in(reg_write_WB),

      .pc_plus4_in(pc_plus4_F),

      .rd_out(rd_D),
      .rs1_out(rs1_D),
      .rs2_out(rs2_D),
      .pc_out(pc_D),
      .rs1_data_out(rs1_data_D),
      .rs2_data_out(rs2_data_D),
      .imm_out(imm_D),
      .pc_plus4_out(pc_plus4_D),

      // CTRL signals
      .reg_write_out(reg_write_D),
      .result_src_out(result_src_D),
      .mem_write_out(mem_write_D),
      .is_jump_out(is_jump_D),
      .is_branch_out(is_branch_D),
      .alu_ctrl_out(alu_ctrl_D),
      .alu_src1_out(alu_src1_D),
      .alu_src2_out(alu_src2_D),
      .data_size_out(data_size_D),
      .xcpt_out(xcpt_D)
  );

  alu_stage alu (
      .clk(clk),
      .reset(reset),
      .stall_in(stall_A),
      .flush_in(flush_A),
      .fwd_src1_in(fwd_src1_A),
      .fwd_src2_in(fwd_src2_A),
      .pc_plus4_in(pc_plus4_D),

      .rs1_data_in (rs1_data_D),
      .rs2_data_in (rs2_data_D),
      .alu_res_C_in(alu_res_C),
      .result_WB_in(result_WB),

      .rd_in (rd_D),
      .rs1_in(rs1_D),
      .rs2_in(rs2_D),
      .imm_in(imm_D),
      .pc_in (pc_D),

      .pc_src_out(pc_src_A_F),
      .pc_target_out(pc_delta_A),
      .alu_res_out(alu_res_A),
      .pc_plus4_out(pc_plus4_A),
      .rd_out(rd_A),
      .rs1_out(rs1_A),
      .rs2_out(rs2_A),

      .write_data_out(write_data_A),

      .reg_write_in(reg_write_D),
      .mem_write_in(mem_write_D),
      .result_src_in(result_src_D),
      .alu_ctrl_in(alu_ctrl_D),
      .alu_src1_in(alu_src1_D),
      .alu_src2_in(alu_src2_D),
      .is_branch_in(is_branch_D),
      .is_jump_in(is_jump_D),
      .data_size_in(data_size_D),

      // OUT: ctrl signals
      .reg_write_out(reg_write_A),
      .result_src_out(result_src_A),
      .mem_write_out(mem_write_A),
      .data_size_out(data_size_A),
      .xcpt_out(xcpt_A)
  );

  cache_stage cache (
      .clk(clk),
      .reset(reset),
      .stall_in(stall_C),
      .flush_in(0),
      .mem_resp_in(mem_resp),
      .mem_req_out(arb_req_dcache),
      .arbiter_grant_in(dgrant),
      .dcache_ready_out(dcache_ready),
      .alu_res_in(alu_res_A),
      .write_data_in(write_data_A),
      .pc_plus4_in(pc_plus4_A),
      .rd_in(rd_A),
      .alu_res_out(alu_res_C),
      .read_data_out(read_data_C),
      .pc_plus4_out(pc_plus4_C),
      .rd_out(rd_C),
      // CTRL signals
      .data_size_in(data_size_A),
      .reg_write_in(reg_write_A),
      .mem_write_in(mem_write_A),
      .result_src_in(result_src_A),
      .reg_write_out(reg_write_C),
      .result_src_out(result_src_C)
  );

  wb_stage write_back (
      .clk(clk),
      .reset(reset),
      .flush_in(flush_WB),
      .alu_res_in(alu_res_C),
      .read_data_in(read_data_C),
      .pc_plus4_in(pc_plus4_C),
      .rd_in(rd_C),
      .rd_out(rd_WB),
      .result_out(result_WB),
      // CTRL signals
      .result_src_in(result_src_C),
      .reg_write_in(reg_write_C),
      .reg_write_out(reg_write_WB)
  );

  forward forward_unit (
      .rs1_A_in(rs1_A),
      .rs2_A_in(rs2_A),
      .rd_C_in(rd_C),
      .rd_WB_in(rd_WB),
      .reg_write_C_in(reg_write_C),
      .reg_write_WB_in(reg_write_WB),
      .fwd_src1_out(fwd_src1_A),
      .fwd_src2_out(fwd_src2_A)
  );

  hazard hazard_unit (
      .rs1_D_in(rs1_D),
      .rs2_D_in(rs2_D),
      .rd_A_in(rd_A),
      .result_src_A_in(result_src_A),
      .icache_ready_in(icache_ready),
      .dcache_ready_in(dcache_ready),
      .pc_src_A_in(pc_src_A_F),
      .stall_F_out(stall_F),
      .stall_D_out(stall_D),
      .flush_D_out(flush_D),
      .flush_A_out(flush_A),
      .stall_C_out(stall_C),
      .stall_A_out(stall_A),
      .flush_WB_out(flush_WB)

  );

  arbiter arb (
      .clk(clk),
      .reset(reset),
      .ireq(arb_req_icache),
      .dreq(arb_req_dcache),
      .igrant(igrant),
      .dgrant(dgrant),
      .mem_req(mem_req)
  );
endmodule
