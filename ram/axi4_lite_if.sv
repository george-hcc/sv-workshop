interface AXI_BUS
	#(
		parameter DATA_WIDTH = 32,
		parameter ADDR_WIDTH = 10
	);

  localparam STRB_WIDRT = DATA_WIDTH/8;

	// Canal Write-Address
	logic                   aw_valid;
  logic                   aw_ready;
  logic [ADDR_WIDTH-1:0]  aw_addr;
  logic [2:0]             aw_prot;

  // Canal Write
  logic                   w_valid;
  logic                   w_ready;
  logic [DATA_WIDTH-1:0]  w_data;
  logic [STRB_WIDRT-1:0]  w_strb;

  // Canal Write-Response
  logic										b_valid;
  logic										b_ready;
  logic	[1:0]							b_resp;

	// Canal Read-Address
	logic                   ar_valid;
	logic                   ar_ready;
	logic [ADDR_WIDTH-1:0]	ar_addr;
	logic [2:0]		          ar_prot;

	// Canal Read
	logic										r_valid;
	logic			              r_ready;
	logic [DATA_WIDTH-1:0]	r_data;
	logic [1:0]		          r_resp;

	modport Master
	(
		input aw_ready,
		output aw_valid, output aw_addr, output aw_prot,

		input w_ready,
		output w_valid, output w_data, output w_strb,

		input b_valid, input b_resp,
		output b_ready,

		input ar_ready,
		output ar_valid, output ar_addr, output ar_prot,
		
		input r_valid, input r_data, input r_resp,
		output r_ready
	);

	modport Slave
	(
		input aw_valid, input aw_addr, input aw_prot,
		output aw_ready,

		input w_valid, input w_data, input w_strb,
		output w_ready,

		input b_ready,
		output b_valid, output b_resp,

		input ar_valid, input ar_addr, input ar_prot, 
		output ar_ready,

		input r_ready,
		output r_valid, output r_data, output r_resp
	);

endinterface
