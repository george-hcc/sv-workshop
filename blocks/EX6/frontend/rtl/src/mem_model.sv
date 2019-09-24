module mem_fpga
  #(
    parameter RAM_DATA_WIDTH = 16,
    parameter RAM_ADDR_WIDTH = 10,
    parameter RAM_N_OF_WORDS = 256
  )(
    clk_i,
    wr_i,
    addr_i,
    data_i,
    busy_mem_o,
    data_o
  );

  // Referencia de contagem de worst case considerando clock de 500kHz
  localparam WORST_CASE_RD_CYCLES = 50;
  localparam WORST_CASE_WR_CYCLES = 7500;

  // Interface
  input  logic                       clk_i;
  input  logic                       wr_i;
  input  logic [RAM_ADDR_WIDTH-1:0]  addr_i;
  input  logic [RAM_DATA_WIDTH-1:0]  data_i;
  output logic                       busy_mem_o;
  output logic [RAM_DATA_WIDTH-1:0]  data_o;

  // Memoria
  logic [RAM_DATA_WIDTH-1:0]  data_vector [0:RAM_N_OF_WORDS-1];
  logic [RAM_ADDR_WIDTH-1:0]  addr_r;
  logic [12:0]                counter;

  // Criação de variável para substituir o delay de escrita que não é possivel de se fazer de forma sequencial
  logic                       gambiarra;
  
  enum
  {
    IDLE,
    READ_PROC,
    WRITE_PROC
  }state, next_state;

  initial $readmemh("endereço do folder", data_vector);

  always_comb
  begin
    unique case(state)
      IDLE:       
        next_state = (wr_i) ? (WRITE_PROC) : (READ_PROC);
      READ_PROC:  
        next_state = (counter == WORST_CASE_RD_CYCLES) ? (IDLE) : (READ_PROC);
      WRITE_PROC:
        next_state = (counter == WORST_CASE_WR_CYCLES) ? (IDLE) : (WRITE_PROC);
    endcase
  end

  always_comb
  begin
    if(wr_i)
      #(5ms:10ms:15ms) gambiarra = 1'b1;
    else
      gambiarra = 1'b0;
  end

  always_ff @(posedge clk_i)
  begin
    state <= next_state;
    addr_r <= addr_i;
    if(gambiarra) 
      data_vector[addr_r] <= data_i;
    if(state == IDLE)
      counter <= 13'h0000;
    else
      counter <= counter + 1'b1;
  end

  always_ff @(negedge clk_i)
  begin
    if(state == IDLE)
      busy_mem_o = 1'b0;
    else
      busy_mem_o = 1'b1;
  end
  
  assign #(20us:60us:100us) data_o = data_vector[addr_r];

endmodule

