// Testbench
module tb #(parameter SEED = 9);
  // y = log2(x)
  logic [7:0]	int_in;
  logic [2:-5]	fixed_point_out;
  bit	 		zeroflag, clk;
  
  real display_fixedpoint;
  assign display_fixedpoint = real'(fixed_point_out) / 32;
  
  // Instantiate device under test
  log2 lg(.fixed_point_out(fixed_point_out),
          .zeroflag(zeroflag),
          .ready(ready),
    	  .int_in(int_in),
          .clk(clk));
  
  initial begin
    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars(1, tb);
    
    clk = 0;
    int_in = 0;
    $display("*****VALORES INICIAIS PRÉ CLOCK*****");
    $display("x = %0d, log2(x) = %b, zeroflag = %b, ready = %b", int_in, fixed_point_out, zeroflag, ready);
    toggle_clk(1);
    $srandom(SEED);
    
    for(int j = 0; j < 20; j++) begin
      $display("*****TESTE #%0d*****", j);
      int_in = $urandom_range(255,0);    
      for(int i = 0; i < 6; i++) begin
        toggle_clk(1);
        $display("Clock #%0d: x = %0d, log2(x) = %0f, zeroflag = %b, ready = %b", i, int_in, display_fixedpoint, zeroflag, ready);
      end
    end
    
  end
  
  task toggle_clk(int n_of_clocks);
    for(int i = 0; i < n_of_clocks; i++) begin
      #10 clk = ~clk;
      #10 clk = ~clk;
    end
  endtask
  
endmodule