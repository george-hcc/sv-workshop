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

	enum logic [3:0] // Variáveis de Estado (Codificação One-Hot)
		{
			WAIT_ADDR 	= 4'b0001, 
			WAIT_WDATA 	=	4'b0010,
			SEND_WRESP	= 4'b0100,
			SEND_RDATA	= 4'b1000
		}	state, next_state;

	always_comb begin
		state = next_state
	end

	// Logica combinacional de variaveis de saida
	always_comb begin
		unique case(state) begin
			WAIT_ADDR: begin
				amba_slave.aw_ready = 1'b1;
				amba_slave.w_ready	= 1'b0;
				amba_slave.b_valid	= 1'b0;
				amba_slave.b_resp		= amba_slave.b_resp; // Nao Importa
				amba_slave.ar_ready = 1'b1;
				amba_slave.r_valid	= 1'b0;
				amba_slave.r_data 	= amba_slave.r_data; // Nao Importa
				amba_slave.r_resp		= amba_slave.r_resp; // Nao Importa
			end 
			WAIT_WDATA: begin
				amba_slave.aw_ready = 1'b0;
				amba_slave.w_ready	= 1'b1;
				amba_slave.b_valid	= 1'b0;
				amba_slave.b_resp		= amba_slave.b_resp; // Nao Importa
				amba_slave.ar_ready = 1'b0;
				amba_slave.r_valid	= 1'b0;
				amba_slave.r_data 	= amba_slave.r_data; // Nao Importa
				amba_slave.r_resp		= amba_slave.r_resp; // Nao Importa
			end
			SEND_WRESP: begin
				amba_slave.aw_ready = 1'b0;
				amba_slave.w_ready	= 1'b0;
				amba_slave.b_valid	= 1'b1;
				amba_slave.b_resp		= 2'b11;						 // Sinal de Sucesso na Escrita
				amba_slave.ar_ready = 1'b0;
				amba_slave.r_valid	= 1'b0;
				amba_slave.r_data 	= amba_slave.r_data; // Nao Importa
				amba_slave.r_resp		= amba_slave.r_resp; // Nao Importa
			end
			SEND_RDATA: begin
				amba_slave.aw_ready = 1'b0;
				amba_slave.w_ready	= 1'b0;
				amba_slave.b_valid	= 1'b0;
				amba_slave.b_resp		= amba_slave.b_resp; // Nao Importa
				amba_slave.ar_ready = 1'b0;
				amba_slave.r_valid	= 1'b1;
				amba_slave.r_data 	= ram_mem[data_addr];
				amba_slave.r_resp		= 2'b11;						 // Sinal de Sucesso na Leitura
			end
	end

	// Logica sequencial de transicao de estados 
	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			 next_state <= WAIT_ADDR;
		end
		else begin
			unique case(state)
				WAIT_ADDR: begin
					priority if(amba_slave.aw_valid) begin	// Checa o sinal de escrita antes do sinal de leitura
						next_state <= WAIT_WDATA;
						data_addr <= aw_addr;
					end
					else if(amba_slave.ar_valid) begin
						next_state <= SEND_RDATA;
						data_addr <= r_addr;
					end
				end
				WAIT_WDATA: begin
					if(amba_slave.w_valid) begin
						next_state <= WAIT_ADDR;
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
		end
	end

endmodule