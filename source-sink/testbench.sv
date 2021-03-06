module testbench #(parameter SEED = 17)();
  
  logic clk, reset;
  integer src_delay, snk_delay;
  
  valid_ready vrBus();

  source src
  (
    .clk		  (clk          ),
    .reset		(reset		    ),
    .delay		(src_delay    ),    
    .vrBus		(vrBus.Master )
  );
  
  sink snk
  (
    .clk		  (clk          ),
    .reset		(reset        ),
    .delay		(snk_delay		),    
    .vrBus		(vrBus.Slave  )
  );
  
  task initiate();
    $srandom(SEED);
    clk 		  = 'b0;
    reset 		= 'b0;
    #1 reset	= 'b1;
  endtask
  
  always begin
    #5 clk = ~clk;
  end

  always_ff @(posedge clk, negedge reset) begin
    if((vrBus.valid && vrBus.ready) || ~reset) begin
      snk_delay <= $urandom_range(5, 0);
      src_delay <= $urandom_range(5, 0);
    end
  end
  
  initial begin
    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars(1, testbench);

    initiate();    
    for(int i = 1; i <= 100; i++) #10;
  	$finish;
  end
  
endmodule

