module memx_ctrl
  (
    input  logic                      clk_i,
    input  logic                      mem_rd_i,
    input  logic                      mem_wd_i,
    input  logic [RAM_ADDR_WIDTH-1:0] memc_addr_i,
    input  logic                      busy_mem_i,
    output logic                      memc_busy_o,
    output logic                      memc_wok_o
  );

  logic invalid_addr;

  assign invalid_addr = memc_addr_i >= RAM_N_OF_WORDS;

  enum
  {
    IDLE,
    REQ_READ,
    WAIT_READ,
    REQ_WRITE,
    WAIT_WRITE
  }state, next_state;

  always_comb
  begin
    unique case(state)
      IDLE:
      begin
        next_state = IDLE;
        if(!invalid_addr)
        begin
          if(mem_wr_i)
            next_state = REQ_WRITE;
          else if(mem_rd_i)
            next_state = REQ_READ;
        end
      end
      REQ_READ:
        next_state = WAIT_READ;
      WAIT_READ:
        next_state = (busy_mem_i) ? (WAIT_READ) : (IDLE); 
      REQ_WRITE:
        next_state = WAIT_WRITE;
      WAIT_WRITE:
        next_state = (busy_mem_i) ? (WAIT_WRITE) : (IDLE);
    endcase
  end

  always_ff @(posedge clk_i)
  begin
    state <= next_state;
    if(state == WAIT_WRITE && !busy_mem_i)
      memc_wok_o <= 1'b1;
    else
      memc_wok_o <= 1'b0;
  end

  assign memc_busy_o = (state != IDLE) && busy_mem_i;

endmodule