module mem_model
  #(
    parameter RAM_DATA_WIDTH = 16,
    parameter RAM_ADDR_WIDTH = 10,
    parameter RAM_N_OF_WORDS = 256
  )(
    input  logic                       clk_i,
    input  logic                       wr_i,
    input  logic [RAM_ADDR_WIDTH-1:0]  addr_i,
    input  logic [RAM_DATA_WIDTH-1:0]  data_i,
    output logic [RAM_DATA_WIDTH-1:0]  data_o
  );

  logic [RAM_DATA_WIDTH-1:0] data_vector [RAM_N_OF_WORDS];
  logic [RAM_ADDR_WIDTH-1:0] addr_r;

  always_ff @(posedge clk_i)
  begin
    addr_r <= addr_i;
    data_o <= #(20us:60us:100us) data_vector[addr_r];
    if(wr_i) 
      data_vector[addr_r] <= #(5ms:10ms:15ms) data_i;
  end

endmodule

