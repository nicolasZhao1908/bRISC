`include "brisc_pkg.svh"

module hazard
  import brisc_pkg::*;
(
    input logic [REG_BITS-1:0] rs1_EX_in,
    input logic [REG_BITS-1:0] rs2_EX_in,
    input logic [REG_BITS-1:0] rs1_D_in,
    input logic [REG_BITS-1:0] rs2_D_in,
    input logic [REG_BITS-1:0] rd_EX_in,
    input logic [REG_BITS-1:0] rd_C_in,
    input logic [REG_BITS-1:0] rd_WB_in,
    input logic reg_write_C_in,
    input logic reg_write_WB_in,
    input result_src_e result_src_EX_in,
    input pc_src_e pc_src_in,
    output fwd_src_e fwd_src1_out,
    output fwd_src_e fwd_src2_out,
    output stall_F_out,
    output stall_D_out,
    output flush_D_out,
    output flush_EX_out
);

  logic load_stall_w;
  logic pc_taken_w;

  always_comb begin

    // Defaults
    assign fwd_src1_out = NONE;
    assign fwd_src2_out = NONE;
    assign stall_F_out = '0;
    assign stall_D_out = '0;
    assign flush_D_out = '0;
    assign flush_EX_out = '0;
    assign load_stall_w = '0;
    assign pc_taken_w = '0;

    // Forwarding C -> EX or WB -> EX
    if (((rs1_EX_in == rd_C_in) & reg_write_C_in) & (rs1_EX_in != 0)) begin
      assign fwd_src1_out = FROM_C;
    end else if (((rs1_EX_in == rd_WB_in) & reg_write_WB_in) & (rs1_EX_in != 0)) begin
      assign fwd_src1_out = FROM_WB;
    end else begin
      assign fwd_src1_out = NONE;
    end

    if (((rs2_EX_in == rd_C_in) & reg_write_C_in) & (rs2_EX_in != 0)) begin
      assign fwd_src2_out = FROM_C;
    end else if (((rs2_EX_in == rd_WB_in) & reg_write_WB_in) & (rs2_EX_in != 0)) begin
      assign fwd_src2_out = FROM_WB;
    end else begin
      assign fwd_src2_out = NONE;
    end

    // Stall if a previous load instr produces
    // the value to be consumed of the next instr
    assign load_stall_w = (result_src_EX_in == FROM_CACHE) &
                 ((rs1_D_in == rd_EX_in) | (rs2_D_in == rd_EX_in));
    assign stall_F_out = load_stall_w;
    assign stall_D_out = load_stall_w;

    // Flush on control hazard
    assign pc_taken_w = (pc_src_in == FROM_EX);
    assign flush_D_out = pc_taken_w;
    assign flush_EX_out = load_stall_w | pc_taken_w;
  end


endmodule
