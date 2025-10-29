package fpu_apb_package;

  //PACKAGE PARAMETERS
  parameter int SEQUENCES = 10;
  parameter int CLK_PERIOD = 10;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  //==================================================================================
  // Classes
  //==================================================================================
  `include "fpu_apb_seq_item.sv"
  `include "fpu_apb_sequence.sv"
  `include "fpu_apb_sequencer.sv"
  `include "fpu_apb_driver.sv"
  //`include "fpu_apb_monitor_in.sv"
  //`include "fpu_apb_monitor_out.sv"
  `include "fpu_apb_agent.sv"
  //`include "fpu_apb_scoreboard.sv"
  //`include "fpu_apb_coverage.sv"
  `include "fpu_apb_env.sv"
  `include "fpu_apb_test.sv"

endpackage


