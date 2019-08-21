module sqrt_ctrl
  (
    input  logic        clk_i,
    input  logic        rst_n_i,
    input  logic        s_less_than_dt_i,
    output logic        busy_o
  );

  enum {
    RESET,
    IDLE,
    WORK
  } state, state_next;

  always_ff @(posedge clk_i, negedge rst_n_i)
  begin
    if(!rst_n_i)
      state <= RESET;
    else
      state <= state_next;
  end

  always_comb
  begin
    case(state)
      RESET:
        state_next = (rst_n_i) ? IDLE : RESET;
      IDLE:
        state_next = WORK;
      WORK:
        state_next = (s_less_than_dt_i) ? (WORK) : (IDLE);
      default:
        state_next = RESET;
    endcase
  end

  assign busy_o = (state == WORK);

endmodule