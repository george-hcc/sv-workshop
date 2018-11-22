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
  
  logic [2:0]             state;
  logic [2:0]							next_state;
  logic [DELAY_BITS-1:0]  delay_count;
  logic [DATA_WIDTH-1:0]  sink_reg;
  
  parameter [2:0]
    RESET_STATE     = 3'b001,  
    PROCESS_DELAY   = 3'b010,
    WAIT_HANDSHAKE  = 3'b100;

  // Logica combinacional da saída Ready
  always_comb begin
  	if(state == WAIT_HANDSHAKE)
  		vrBus.ready = 1'b1;
  	else
  		vrBus.ready = 1'b0;
  end

  // Logica combinacional de correção de estados
  // Inserido para suportar valores aleatórios de delay
  always_comb begin
  	if(delay == 'b0 && next_state != RESET_STATE)
  		state = WAIT_HANDSHAKE;
  	else
  		state = next_state;
  end

  // Logica sequêncial de estados e manipulação de variáveis internas
  always_ff @(posedge clk, negedge reset) begin
    if(~reset) begin
      sink_reg    <= 'b1;
      delay_count <= 'b0;
      next_state  <= RESET_STATE;
    end
    
    else begin
      case(state)
        RESET_STATE: begin
          next_state <= PROCESS_DELAY;
        end
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