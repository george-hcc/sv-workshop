`include "axi4_lite_if.sv"
`include "ram_master.sv"
`include "axi4_lite_ram.sv"

module testbench;
	parameter SEED = 420;

	logic clk;
	logic rst_n;

	AXI_BUS axi_bus();

	ram_master ram_master
	(
		.clk					(clk						),
		.rst_n				(rst_n					),
		.amba_master	(axi_bus.Master )
	);

	axi4_lite_ram ram_mem
	(
		.clk					(clk						),
		.rst_n				(rst_n					),
		.amba_slave		(axi_bus.Slave 	)
	);

	always begin
		#5 clk = ~clk;
	end

	task initiate();
    $srandom(SEED);
    clk 		  = 1'b0;
    $display("Resetando Modulos");
    rst_n			= 1'b1;
    rst_n 		= 1'b0;
    #10 rst_n	= 1'b1;
    $display("Reset Concluido");
  endtask

  initial begin
    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars(1, testbench);

    initiate();    
    for(int i = 1; i <= 100; i++) #50;
  	$finish;
  end

endmodule // testbench