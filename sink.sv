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
  logic [DELAY_BITS-1:0]  delay_count;
  logic [DATA_WIDTH-1:0]  sink_reg;
  
  parameter [1:0]
    PROCESS_DELAY  =  3'b001,
    WAIT_HANDSHAKE =  3'b010;
  
  always_ff @(posedge clk, posedge reset) begin
    if(reset) begin
      sink_reg <= 'b0;
      delay_count <= 'b0;
      vrBus.ready <= 'b0;
      state <= PROCESS_DELAY;
    end
    
    else begin
      case(state)
        PROCESS_DELAY: begin
          if(delay == delay_count + 1 || delay == 'b0) begin
            state <= WAIT_HANDSHAKE;
            vrBus.ready <= 1'b1;
          end
          delay_count <= delay_count + 1;
        end
        WAIT_HANDSHAKE: begin
          if(vrBus.valid && vrBus.ready) begin // Handshake Ocorre
            sink_reg <= vrBus.data + 1;
            if(delay != 'b0) begin // Volta a processar o delay
              state <= PROCESS_DELAY;
              delay_count <= 'b0;
              vrBus.ready <= 'b0;
            end
          end
        end
      endcase
    end
  end
endmodule