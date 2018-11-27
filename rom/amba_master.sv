module rom_master
	#(
		parameter DATA_WIDTH = 32,
		parameter ADDR_WIDTH = 10
	)(
		input logic			clk,
		input logic			rst_n,

		AXI_BUS.Master 	amba_master
	);

	logic [DATA_WIDTH-1:0]	data;
	logic [ADDR_WIDTH-1:0]	addr;
	logic [1:0]							state;

	localparam [1:0]
		SEND_ADDR = 2'b01,
		WAIT_DATA = 2'b10;

	always_comb begin
		if(state == SEND_ADDR) begin
			amba_master.ar_valid 	= 1'b1;
			amba_master.ar_addr		= addr;
			amba_master.r_ready		= 1'b0;
		end
		else if(state == WAIT_DATA) begin
			amba_master.ar_valid 	= 1'b0;
			amba_master.r_ready		= 1'b1;
			amba_master.ar_addr		= 0;
		end
	end

	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			 state <= SEND_ADDR;
			 addr <= 'b0;
		end 
		else begin
			case (state)
				SEND_ADDR: begin
					if(amba_master.ar_ready) begin
						state <= WAIT_DATA;
					end
				end // SEND_ADDR:
				WAIT_DATA: begin
					if(amba_master.r_valid) begin
						state <= SEND_ADDR;
						addr <= amba_master.r_data;
					end
				end // WAIT_DATA:
				default:  
					$display("ERROR: Default State atingido"); 
			endcase
		end
	end

endmodule