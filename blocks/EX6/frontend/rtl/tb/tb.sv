module tb();

  //Parametros
  parameter RAM_DATA_WIDTH;
  parameter RAM_ADDR_WIDTH;
  parameter RAM_N_OF_WORDS;
  
  logic                       clk;
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
  
  module memx
  #(
    .RAM_DATA_WIDTH,
    .RAM_ADDR_WIDTH,
    .RAM_N_OF_WORDS
  )(
    .clk_i              (clk),
    .mem_rd_i           (mem_rd_w),
    .mem_wr_i           (mem_wr_w),
    .mem_addr_i         (mem_addr_w),
    .mem_wdt_i          (mem_wdt_w),
    .mem_busy_o         (mem_busy_w),
    .mem_rdt_o          (mem_rdt_w),
    .mem_wok_o          (mem_wok_w),
    .busy_mem_i         (busy_mem_w),
    .data_i             (rdata_w),
    .wr_o               (wr_w),
    .addr_o             (addr_w),
    .data_o             (wdata_w),
  );

  module mem_fpga
  #(
    ,RAM_DATA_WIDTH,
    ,RAM_ADDR_WIDTH,
    ,RAM_N_OF_WORDS
  )(
    clk_i               (clk),
    wr_i                (wr_w),
    addr_i              (addr_w),
    data_i              (wdata_w),
    busy_mem_o          (busy_mem_w),
    data_o              (rdata_w),
  );
  
  initial begin
    initiate;
    mem_wr_w = 1'b1;
    mem_rd_i = 1'b0;
    mem_addr_w = 10'h000;
    mem_wdt_w = 16'h1010;
    toggle_clk(10000);
    /*
    $display("###INICIALIZANDO TESTES###");
    for(int i = 0; i < 1000; i++) begin
      test_sad(i);
      n_testes++;
    end
    $display("######FIM DE TESTES$######");
    $display("Número de Testes:\t%d", n_testes);
    $display("Número de Erros:\t%d", n_erros);
    */
    $finish;
  end
  
  task initiate;
    n_erros = 0;
    n_testes = 0;
    clk = 1'b0;
    toggle_clk(1);
  endtask

/*
  task test_sad(int seed);
    int pixel_index;
    int pixel_array_a [0:255];
    int pixel_array_b [0:255];

    $srandom(seed);
    for(int i = 0; i < 256; i++)
    begin
      pixel_array_a[i] = $urandom_range(0, 255);
      pixel_array_b[i] = $urandom_range(0, 255);
    end

    pixel_index = 0;
    while(pixel_index < 255)
    begin
      data_a = pixel_array_a[pixel_index];
      data_b = pixel_array_b[pixel_index];
      while(!busy)
        toggle_clk(1);
      toggle_clk(1);
      pixel_index++;
    end

    toggle_clk(2);
    check_error(pixel_array_a, pixel_array_b);
  endtask

  task check_error(int pa_a [0:255], int pa_b [0:255]);
    int reff;
    reff = 0;
    for(int i = 0; i < 255; i++)
      reff = reff + $abs(pa_a[i] - pa_b[i]);
    if(reff != data_out)
    begin
      $display("#ERRO: data_out = %d, reff = %f", data_out, reff);
      n_erros++;
    end
  endtask
*/
  
  task toggle_clk(input int n);
    for(int i = 0; i < n; i++) 
    begin
      #1 clk = !clk;
      #1 clk = !clk;
    end
  endtask
  
endmodule