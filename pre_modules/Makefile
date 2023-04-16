src = $(wildcard ./*.v)

compile:
	iverilog -s tb $(src)
	vvp a.out

wave:
	gtkwave dump.vcd


.PHONY: compile wave