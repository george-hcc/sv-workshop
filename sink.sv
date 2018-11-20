module sink 
  #(
    parameter DATA_WIDTH = 8,
    parameter DELAY_BITS = 3
  )(
    input logic                   clk, 
    input logic                   reset,
    input logic [DELAY_BITS-1:0]  delay,
    
    valid_ready.Slave             vrBus
  );
  
  logic [1:0]             state;
  logic [1:0]							next_state;
  logic [DELAY_BITS-1:0]  delay_count;
  logic [DATA_WIDTH-1:0]  sink_reg;
  
  parameter [1:0]
    PROCESS_DELAY  =  2'b01,
    WAIT_HANDSHAKE =  2'b10;

  always_comb begin
  	if(state == WAIT_HANDSHAKE)
  		vrBus.ready = 1'b1;
  	else
  		vrBus.ready = 1'b0;
  end

  always_comb begin
  	if(delay == 'b0)
  		state = WAIT_HANDSHAKE;
  	else
  		state = next_state;
  end
  
  always_ff @(posedge clk, negedge reset) begin
    if(~reset) begin
      sink_reg <= 'b0;
      delay_count <= 'b0;
      next_state <= PROCESS_DELAY;
    end
    
    else begin
      case(state)
        PROCESS_DELAY: begin
          delay_count <= delay_count + 1;
          if(delay == delay_count + 1)
            next_state <= WAIT_HANDSHAKE;
        end
        WAIT_HANDSHAKE: begin
          if(vrBus.valid && vrBus.ready) begin // Handshake Ocorre
            sink_reg <= vrBus.data + 1;
            next_state <= PROCESS_DELAY;
            delay_count <= 'b0;
          end
        end
      endcase
    end
  end
endmodule