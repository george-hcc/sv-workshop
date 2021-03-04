module first8bitcell (clk, reset, new_data, is_empty, 
                      is_pushing, cell_data);
  
  input 				clk, reset;
  input 		[7:0]   new_data;
  output logic			is_empty, is_pushing;
  output logic 	[7:0]	cell_data;
  
  logic new_data_is_smaller;
  assign new_data_is_smaller = new_data < cell_data;
  
  assign is_pushing = new_data_is_smaller && !is_empty;
    
  always_ff @(posedge clk, posedge reset) begin 
    if(reset)
      is_empty <= 1;
    else if(is_empty) begin
      cell_data <= new_data;
      is_empty <= 0;
    end
    else if(new_data_is_smaller)
      cell_data <= new_data;
  end
  
endmodule