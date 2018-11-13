run: all

all:
	xrun -access +r -input shm.tcl valid_ready.sv testbench.sv source.sv sink.sv
	
waves: 
	simvision waves.shm	

simulate: all 

synthesize:
	rc -f rtl.tcl

clean_reports:
	rm -r reports*
clean:
	rm -rf xcelium.d INCA_libs xrun.* *.shm *.dsn *.trn *.ucm ncvlog_*.err imc.key .simvision
	rm -r  mapped* rc* fv libscore_work script

