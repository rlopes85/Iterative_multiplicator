# Makefile to run verilog simulations
#
# Targets:
#    "make compile"             compiles only
#    "make run"                 runs only
#    "make viewer"              starts waveform viewer
#    "make clean"               deletes temporary files and dirs
#
# Notes for iverilog:
#
#
# A few notes on writing a Makefile
#  - Make sure commands are preceded by a "tab"; spaces will not work!
#  - You may also add dependencies so that a command will execute only
#    if the dependency has been updated more recently than the target
#    (name the target with the same name as the output of the command(s)).
#  - Use a "-n" flag to see what make will use without running the
#    command(s).  Ex: "make -n clean"
#
# 2005/01/29  Added iverilog targets


#----- Useful variables
NAME_TOP	:= tbench


#----- Targets, iverilog
# Use this to compile without running simulation
compile:
	iverilog -c $(NAME_TOP) -o $(NAME_TOP).vvp -v > $(NAME_TOP).log

# Run simulation
run:
	vvp $(NAME_TOP).vvp

# Start viewer
viewer:
	gtkwave $(NAME_TOP).vcd &

# iverilog help, command line
help:
	man iverilog

#----- Cleanup
# Delete temporary files
clean:
	rm -f $(NAME_TOP).log
	rm -f $(NAME_TOP).vvp
	rm -f $(NAME_TOP).vcd
