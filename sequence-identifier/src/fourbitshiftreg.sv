module fourbitshiftreg
  #(
    parameter SEQUENCE_SIZE = 4
  )(
    output [SEQUENCE_SIZE-1:0]	p_out,
  	input						s_in,
    input						clk
  );
  
  //Geração de N flip-flops em série
  genvar i;
  generate
    for(i = 0; i < SEQUENCE_SIZE; i++) begin: flipflops
      if(i == 0)
        flipflop ff[i] (.q(p_out[i]),
                        .d(s_in),
                        .clk(clk));
      else  
        flipflop ff[i] (.q(p_out[i]),
                        .d(p_out[i-1]),
                        .clk(clk));
    end
  endgenerate 
  
endmodule