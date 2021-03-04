module flipflop (clk, reset, d, q);
  input			clk, reset, d;
  output logic	q;
  
  always_ff @(posedge clk) begin
    if (reset)
      q <= 0;
    else
      q <= d;
  end
  
endmodule