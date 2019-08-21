module tb();
  
  logic         clk;
  logic         rst_n;
  logic         enb;
  logic [7:0]   data_a;
  logic [7:0]   data_b;
  logic         busy;
  logic [31:0]  data_out;

  int n_erros;
  int n_testes;
  
  sad SAD
  (
    .clk_i    (clk),
    .rst_n_i  (rst_n),
    .enb_i    (enb),
    .dta_i    (data_a),
    .dtb_i    (data_b),
    .busy_o   (busy),
    .dt_o     (data_out)
  );
  
  initial begin
    initiate;
    $display("###INICIALIZANDO TESTES###");
    for(int i = 0; i < 1000; i++) begin
      test_sad(i);
      n_testes++;
    end
    $display("######FIM DE TESTES$######");
    $display("Número de Testes:\t%d", n_testes);
    $display("Número de Erros:\t%d", n_erros);
    $finish;
  end
  
  task initiate;
    n_erros = 0;
    n_testes = 0;
    clk = 1'b0;
    rst_n = 1'b0;
    enb = 1'b1;
    toggle_clk(1);
    rst_n = !rst_n;
    toggle_clk(1);
  endtask

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
  
  task toggle_clk(input int n);
    for(int i = 0; i < n; i++) 
    begin
      #1 clk = !clk;
      #1 clk = !clk;
    end
  endtask
  
endmodule