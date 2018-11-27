module source 
  #(
    parameter DATA_WIDTH = 8,
    parameter DELAY_BITS = 3
  )(
    input logic                   clk,
    input logic                   reset,
    input logic [DELAY_BITS-1:0]  delay,
    
    valid_ready.Master            vrBus
  );
  
  logic [2:0]             state;
  logic [2:0]							next_state;
  logic [DELAY_BITS-1:0]  delay_count;
  logic [DATA_WIDTH-1:0]	source_reg;
  
  parameter [2:0]
    RESET_STATE     = 3'b001,  
    PROCESS_DELAY   = 3'b010,
    WAIT_HANDSHAKE  = 3'b100;

  // Logica combinacional das saídas Valid e Data
  always_comb begin
  	if(state == WAIT_HANDSHAKE) begin
  		vrBus.valid = 1'b1;
  		vrBus.data = source_reg + 1;
  	end
  	else begin
  		vrBus.valid = 1'b0;
  		vrBus.data = source_reg;
  	end
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
      delay_count <= 'b0;
      source_reg <= 'b0;
      next_state <= RESET_STATE;
    end
    
    else begin    
      case(state)
        RESET_STATE: begin
          next_state <= PROCESS_DELAY;
        end
        PROCESS_DELAY: begin
          delay_count <= delay_count + 1;
          if(delay == delay_count + 1)	 // Delay acaba
            next_state <= WAIT_HANDSHAKE;
        end
        WAIT_HANDSHAKE: begin
          if(vrBus.ready) begin  // Handshake Ocorre
          	source_reg <= source_reg + 1;
          	next_state <= PROCESS_DELAY;
            delay_count <= 'b0;
          end
        end
      endcase
    end
  end
endmodule