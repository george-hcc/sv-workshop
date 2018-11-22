database -open waves -shm
probe -create testbench -depth all -all -memories -shm -database waves -name proba
probe -enable proba
run 18 ms  -absolute
#probe -disable proba
#run 70 ms -absolute
exit
