module shiftregister (clk, reset, serial_in, sr_out, ready);
  input				clk, reset, serial_in;
  output	[4:0]	sr_out;
  output 			ready;
  
  logic 	[3] 	count = 0;
  logic				controlled_clk;
  
  assign ready = (count == 5);
  assign controlled_clk = clk && !ready;
  
  always @(posedge clk or posedge reset) begin
    if (reset)
      count <= 0;
    else if (count == 5)
      ;
    else
      count <= count + 1;    
  end
  
  flipflop f0 (.clk(controlled_clk),
               .reset(reset),
               .d(serial_in),
               .q(sr_out[0]));
  
  flipflop f1 (.clk(controlled_clk),
               .reset(reset),
               .d(sr_out[0]),
               .q(sr_out[1]));
  
  flipflop f2 (.clk(controlled_clk),
               .reset(reset),
               .d(sr_out[1]),
               .q(sr_out[2]));
  
  flipflop f3 (.clk(controlled_clk),
               .reset(reset),
               .d(sr_out[2]),
               .q(sr_out[3])); 
  
  flipflop f4 (.clk(controlled_clk),
               .reset(reset),
               .d(sr_out[3]),
               .q(sr_out[4]));  
  
endmodule
