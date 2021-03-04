`include "fourbitshiftreg.sv"
`include "flipflop.sv"

module fourbitfinder
  #(
    parameter SEQUENCE_SIZE = 4
  )(
    output 						sqce_found,
    input						serial_in,
    input [SEQUENCE_SIZE-1:0]	bit_sequence,
    input						clk
  );
  
  //Registrador de deslocamento que armazena as ultimas quatro entradas
  logic [SEQUENCE_SIZE-1:0] shiftreg_out;
  fourbitshiftreg 	#(.SEQUENCE_SIZE(SEQUENCE_SIZE)) sr 
  					(.p_out(shiftreg_out),
                 	 .s_in(serial_in),
                     .clk(clk));
  
  //sqce_found = 1 quando as ultimas N entradas forem iguais a bit_sequence
  assign sqce_found = (bit_sequence == shiftreg_out);
  
endmodule