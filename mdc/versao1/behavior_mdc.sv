module mdc
  (
    input  logic        clk_i,
    input  logic        rst_n_i,
    input  logic        enb_i,
    input  logic [7:0]  dtx_i,
    input  logic [7:0]  dty_i,
    output logic [7:0]  dt_o
  );

  logic [7:0] dtx;
  logic [7:0] dtx_next;
  logic [7:0] dty;
  logic [7:0] dty_next;
  logic [2:0] k;

  logic       reset_flag;
  logic       both_odd;
  logic       both_even;
  logic       both_equal;
  logic       x_zero;
  logic       y_zero;
  logic       x_greater;

  assign both_odd   = dtx[0] && dty[0];
  assign both_even  = !dtx[0] && !dty[0];
  assign both_equal = dtx == dty;
  assign x_zero     = (dtx_i == 8'h00);
  assign y_zero     = (dty_i == 8'h00);
  assign x_greater  = dtx >= dty;

  // Lógica de flag de reset usada para pegar valor inicial das iterações
  always_ff @(posedge clk_i, negedge rst_n_i)
  begin
    if(!rst_n_i)
      reset_flag = 1'b1;
    else if(enb_i)
      reset_flag = 1'b0;
  end

  // Lógica combinacional de dtx_next
  always_comb begin
    dtx_next = dtx;
    if(!both_equal && !x_zero && !y_zero)
    begin
      if(both_odd && x_greater)
        dtx_next = (dtx + ~dty + 1) >> 1;
      else if(!dtx[0])
        dtx_next = dtx >> 1;
    end
  end

  // Definição de dty_next
  always_comb begin
    dty_next = dty;
    if(!both_equal && !x_zero && !y_zero)
    begin
      if(both_odd && !x_greater)
        dty_next = (dty + ~dtx + 1) >> 1;
      else if(!dty[0])
        dty_next = dty >> 1;
    end
  end

  // Lógica sequencial de dtx
  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if(!rst_n_i)
      dtx <= 8'h00;
    else
      dtx <= (reset_flag) ? (dtx_i) : (dtx_next);
  end

  // Lógica sequencial de dty
  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if(!rst_n_i)
      dty <= 8'h00;
    else
      dty <= (reset_flag) ? (dty_i) : (dty_next);
  end

  // Definição de k. Usado para calcular a saída
  always_ff @(posedge clk_i, negedge rst_n_i)
  begin
    if(!rst_n_i)
      k <= 3'h0;
    else if(enb_i && both_even && !both_equal)
      k <= k + 1;
  end

  // Lógica sequencial de saída
  always_ff @(posedge clk_i, negedge rst_n_i)
  begin
    if(x_zero)
      dt_o <= dty;
    else if(y_zero)
      dt_o <= dtx;
    else if(enb_i && both_equal)
      dt_o <= dtx << k;
  end

endmodule