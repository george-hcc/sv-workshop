module flipflop
  (
  output logic	q,
  input			d,
  input			clk
  );  
  
  always_ff @(posedge clk)
    q <= d;
  
endmodule