run: all

all:
	xrun -access +r -input shm.tcl ../src/memx.sv ../src/mem_model.sv tb.sv  -nowarn "NONPRT"

create:
	@echo "database -open waves -shm" >> shm.tcl
	@echo "probe -create  tb -depth all -all -memories -shm -database waves" >> shm.tcl
	@echo "run 100 ms -absolute" >> shm.tcl
	@echo "exit" >> shm.tcl
	
waves: 
	simvision waves.shm	

simulate: all 

synthesize:
	rc -f rtl.tcl

clean_reports:
	rm -r reports*

clean:
	rm -rf xcelium.d INCA_libs xrun.* *.shm shm.tcl
	rm -r  mapped* rc* fv libscore_work script

