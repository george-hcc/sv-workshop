// Testbench
module tb #(parameter SEED = 2);
  
  logic			clk, serial_in;
  logic 		sqce_found;
  logic [3:0] 	bit_sequence;
  
  // Instantiate device under test
  fourbitfinder FBF(.clk(clk),
                    .serial_in(serial_in),
                    .bit_sequence(bit_sequence),
                    .sqce_found(sqce_found));
  
  initial begin
    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars(1, tb);

    clk = 0;
    serial_in = 0;
    $srandom(SEED);
    
    for(int j = 1; j <= 5; j++) begin
      bit_sequence = $urandom_range(15,0);
      $display("*********TESTE #%0d*********\n", j);
      $display("Sequencia a ser encontrada: %b\n", bit_sequence);
      for(int i = 0; i < 50; i++) begin
        serial_in = $urandom_range(1, 0);
        toggle_clk(1);
        $display("Ciclo #%2d: d = %0h, sqce_found = %0h", i, serial_in, sqce_found);
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