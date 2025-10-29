all: compile sim coverage

compile:
	vlib work
	vlog -sv -f files.f +cover

sim:
	vsim +UVM_VERBOSITY=UVM_LOW -wlf fpu_apb_top.wlf -logfile sim.log -c -coverage -assertdebug -voptargs="+acc" work.fpu_apb_top -do  "coverage save -onexit -directive -codeAll fpu_apb_top.ucdb; run -all"
	vcd2wlf fpu_apb_top.vcd fpu_apb_top.wlf

	coverage:
	vcover report -html -htmldir coverage_report fpu_apb_top.ucdb