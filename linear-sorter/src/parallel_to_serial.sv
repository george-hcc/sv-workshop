module parallel_to_serial (clk, reset, mixed_array, serial);
  input 		clk, reset;
  input [7:0] 	mixed_array[8];
  output [7:0]	serial;
  
  //Contador de iterações
  logic	[2:0]	count;
  always_ff @(posedge clk, posedge reset) begin
    if(reset)
      count <= 0;
    else if (count == 3'b111)
      count <= count;
    else
      count <= count + 1;
  end
  
  //Transforma entrada paralela em serial
  assign serial = mixed_array[count];
  
endmodule