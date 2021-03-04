module sqrt_proc
  (
    input  logic        clk_i,
    input  logic        busy_i,
    input  logic [7:0]  dt_i,
    output logic        s_less_than_dt_o,
    output logic [7:0]  dt_o
  );

  logic [5:0] d_init_w;
  logic [5:0] d_r;
  logic [5:0] d_next_w;
  logic [8:0] s_init_w;
  logic [8:0] s_r;
  logic [8:0] s_next_w;
  logic [7:0] dt_r;

  assign d_init_w = 5'h00;
  assign d_next_w = d_r + 2;
  assign s_init_w = 8'h01;
  assign s_next_w = s_r + d_r + 3;

  // Armazena o valor de dt_i na subida da flag busy_i
  always_ff @(posedge busy_i)
    dt_r <= dt_i;

  // Lógica sequencial de iterações de d e s
  always_ff @(posedge clk_i) 
  begin
    if(!busy_i) 
    begin
      d_r <= d_init_w;
      s_r <= s_init_w;
    end
    else
    begin
      d_r <= d_next_w;
      s_r <= s_next_w;
    end
  end

  // Flag necessária para controle
  assign s_less_than_dt_o = (s_next_w <= dt_i);

  // Saída do sistema
  assign dt_o = (dt_r == 8'h00) ? (8'h00) : (d_r >> 1);

endmodule