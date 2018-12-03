module ram_master
	#(
		parameter DATA_WIDTH = 32,
		parameter ADDR_WIDTH = 10
	)(
		input logic			clk,
		input logic			rst_n,

		AXI_BUS.Master	amba_master
	);

	logic [DATA_WIDTH-1:0] 	data;
	logic [ADDR_WIDTH-1:0] 	addr;
	logic [ADDR_WIDTH-1:0] 	index;
	logic 									wr_enable;
	logic 									rd_enable;

	// Variáveis de estados da Write FSM
	enum logic [3:0]{
		WRITE_IDLE	= 4'b0001,
		SEND_WADDR	= 4'b0010,
		SEND_WDATA	=	4'b0100,
		WAIT_WRESP	= 4'b1000
	}	wr_state, next_wr_state;

	// Variáveis de estados da READ FSM
	enum logic [2:0]{
		READ_IDLE		= 3'b001,
		SEND_RADDR	= 3'b010,
		WAIT_RDATA	= 3'b100
	}	rd_state, next_rd_state;

	// Variáveis de estados do algoritmo de escrita e leitura
	enum logic [3:0]{
		RESET				=	4'b0001,
		READ_INDEX 	= 4'b0010, 
		READ_DATA 	=	4'b0100,
		WRITE_INDEX	= 4'b1000
	} logic_state, next_logic_state;

	assign wr_enable = (next_logic_state == WRITE_INDEX);
	assign rd_enable = (next_logic_state == READ_INDEX || next_logic_state == READ_DATA);

	always_ff @(posedge clk, negedge rst_n) begin
		if(~rst_n)
			wr_state <= WRITE_IDLE;
		else
			wr_state <= next_wr_state;
	end

	// Lógica combinacional de transição de estados referente a WRITE FSM
	always_comb begin
		next_wr_state = wr_state; // O famoso anti-latch 100% atualizado pode confiar pai
		unique case(wr_state)
			WRITE_IDLE: begin
				if(wr_enable)
					next_wr_state = SEND_WADDR;
			end
			SEND_WADDR: begin
				if(amba_master.aw_ready)
					next_wr_state = SEND_WDATA;
			end
			SEND_WDATA: begin
				if(amba_master.w_ready)
					next_wr_state = WAIT_WRESP;
			end
			WAIT_WRESP: begin
				if(amba_master.b_valid) begin
					if(wr_enable)
						next_wr_state = SEND_WADDR;
					else
						next_wr_state = WRITE_IDLE;
				end
			end
		endcase
	end

	// Lógica combinacional de variáveis das saídas AXI referente a escrita (AW, W e B)
	always_comb begin
		amba_master.aw_prot		=	'b0; 	// Não Importa
		amba_master.w_strb		=	'b0;	// Não Importa
		unique case (wr_state)
			WRITE_IDLE: begin
				amba_master.aw_valid	=	'b0;
				amba_master.aw_addr		=	'b0;
				amba_master.w_valid		=	'b0;
				amba_master.w_data 		=	'b0;
				amba_master.b_ready		=	'b0;
			end
			SEND_WADDR: begin
				amba_master.aw_valid	=	1'b1;
				amba_master.aw_addr		=	addr;
				amba_master.w_valid		=	1'b0;
				amba_master.w_data 		=	'b0;
				amba_master.b_ready		=	1'b0;
			end
			SEND_WDATA: begin
				amba_master.aw_valid	=	1'b0;
				amba_master.aw_addr		=	'b0;
				amba_master.w_valid		=	1'b1;
				amba_master.w_data 		=	data;
				amba_master.b_ready		=	1'b0;
			end
			WAIT_WRESP: begin
				amba_master.aw_valid	=	1'b0;
				amba_master.aw_addr		=	'b0;
				amba_master.w_valid		=	1'b0;
				amba_master.w_data 		=	'b0;
				amba_master.b_ready		=	1'b1;
			end
		endcase
	end

	always_ff @(posedge clk, negedge rst_n) begin
		if(~rst_n)
			rd_state <= READ_IDLE;
		else
			rd_state <= next_rd_state;
	end

	// Lógica combinacional de transição de estados referente a Write FSM
	always_comb begin
		next_rd_state = rd_state; // O famoso anti-latch 100% atualizado pode confiar pai
		unique case(rd_state)
			READ_IDLE: begin
				if(rd_enable)
					next_rd_state = SEND_RADDR;
			end
			SEND_RADDR: begin
				if(amba_master.ar_ready)
					next_rd_state = WAIT_RDATA;
			end
			WAIT_RDATA: begin
				if(amba_master.r_valid) begin
					if(rd_enable)
						next_rd_state = SEND_RADDR;
					else
						next_rd_state = READ_IDLE;
				end
			end
		endcase
	end

	// Lógica combinacional de variáveis das saídas AXI referente a leitura (AR e R)
	always_comb begin		
		amba_master.ar_prot		=	'b0;	// Não Importa
		unique case(rd_state)
			READ_IDLE: begin
				amba_master.ar_valid	=	'b0;
				amba_master.ar_addr		=	'b0;
				amba_master.r_ready		= 'b0;
			end
			SEND_RADDR: begin
				amba_master.ar_valid	=	1'b1;
				amba_master.ar_addr		=	addr;
				amba_master.r_ready		= 1'b0;
			end
			WAIT_RDATA: begin
				amba_master.ar_valid	=	1'b0;
				amba_master.ar_addr		=	'b0;
				amba_master.r_ready		= 1'b1;
			end
		endcase
	end

	always_ff @(posedge clk, negedge rst_n) begin
		if(~rst_n)
			logic_state <= RESET;
		else
			logic_state <= next_logic_state;
	end

	// Lógica combinacional de transição de estados do Algoritmo
	always_comb begin
		next_logic_state = logic_state; // O famoso anti-latch 100% atualizado pode confiar pai
		unique case(logic_state)
			RESET: begin
				next_logic_state = READ_INDEX;
			end
			READ_INDEX: begin
				if(amba_master.r_ready && amba_master.r_valid)	
					next_logic_state = READ_DATA;
			end
			READ_DATA: begin
				if(amba_master.r_ready && amba_master.r_valid)	
					next_logic_state = WRITE_INDEX;
			end
			WRITE_INDEX: begin
				if(amba_master.b_ready && amba_master.b_valid)	
					next_logic_state = READ_INDEX;
			end
		endcase
	end

	// Definição da variáveil interna addr
	always_comb begin
		addr = 'b0;
		unique case(logic_state)
			RESET:
				addr = 'b0;
			READ_INDEX:
				addr = index;
			READ_DATA:
				addr = data;
			WRITE_INDEX:
				addr = index;
		endcase
	end

	// Definição da variável interna index
	always_ff @(posedge clk, negedge rst_n) begin
		if(~rst_n)
			index <= 0;
		else if(logic_state == WRITE_INDEX && amba_master.b_valid)
			index <= index + 1;
	end

	// Definição da variável interna data
	always_ff @(posedge clk, negedge rst_n) begin
		unique case(logic_state)
			RESET:
				data <= 'b0;
			READ_INDEX:
				data <= amba_master.r_data;
			READ_DATA:
				data <= amba_master.r_data;
			WRITE_INDEX:
				data <= data;
			default:
				data <= 'bx;
		endcase
	end

endmodule