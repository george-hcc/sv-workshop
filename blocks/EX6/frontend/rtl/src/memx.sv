//                              -*- Mode: Verilog -*-
// Filename        : memx.sv
// Description     : teste
// Author          : George Camboim
// Created On      : Sat Sep 21 17:43:52 2019
// Last Modified By: George Camboim
// Last Modified On: Sat Sep 21 17:43:52 2019
// Update Count    : 0
// Status          : Unknown, Use with caution!

module memx
  #(
    parameter RAM_DATA_WIDTH = 16,
    parameter RAM_ADDR_WIDTH = 10,
    parameter RAM_N_OF_WORDS = 256
  )(
    // Interface de entrada e saídas externas
    input  logic 	                    clk_i,
    input  logic 	                    memc_rd_i,
    input  logic 	                    memc_wd_i,
    input  logic [RAM_ADDR_WIDTH-1:0] memc_addr_i,
    input  logic [RAM_DATA_WIDTH-1:0] memc_wdt_i,
    output logic                      memc_busy_o,
    output logic [RAM_DATA_WIDTH-1:0] memc_rdt_o,
    output logic 	                    memc_wok_o,
    // Interface com o modelo de memória
    input  logic                      busy_mem_i,
    input  logic [RAM_DATA_WIDTH-1:0] data_i,
    output logic                      wr_o,
    output logic [RAM_ADDR_WIDTH-1:0] addr_o,
    output logic [RAM_DATA_WIDTH-1:0] data_o
  );

endmodule // memx



   
   
