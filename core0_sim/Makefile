src = $(wildcard ../core0_rtl/*.v)
rtl_dir = ../core0_rtl
tb_dir = .

compile_tb:
	iverilog -s tb -o out.vvp -I $(rtl_dir)  $(src) tb.v 

run:
	vvp out.vvp

clean:
	rm -rf *.vvp *.vcd *.out log

.PHONY: compile_tb clean run
