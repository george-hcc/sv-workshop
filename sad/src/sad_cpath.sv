module sad_cpath
  (
    input  logic        clk_i,
    input  logic        rst_n_i,
    input  logic        enb_i,
    input  logic [7:0]  index_i,
    output logic        restart_flag_o,
    output logic        pre_sum_flag_o,
    output logic        output_flag_o,
    output logic        busy_o
  );

  enum {
    RESET,
    START,
    I_COMP,
    SUM,
    OUTPUT
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
        state_next = (rst_n_i) ? START : RESET;
      START:
        state_next = (enb_i) ? I_COMP : START;
      I_COMP:
        state_next = (index_i == 8'hFF) ? (OUTPUT) : (SUM);
      SUM:
        state_next = I_COMP;
      OUTPUT:
        state_next = START;
      default:
        state_next = RESET;
    endcase
  end

  assign restart_flag_o = (state == START);
  assign pre_sum_flag_o = (state_next == SUM);
  assign output_flag_o = (state == OUTPUT);
  assign busy_o = (state == SUM);

endmodule