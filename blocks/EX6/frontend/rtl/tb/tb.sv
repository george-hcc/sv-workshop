module tb();

  //Parametros
  parameter RAM_DATA_WIDTH = 16;
  parameter RAM_ADDR_WIDTH = 10;
  parameter RAM_N_OF_WORDS = 256;
  
  logic                       clk;
  logic [1:0]                 clk_div;
  logic                       rstn;
  //Interface TB-MEMC
  logic                       mem_rd_w;
  logic                       mem_wr_w;
  logic [RAM_ADDR_WIDTH-1:0]  mem_addr_w;
  logic [RAM_DATA_WIDTH-1:0]  mem_wdt_w;
  logic                       mem_busy_w;
  logic [RAM_DATA_WIDTH-1:0]  mem_rdt_w;
  logic                       mem_wok_w;

  //Interface MEMC-MEM
  logic                       wr_w;
  logic [RAM_ADDR_WIDTH-1:0]  addr_w;
  logic [RAM_DATA_WIDTH-1:0]  rdata_w;
  logic                       busy_mem_w;
  logic [RAM_DATA_WIDTH-1:0]  wdata_w;


  //Estatisticas de teste
  int n_erros;
  int n_testes;

  always_ff @(posedge clk) clk_div += 1;
  
  memx
  #(
    .RAM_DATA_WIDTH(),
    .RAM_ADDR_WIDTH(),
    .RAM_N_OF_WORDS()
  )CONTROLLER(
    .clk_i              (clk),
    .rst_n_i            (rstn),
    .mem_rd_i           (mem_rd_w),
    .mem_wr_i           (mem_wr_w),
    .mem_addr_i         (mem_addr_w),
    .mem_wdt_i          (mem_wdt_w),
    .mem_busy_o         (mem_busy_w),
    .mem_rdt_o          (mem_rdt_w),
    .mem_wok_o          (mem_wok_w),
    .data_i             (rdata_w),
    .wr_o               (wr_w),
    .addr_o             (addr_w),
    .data_o             (wdata_w)
  );

  mem_model
  #(
    .RAM_DATA_WIDTH(),
    .RAM_ADDR_WIDTH(),
    .RAM_N_OF_WORDS()
  )MEMORY(
    .clk_i               (clk_div[1]),
    .wr_i                (wr_w),
    .addr_i              (addr_w),
    .data_i              (wdata_w),
    .data_o              (rdata_w)
  );
  
  initial begin
    initiate;
    mem_wr_w = 1'b1;
    mem_rd_w = 1'b0;
    mem_addr_w = 10'h000;
    mem_wdt_w = 16'h1010;
    toggle_clk(10);
    while(mem_busy_w)
      toggle_clk(1);
    mem_addr_w++;
    mem_wdt_w = mem_wdt_w * 3;
    toggle_clk(10);
    while(mem_busy_w)
      toggle_clk(1);
    mem_addr_w++;
    mem_wdt_w = mem_wdt_w * 3;
    toggle_clk(10);
    while(mem_busy_w)
      toggle_clk(1);
    mem_wr_w = 1'b0;
    mem_rd_w = 1'b1;
    mem_addr_w = 10'h000;
    toggle_clk(10);
    while(mem_busy_w)
      toggle_clk(1);
    $finish;
  end
  
  task initiate;
    n_erros = 0;
    n_testes = 0;
    clk = 1'b0;
    clk_div = 2'h0;
    rstn = 1'b0;
    toggle_clk(2);
    rstn = 1'b1;
    toggle_clk(2);
  endtask
  
  task toggle_clk(input int n);
    for(int i = 0; i < n; i++) 
    begin
      #250ns clk = !clk;
      #250ns clk = !clk;
    end
  endtask
  
endmodule