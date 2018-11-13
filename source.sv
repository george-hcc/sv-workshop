// Source de dados com delay e interface ready-valid.
// Utiliza dois circuitos contadores, um para contar delay e o segundo para aumentar em um a saída "source_out" quando todas as condição forem atendidas.
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
  
  logic [1:0]             state;
  logic [DELAY_BITS-1:0]  delay_count;
  
  parameter [1:0]
    PROCESS_DELAY  =  3'b001,
    WAIT_HANDSHAKE =  3'b010;
  
  always_ff @(posedge clk, posedge reset) begin
    
    if(reset) begin
      delay_count <= 'b0;
      vrBus.data <= 'b0;
      vrBus.valid <= 'b0;
      state <= PROCESS_DELAY;
    end
    
    else begin    
      case(state)
        PROCESS_DELAY: begin
          if(delay == delay_count + 1 || delay == 'b0) begin // Delay acaba
            state <= WAIT_HANDSHAKE;
            vrBus.data <= vrBus.data + 1;
            vrBus.valid <= 1'b1;
          end
          delay_count <= delay_count + 1; 
        end
        WAIT_HANDSHAKE: begin
          if(vrBus.valid && vrBus.ready) begin  // Handshake Ocorre
            if(delay != 'b0) begin  // Volta a processar o delay
              state <= PROCESS_DELAY;
              delay_count <= 'b0;
              vrBus.valid <= 1'b0;
            end else // Condição Delay 0
              vrBus.data <= vrBus.data + 1;
          end
        end
      endcase
    end
  end
endmodule