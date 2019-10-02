
//                              -*- Mode: Verilog -*-
// Filename        : memx.sv
// Description     : Topo de um controlador de memória (exercicio)
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
    input  logic 	                    mem_rd_i,
    input  logic 	                    mem_wr_i,
    input  logic [RAM_ADDR_WIDTH-1:0] mem_addr_i,
    input  logic [RAM_DATA_WIDTH-1:0] mem_wdt_i,
    output logic                      mem_busy_o,
    output logic [RAM_DATA_WIDTH-1:0] mem_rdt_o,
    output logic 	                    mem_wok_o,
    // Interface com o modelo de memória
    input  logic                      busy_mem_i,
    input  logic [RAM_DATA_WIDTH-1:0] data_i,
    output logic                      wr_o,
    output logic [RAM_ADDR_WIDTH-1:0] addr_o,
    output logic [RAM_DATA_WIDTH-1:0] data_o
  );

   memx_ctrl 
   #(
    .RAM_ADDR_WIDTH(),
    .RAM_N_OF_WORDS()
   )CTRL(
    .clk_i        (clk_i),
    .mem_rd_i     (mem_rd_i),
    .mem_wr_i     (mem_wr_i),
    .mem_addr_i   (mem_addr_i),
    .busy_mem_i   (busy_mem_i),
    .mem_busy_o   (mem_busy_o),
    .mem_wok_o    (mem_wok_o)
   );

   memx_proc 
   #(
    .RAM_DATA_WIDTH(),
    .RAM_ADDR_WIDTH()
   )PROC(
    .clk_i        (clk_i),
    .mem_wr_i     (mem_wr_i),
    .mem_addr_i   (mem_addr_i),
    .mem_wdt_i    (mem_wdt_i),
    .mem_rdt_o    (mem_rdt_o),
    .data_i       (data_i),
    .addr_o       (addr_o),
    .data_o       (data_o),
    .wr_o         (wr_o)
   );   

endmodule // memx
