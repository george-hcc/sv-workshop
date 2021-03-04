run: all

all:
	irun -access +r -input shm.tcl flipflop.sv shiftregister.sv square_of_m_i.sv log2_m.sv log2.sv tb.sv  -nowarn "NONPRT"

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

