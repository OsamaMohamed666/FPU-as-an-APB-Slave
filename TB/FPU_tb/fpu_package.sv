package fpu_package;
  parameter int SEQUENCES = 100000;
  parameter int CLK_PERIOD = 10;

  bit detect_new_fpu_operation;

  `include "uvm_macros.svh"
  import uvm_pkg::*;
  //==================================================================================
  // Classes
  //==================================================================================
  `include "fpu_config.sv"
  `include "fpu_seq_item.sv"
  `include "fpu_sequence.sv"
  `include "fpu_sequencer.sv"
  `include "fpu_driver.sv"
  `include "fpu_monitor_in.sv"
  `include "fpu_monitor_out.sv"
  `include "fpu_agent.sv"
  `include "fpu_scoreboard.sv"
  `include "fpu_coverage.sv"
  `include "fpu_env.sv"
  `include "fpu_test.sv"

endpackage
