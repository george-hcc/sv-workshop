module memx_proc
  #(
    parameter RAM_DATA_WIDTH = 16,
    parameter RAM_ADDR_WIDTH = 10
  )(
    // Interface de entrada e saídas externas
    input  logic                      clk_i,
    input  logic                      memc_wd_i,
    input  logic [RAM_ADDR_WIDTH-1:0] memc_addr_i,
    input  logic [RAM_DATA_WIDTH-1:0] memc_wdt_i,
    output logic [RAM_DATA_WIDTH-1:0] memc_rdt_o,
    // Interface com o modelo de memória
    input  logic [RAM_DATA_WIDTH-1:0] data_i,
    output logic [RAM_ADDR_WIDTH-1:0] addr_o,
    output logic [RAM_DATA_WIDTH-1:0] data_o
  );

  always_ff @(posedge clk_i)
  begin
    addr_o <= memc_addr_i;
    data_o <= memc_wdt_i;
    wr_i <= memc_wd_i;
    memc_rdt_o <= data_i;
  end

endmodule