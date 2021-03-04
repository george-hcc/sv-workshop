run: all

all:
	irun -access +r -input shm.tcl first8bitcell.sv smart8bitcell.sv parallel_to_serial.sv parallelsort.sv tb.sv  -nowarn "NONPRT"

create:
	@echo "database -open waves -shm" >> shm.tcl
	@echo "probe -create  tb -depth all -all -memories -shm -database waves" >> shm.tcl
	@echo "run 18 ms -absolute" >> shm.tcl
	@echo "exit" >> shm.tcl

waves: 
	simvision waves.shm	

simulate: all 

synthesize:
	rc -f rtl.tcl

clean_reports:
	rm -r reports*
clean:
	rm -rf xcelium.d INCA_libs xrun.* *.shm *.dsn *.trn *.ucm ncvlog_*.err imc.key .simvision irun.* *.diag
	rm -r  mapped* rc* fv libscore_work script

