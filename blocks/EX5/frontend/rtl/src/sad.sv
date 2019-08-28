module sad
  (
    input  logic        clk_i,
    input  logic        rst_n_i,
    input  logic        enb_i,
    input  logic [7:0]  dta_i,
    input  logic [7:0]  dtb_i,
    output logic        busy_o,
    output logic [31:0] dt_o
  );

  logic       gated_clock_w;
  logic       restart_flag_w;
  logic       pre_sum_flag_w;
  logic       output_flag_w;
  logic [7:0] index_w;

  assign gated_clock_w = clk_i && enb_i;

  sad_cpath CTRL_PATH
  (
    .clk_i          (gated_clock_w),
    .rst_n_i        (rst_n_i),
    .enb_i          (enb_i),
    .index_i        (index_w),
    .restart_flag_o (restart_flag_w),
    .pre_sum_flag_o (pre_sum_flag_w),
    .output_flag_o  (output_flag_w),
    .busy_o         (busy_o)
  );

  sad_dpath DATA_PATH
  (
    .clk_i          (gated_clock_w),
    .rst_n_i        (rst_n_i),
    .enb_i          (enb_i),
    .restart_flag_i (restart_flag_w),
    .pre_sum_flag_i (pre_sum_flag_w),
    .output_flag_i  (output_flag_w),
    .busy_i         (busy_o),
    .dta_i          (dta_i),
    .dtb_i          (dtb_i),
    .index_o        (index_w),
    .dt_o           (dt_o)
  );

endmodule