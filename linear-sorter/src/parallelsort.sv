`include "parallel_to_serial.sv"
`include "first8bitcell.sv"
`include "smart8bitcell.sv"

module parallelsort (clk, reset, mixed_array, sorted_array, ready);
  input 		    clk, reset;
  input		[7:0]	mixed_array[8];
  output 	[7:0]	sorted_array[8];
  output 		    ready;
  
  logic [7:0]	w_is_empty, w_is_pushing;
  logic [7:0] 	w_cell_data[8];

  // Desliga o clock das células quando a organização for concluida
  logic	controlled_clk;
  assign controlled_clk = clk && ~ready;
  
  // Output Ready = 1 quando todas as celulas forem preenchidas
  assign ready = reset ? 1'b0 : ~(|w_is_empty);
  
  // Fornece entrada serial para as celulas a partir de uma array
  logic [7:0] w_serial_in;
  parallel_to_serial pts (.clk(controlled_clk),
                          .reset(reset),
                          .mixed_array(mixed_array),
                          .serial(w_serial_in));
  
  // 8 celulas de memória de 8bits conectadas em cascata  
  genvar i;
  generate
    for(i = 0; i < 8; i++) begin: smart_cells
      if(i == 0) begin
        first8bitcell (.clk(controlled_clk),
                      .reset(reset),
                      .new_data(w_serial_in),
                      .is_empty(w_is_empty[i]),
                      .is_pushing(w_is_pushing[i]),
                      .cell_data(w_cell_data[i]));
      end
      else begin
        smart8bitcell (.clk(controlled_clk),
                       .reset(reset),
                       .prev_is_empty(w_is_empty[i-1]),
                       .prev_is_pushing(w_is_pushing[i-1]),
                       .prev_cell_data(w_cell_data[i-1]),
                       .new_data(w_serial_in),
                       .is_empty(w_is_empty[i]),
                       .is_pushing(w_is_pushing[i]),
                       .cell_data(w_cell_data[i]));
      end
    end
  endgenerate
  
  assign sorted_array = w_cell_data;
endmodule