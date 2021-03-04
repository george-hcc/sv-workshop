// Testbench
module tb #(parameter SEED = 42);
  
  logic 		clk, reset, ready;
  logic [7:0]	mixed_array[8];
  logic [7:0]	sorted_array[8];
  
  // Instantiate device under test
  parallelsort PS(.clk(clk),
                  .reset(reset),
                  .mixed_array(mixed_array), 
                  .sorted_array(sorted_array), 
                  .ready(ready));
  
  initial begin
    // Dump waves
    $dumpfile("tb.vcd");
    $dumpvars(1, test);

    clk = 0;
    reset = 1;
    toggle_clk(1);
    $srandom(SEED);
    test_loop();
    $finish();
  end
  
  task toggle_clk(int n_of_clocks);
    for(int i = 0; i < n_of_clocks; i++) begin
      #10 clk = ~clk;
      #10 clk = ~clk;
    end
  endtask
  
  task test_loop();
  	for(int i = 1; i <= 10; i++) begin
      #1 reset = 0;
      $display("**********TESTE #%0d**********", i);
      $display("\nArray de Entrada (desorganizada):\n");
      for(int j = 0; j < 8; j++) begin
        #1 mixed_array[j] = $urandom_range(255,0);
        $display("%d\t", mixed_array[j]);
      end
      toggle_clk(8);
      $display("\nArray Organizada (depois de 8 clocks):\n");
      for(int j = 0; j < 8; j++)
        $display("%d\t", sorted_array[j]);
      $display("\n");
      reset = 1;
    end
  endtask
  
endmodule