module smart8bitcell (clk, reset, prev_is_empty, prev_is_pushing,
                      prev_cell_data, new_data, is_empty, 
                      is_pushing, cell_data);
  
  input 				clk, reset;
  input 				prev_is_empty, prev_is_pushing;
  input 		[7:0]   prev_cell_data, new_data;
  output logic			is_empty, is_pushing;
  output logic 	[7:0]	cell_data;
  
  logic new_data_is_smaller;
  assign new_data_is_smaller = new_data < cell_data;
  
  assign is_pushing = new_data_is_smaller && !is_empty;
  
  // Parametrização de Estados
  parameter [2:0]
    RESET           = 3'b1??,
  	CLEAN_CELL		= 3'b01?,
    TAKE_PREV       = 3'b001,
    CHECK_NEW      	= 3'b000;
  
  logic [2:0] case_vector;
  assign case_vector = {reset, prev_is_empty, prev_is_pushing};
  
  always_ff @(posedge clk, posedge reset) begin 
    casez(case_vector)
      RESET: begin
        is_empty <= 1;
      end
      CLEAN_CELL:
        is_empty <= 1;
      TAKE_PREV: begin
        cell_data <= prev_cell_data;
        if(is_empty)
          is_empty <= 0;
      end
      CHECK_NEW: begin
        if(is_empty) begin
          cell_data <= new_data;
          is_empty <= 0;
        end
        else if(new_data_is_smaller)
          cell_data <= new_data;
      end
    endcase
  end
  
endmodule