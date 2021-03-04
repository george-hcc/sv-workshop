module tb();
  
  logic clk;
  logic enb;
  logic [7:0] data_in;
  logic busy;
  logic [7:0] data_out;

  int n_erros;
  int n_testes;
  
  sqrt SQRT
  (
    .clk_i    (clk),
    .enb_i    (enb),
    .dt_i     (data_in),
    .busy_o   (busy),
    .dt_o     (data_out)
  );
  
  initial begin
    initiate;
    $display("###INICIALIZANDO TESTES###");
    for(int i = 0; i < 256; i++) begin
      test_sqrt(i);
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
    enb = 1'b0;
    toggle_clk(1);
    enb = 1'b1;
  endtask

  task test_sqrt(int x);
    wait(!busy);
    data_in = x;
    toggle_clk(1);
    while(busy)
      toggle_clk(1);
    check_error(x);
  endtask

  task check_error(int x);
    int reff;
    reff = $floor($sqrt($itor(x)));
    if(reff != data_out)
    begin
      $display("#ERRO: dt_i = %d, dt_o = %d, reff = %f", data_in, data_out, reff);
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