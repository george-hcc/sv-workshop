module sad_dpath
  (
    input  logic        clk_i,
    input  logic        rst_n_i,
    input  logic        enb_i,
    input  logic        restart_flag_i,
    input  logic        pre_sum_flag_i,
    input  logic        output_flag_i,
    input  logic        busy_i,
    input  logic [7:0]  dta_i,
    input  logic [7:0]  dtb_i,
    output logic [7:0]  index_o,
    output logic [31:0] dt_o
  );

  logic [31:0]  sum_r;
  logic [8:0]   difference_w;
  logic [8:0]   abs_w;
  logic [8:0]   abs_r;

  assign difference_w = dta_i - dtb_i;
  assign abs_w = (difference_w[8]) ? (-difference_w) : (difference_w);

  always_ff @(posedge clk_i)
  begin
    if(pre_sum_flag_i)
      abs_r <= abs_w;
  end
  
  always_ff @(posedge clk_i)
  begin
    if(restart_flag_i)
    begin
      sum_r <= 32'h0000_0000;
      index_o <= 8'h00;
    end
    else if(busy_i)
    begin
      sum_r <= sum_r + abs_r;
      index_o <= index_o + 1'b1;
    end
  end

  always_ff @(posedge clk_i, negedge rst_n_i)
  begin
    if(!rst_n_i)
      dt_o <= 32'h0000_0000;
    else if(output_flag_i)
      dt_o <= sum_r;
  end

endmodule

