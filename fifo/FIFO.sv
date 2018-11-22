module FIFO
	#(
		parameter DATA_WIDTH 	= 8,
    parameter ADDR_SIZE 	= 3,
		parameter FIFO_SIZE		= 8 	// FIFO_SIZE = 2^ADDR_SIZE exceto para ADDR_SIZE = 0
	)(
		input logic 				clk,
		input logic 				reset,

		valid_ready.Slave 			putBus,
		valid_ready.Master 			getBus
	);

	generate
    /************************************
    *****TAMANHO DA FIFO MAIOR QUE 0*****
    ************************************/
    if(ADDR_SIZE > 0) begin

		  logic [DATA_WIDTH-1:0] 	fifo_mem	[0:FIFO_SIZE-1]; // Banco de Registradores internos da FIFO
      logic [ADDR_SIZE:0]     rd_ptr; 	// Guarda endereço do próximo elemento a ser lido na memória
      logic [ADDR_SIZE:0]     wr_ptr; 	// Guarda endereço do próximo elemento a ser escrito na memória

		  logic                   is_empty; // Flag de controle para sinalizar que a FIFO está vazia
		  logic					          is_full;  // Flag de controle para sinalizar que a FIFO está cheia
        
      // Logica combinacional das saídas valid e ready
      assign putBus.ready = ~is_full || getBus.ready;
      assign getBus.valid = ~is_empty || putBus.valid;
        
      // Logica combinacional da flag "is_empty"
      always_comb begin
        if(rd_ptr == wr_ptr)
          is_empty = 1'b1;
        else
          is_empty = 1'b0;          
      end
        
      // Logica combinacional da flag "is_full"
      always_comb begin
        if(rd_ptr[ADDR_SIZE-1:0] == wr_ptr[ADDR_SIZE-1:0] && rd_ptr[ADDR_SIZE] != wr_ptr[ADDR_SIZE])
          is_full = 1'b1;
        else
          is_full = 1'b0;
      end
        
      // Logica combinacional da saída da FIFO
      always_comb begin
        if(putBus.valid && getBus.ready && is_empty) // Transmissao instantanea
          getBus.data = putBus.data;
        else
          getBus.data = fifo_mem[rd_ptr[ADDR_SIZE-1:0]]; // Funcionamento Read and Write
      end
        
      // Logica sequêncial de gravação e leitura
      always_ff @(posedge clk, negedge reset) begin
        if(~reset) begin // RESET
          wr_ptr <= 'b0;
          rd_ptr <= 'b0;
        end
        else if(putBus.valid) begin
          if(getBus.ready && ~is_empty) begin	// READ AND WRITE
            fifo_mem[wr_ptr[ADDR_SIZE-1:0]] <= putBus.data;
            wr_ptr <= wr_ptr + 1;
            rd_ptr <= rd_ptr + 1;
          end
          else if(~getBus.ready && ~is_full) begin // WRITE
            fifo_mem[wr_ptr[ADDR_SIZE-1:0]] <= putBus.data;
            wr_ptr <= wr_ptr + 1;
          end            
        end
        else if(getBus.ready && ~is_empty) begin // READ
            rd_ptr <= rd_ptr + 1;
        end
      end        
    end
      
    /************************************
    ******TAMANHO DA FIFO IGUAL A 0******
    ************************************/
    else begin
      assign getBus.valid = putBus.valid;
		  assign putBus.ready = getBus.ready;
    end
      
	endgenerate

endmodule