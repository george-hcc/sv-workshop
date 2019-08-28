module mysqrt
  (
    input  logic        clk_i,
    input  logic        rst_n_i,
    input  logic        enb_i,
    input  logic [7:0]  dt_i,
    output logic [7:0]  dt_o
  );

  logic [5:0] d_init;
  logic [5:0] d;
  logic [5:0] d_next;
  logic [8:0] s_init;
  logic [8:0] s;
  logic [8:0] s_next;
  logic [7:0] r;
  logic       s_less_dt;

  assign d_init = 5'h00;
  assign d_next = d + 2;
  assign s_init = 8'h01;
  assign s_next = s + d + 3;
  assign s_less_dt = (s <= dt_i);

  always_ff @(posedge clk_i, negedge rst_n_i) 
  begin
    if(!rst_n_i) 
    begin
      d <= d_init;
      s <= s_init;
    end
    else if(enb_i && s_less_dt) 
    begin
      d <= d_next;
      s <= s_next;
    end
  end

  assign r = d >> 1;

  always_ff @(posedge clk_i)
    if(enb_i)
      dt_o <= r;

endmodule