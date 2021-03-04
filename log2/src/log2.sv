`include "log2_m.sv"
`include "square_of_m_i.sv"
`include "shiftregister.sv"
`include "flipflop.sv"

module log2 (clk, int_in, fixed_point_out, zeroflag, ready);
  input				clk;
  input 	[7:0] 	int_in;
  output	[2:-5] 	fixed_point_out;
  output 			zeroflag, ready;

  logic 	[2:0] 	expoent;
  logic 	[-1:-5] mantissa;
  logic		[7:0] 	comparation_input;
  logic				reset, zeroflag_clk;

  // Zeroflag alerta entrada invalida x = 0
  assign zeroflag = int_in ? 0 : 1;
  
  // Saída log2(x) = e + log2(m)
  assign fixed_point_out = {expoent, mantissa};
  
  // Reset ativo quando detectada mudança em entrada int_in
  assign reset = !(comparation_input == int_in);
  
  // Cancela o cálculo de log se a entrada for zero
  assign zeroflag_clk = clk && !zeroflag;
  
  // Circuito Combinacional para encontrar o Expoente
  always_comb begin
    if (zeroflag)
      ;
    else begin
      priority casez (int_in)
        8'b1???_????: 	expoent = 3'd7;
        8'b01??_????: 	expoent = 3'd6;
        8'b001?_????: 	expoent = 3'd5;
        8'b0001_????: 	expoent = 3'd4;
        8'b0000_1???: 	expoent = 3'd3;
        8'b0000_01??: 	expoent = 3'd2;
        8'b0000_001?:	expoent = 3'd1;
        default: 		expoent = 3'd0;
      endcase
    end    
  end
  
  // Registrador que armazena int_in para detecção de mudança
  always @(posedge clk) begin
		comparation_input <= int_in;
  end
  
  log2_m log2_m(.clk(zeroflag_clk),
                .reset(reset),
                .m(int_in << (7 - expoent)),
                .mantissa(mantissa),
                .ready(ready));
endmodule
