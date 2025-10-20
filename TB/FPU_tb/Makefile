all: compile sim coverage

compile:
	vlib work
	vlog -sv -f files.f +cover

sim:
	vsim +UVM_VERBOSITY=UVM_LOW -wlf fpu_top.wlf -logfile sim.log -c -coverage -assertdebug -voptargs="+acc" work.fpu_top -do  "coverage save -onexit -directive -codeAll fpu_top.ucdb; run -all"
	vcd2wlf fpu_top.vcd fpu_top.wlf

	coverage:
	vcover report -html -htmldir coverage_report fpu_top.ucdb