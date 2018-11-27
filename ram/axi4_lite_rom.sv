module axi4_lite_rom
	#(
		parameter DATA_WIDTH	= 32,
		parameter ADDR_WIDTH 	= 10,
		parameter ROM_SIZE		=	1024 // 2^ADDR_WIDTH
	)(
		input logic			clk,
		input logic			rst_n,

		AXI_BUS.Slave		amba_slave
	);

	logic [DATA_WIDTH-1:0] 	rom_mem 		[0:ROM_SIZE-1];
	logic [ADDR_WIDTH-1:0]	data_addr;
	logic [1:0]							state;

	initial begin
		$display("Carregando Memória ROM");
		$readmemh("rom_mem.hex", rom_mem);
	end

	localparam [1:0]
		WAIT_ADDR 	= 2'b01,
		SEND_DATA		= 2'b10;

	always_comb begin
		if(state == WAIT_ADDR) begin
			amba_slave.ar_ready = 1'b1;
			amba_slave.r_valid 	= 1'b0;
			amba_slave.r_data		= 0;
		end
		else if(state == SEND_DATA) begin
			amba_slave.ar_ready = 1'b0;
			amba_slave.r_valid 	= 1'b1;
			amba_slave.r_data		= rom_mem[data_addr];
		end
	end

	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			 state <= WAIT_ADDR;
		end
		else begin
			case (state)
				WAIT_ADDR: begin
					if(amba_slave.ar_valid) begin
						state <= SEND_DATA;
						data_addr <= amba_slave.ar_addr;
					end
				end
				SEND_DATA: begin
					if(amba_slave.r_ready)
						state <= WAIT_ADDR;
				end
				default: 
					$display("ERROR: Default State atingido"); 
			endcase
		end
	end

endmodule