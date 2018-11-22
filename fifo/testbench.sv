module testbench #(parameter SEED = 17)();
  
  logic clk, reset;
  integer src_delay, snk_delay;
  
  valid_ready putBus();
  valid_ready getBus();

  source src
  (
    .clk		  (clk          	),
    .reset		(reset		    	),
    .delay		(src_delay    	),    
    .vrBus		(putBus.Master 	)
  );
  
  sink snk
  (
    .clk			(clk         		),
    .reset		(reset        	),
    .delay		(snk_delay			),    
    .vrBus		(getBus.Slave 	)
  );

  FIFO FIFO
  (
    .clk      (clk            ),
    .reset    (reset          ),
    .putBus   (putBus.Slave   ),
    .getBus   (getBus.Master  )
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
    if((putBus.valid && putBus.ready) || ~reset)
      src_delay <= $urandom_range(5, 0);
    if((getBus.valid && getBus.ready) || ~reset)  
      snk_delay <= $urandom_range(5, 0);
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

