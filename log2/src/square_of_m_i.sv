module square_of_m_i(m_i, m_i_squared, multip_carry);
  input 	[0:-7]	m_i;
  output 	[0:-7]	m_i_squared;
  output 			multip_carry;
  
  logic		[1:-14] complete_square;
  
  assign complete_square = m_i * m_i;
  assign m_i_squared = complete_square[0:-7];
  assign multip_carry = complete_square[1];
  
endmodule
