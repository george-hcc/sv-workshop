module axi4_lite_ram
	#(
		parameter DATA_WIDTH	= 32,
		parameter ADDR_WIDTH 	= 10,
		parameter RAM_SIZE		=	1024 // 2^ADDR_WIDTH
	)(
		input logic			clk,
		input logic			rst_n,

		AXI_BUS.Slave		amba_slave
	);

	logic [DATA_WIDTH-1:0] 	ram_mem 		[0:RAM_SIZE-1];
	logic [ADDR_WIDTH-1:0]	data_addr;

	initial begin
		$display("Carregando Memória RAM");
		$readmemh("ram_mem.hex", ram_mem);
	end

	enum logic [4:0] // Variáveis de Estado (Codificação One-Hot)
		{
			RESET				=	5'b00001,
			WAIT_ADDR 	= 5'b00010, 
			WAIT_WDATA 	=	5'b00100,
			SEND_WRESP	= 5'b01000,
			SEND_RDATA	= 5'b10000,
			BAD_STATE		= 5'bxxxxx
		}	state, next_state;

	always_comb begin
		state = next_state;
	end

	// Logica combinacional de variaveis de saida
	always_comb begin		
		amba_slave.b_resp		= 'b0; // Nao Importa
		amba_slave.r_resp		= 'b0; // Nao Importa
		unique case(state)
			RESET: begin
				amba_slave.aw_ready = 'b0;
				amba_slave.w_ready	= 'b0;
				amba_slave.b_valid	= 'b0;
				amba_slave.ar_ready = 'b0;
				amba_slave.r_valid	= 'b0;
				amba_slave.r_data 	= 'b0;
			end
			WAIT_ADDR: begin
				amba_slave.aw_ready = 1'b1;
				amba_slave.w_ready	= 1'b0;
				amba_slave.b_valid	= 1'b0;
				amba_slave.ar_ready = 1'b1;
				amba_slave.r_valid	= 1'b0;
				amba_slave.r_data 	= 'b0; // Nao Importa
			end 
			WAIT_WDATA: begin
				amba_slave.aw_ready = 1'b0;
				amba_slave.w_ready	= 1'b1;
				amba_slave.b_valid	= 1'b0;
				amba_slave.ar_ready = 1'b0;
				amba_slave.r_valid	= 1'b0;
				amba_slave.r_data 	= 'b0; // Nao Importa
			end
			SEND_WRESP: begin
				amba_slave.aw_ready = 1'b0;
				amba_slave.w_ready	= 1'b0;
				amba_slave.b_valid	= 1'b1;
				amba_slave.ar_ready = 1'b0;
				amba_slave.r_valid	= 1'b0;
				amba_slave.r_data 	= 'b0; // Nao Importa
			end
			SEND_RDATA: begin
				amba_slave.aw_ready = 1'b0;
				amba_slave.w_ready	= 1'b0;
				amba_slave.b_valid	= 1'b0;
				amba_slave.ar_ready = 1'b0;
				amba_slave.r_valid	= 1'b1;
				amba_slave.r_data 	= ram_mem[data_addr];
			end
			default: begin
				amba_slave.aw_ready = 'bx;
				amba_slave.w_ready	= 'bx;
				amba_slave.b_valid	= 'bx;
				amba_slave.ar_ready = 'bx;
				amba_slave.r_valid	= 'bx;
				amba_slave.r_data 	= 'bx;
			end
		endcase
	end

	// Logica sequencial de transicao de estados 
	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			 next_state <= RESET;
		end
		else begin
			unique case(state)
				RESET: begin
					next_state <= WAIT_ADDR;
				end
				WAIT_ADDR: begin
					priority if(amba_slave.aw_valid) begin	// Checa o sinal de escrita antes do sinal de leitura
						next_state <= WAIT_WDATA;
						data_addr <= amba_slave.aw_addr;
					end
					else if(amba_slave.ar_valid) begin
						next_state <= SEND_RDATA;
						data_addr <= amba_slave.ar_addr;
					end
					else
						next_state <= state; // O famoso não faça nada boy
				end
				WAIT_WDATA: begin
					if(amba_slave.w_valid) begin
						next_state <= SEND_WRESP;
						ram_mem[data_addr] <= amba_slave.w_data;
					end
				end
				SEND_WRESP: begin
					if(amba_slave.b_ready)
						next_state <= WAIT_ADDR;
				end
				SEND_RDATA: begin
					if(amba_slave.r_ready)
						next_state <= WAIT_ADDR;
				end
				default:
					next_state <= BAD_STATE;
			endcase
		end
	end

endmodule