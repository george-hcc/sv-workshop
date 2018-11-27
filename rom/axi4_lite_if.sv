interface AXI_BUS
	#(
		parameter DATA_WIDTH = 32,
		parameter ADDR_WIDTH = 10
	);

	// Canal Read-Addres
	logic 									ar_valid;
	logic 									ar_ready;
	logic [ADDR_WIDTH-1:0]	ar_addr;
	logic	[2:0]							ar_prot;

	// Canal Read
	logic										r_valid;
	logic										r_ready;
	logic [DATA_WIDTH-1:0]	r_data;
	logic [1:0]							r_resp;

	modport Master
	(
		input ar_ready,
		output ar_valid, output ar_addr, output ar_prot,
		
		input r_valid, input r_data, input r_resp,
		output r_ready
	);

	modport Slave
	(
		input ar_valid, input ar_addr, input ar_prot, 
		output ar_ready,

		input r_ready,
		output r_valid, output r_data, output r_resp
	);

endinterface