// Modulo para encontrar a parte fracionária do log2 (mantissa)
module log2_m (clk, reset, m, mantissa, ready);
  input	 			clk, reset;
  input 	[0:-7] 	m;
  output 	[-1:-5] mantissa;
  output			ready;

  logic 	[7:0]	m_i, next_m_i;
  logic 	[7:0]	m_i_squared;
  logic				squared_above2;

  // Registrador Iterativo
  always @(posedge clk) begin
    if (reset)
	  m_i <= m;
	else
	  m_i <= next_m_i;
  end

  // MUX para selecionar valor de next_m_i
  always_comb begin
    if (squared_above2)
      next_m_i = {squared_above2, m_i_squared} >> 1;
	else
	  next_m_i = m_i_squared;
	end
  
  // Modulo para encontrar m_i ao quadrado
  square_of_m_i somi(.m_i(m_i),
                	 .m_i_squared(m_i_squared),
                	 .multip_carry(squared_above2));

  // Registrador de Deslocamento, armazena saída log2(m)
  shiftregister sr (.clk(clk),
                    .reset(reset),
                    .serial_in(squared_above2),
                    .sr_out(mantissa),
                    .ready(ready));

endmodule
