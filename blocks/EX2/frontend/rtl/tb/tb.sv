module tb();
  
  logic clk;
  logic rst_n;
  logic enb;
  logic [7:0] data_x;
  logic [7:0] data_y;
  logic [7:0] data_out;

  int n_erros;
  int n_testes;
  
  mdc MDC
  (
    .clk_i    (clk),
    .rst_n_i  (rst_n),
    .enb_i    (enb),
    .dtx_i    (data_x),
    .dty_i    (data_y),
    .dt_o     (data_out)
  );
  
  initial begin
    initiate;
    $display("###INICIALIZANDO TESTES###");
    for(int i = 0; i < 256; i++) begin
      for(int j = 0; j < 256; j++) begin
        test_mdc(j, i);
        n_testes++;
      end
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
    enb = 1'b0;
    toggle_clk(1);
    rst_n = !rst_n;
    toggle_clk(1);
  endtask

  task test_mdc(int x, int y);
    enb = 1'b0;
    rst_n = !rst_n;
    toggle_clk(1);
    rst_n = !rst_n;
    enb = 1'b1;
    data_x = x;
    data_y = y;
    toggle_clk(16);
    check_error(x, y);
  endtask

  task check_error(int x, int y);
    int reff;
    reff = gcd_reff(x, y);
    if(reff != data_out)
    begin
      $display("#ERRO: dt_x = %d, dt_y = %d, dt_o = %d, reff = %f", data_x, data_y, data_out, reff);
      n_erros++;
    end
  endtask

  function int gcd_reff(int x, int y);
    int k;
    logic x_even, y_even;
    k = 0;
    if(x == 0)
      return y;
    if(y == 0)
      return x;
    while(x != y)
    begin
      x_even = (x % 2) == 0;
      y_even = (y % 2) == 0;
      if(!x_even && !y_even)
      begin
        if(x >= y)
          x = (x-y) / 2;
        else
          y = (y-x) / 2;
      end
      else
      begin
        if(x_even && y_even)
          k++;
        if(x_even)
          x = x / 2;
        if(y_even)
          y = y / 2;
      end
    end
    return x << k;
  endfunction
  
  task toggle_clk(int n);
    for(int i = 0; i < n; i++) 
    begin
      #1 clk = !clk;
      #1 clk = !clk;
    end
  endtask
  
endmodule