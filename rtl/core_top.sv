`include "brisc_pkg.svh"

module core_top
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset
);

    logic req;
    logic req_store;
    logic [ADDRESS_WIDTH-1:0] req_address;
    logic [CACHE_LINE_WIDTH-1:0] req_evict_data;
    logic [CACHE_LINE_WIDTH-1:0] fill_data;
    logic [ADDRESS_WIDTH-1:0] fill_address;
    logic fill;

  core brisc_core (
      .clk(clk),
      .reset(reset),

      .mem_fill_data(fill_data),
      .mem_fill_addr(fill_address),
      .mem_fill_valid(fill),

      .mem_req(req),
      .mem_store(req_store),
      .mem_addr(req_address),
      .mem_data(req_evict_data)
  );

  memory mem (
    .clk(clk),
    .req(req),
    .req_store(req_store),
    .req_address(req_address),
    .req_evict_data(req_evict_data),

    .fill_data(fill_data),
    .fill_address(fill_address),
    .fill(fill)
  );

endmodule
