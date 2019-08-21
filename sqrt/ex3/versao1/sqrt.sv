module sqrt
  (
    input  logic        clk_i,
    input  logic        rst_n_i,
    input  logic        enb_i,
    input  logic [7:0]  dt_i,
    output logic        busy_o,
    output logic [7:0]  dt_o
  );

  logic clk_gated_w;
  logic s_less_than_dt_w;

  assign clk_gated_w = clk_i && enb_i;

  sqrt_ctrl SQRT_CTRL
  (
    .clk_i              (clk_gated_w      ),
    .rst_n_i            (rst_n_i          ),
    .s_less_than_dt_i   (s_less_than_dt_w ),
    .busy_o             (busy_o           )
  );

  sqrt_proc SQRT_PROC 
  (
    .clk_i              (clk_gated_w      ),
    .busy_i             (busy_o           ),
    .dt_i               (dt_i             ),
    .s_less_than_dt_o   (s_less_than_dt_w ),
    .dt_o               (dt_o             )
  );

endmodule

