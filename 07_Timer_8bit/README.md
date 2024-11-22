how to use makefile in this environment:
	initiate project:
		make init
	compile all sources and testbenches:
		make compile
	simulation:
		make simulation
	clean all outputs:
		make clean


how to run modelsim/questasim in command line:
	- create work lib:
		vlib work
	- delete work lib:
		vdel -all -lib work
	- mapping work dir
		vmap work work
	- compile:
		vlog -work work *.v
	- run simulation without waveform:
		vsim -c work.my_tb -do "run -all"