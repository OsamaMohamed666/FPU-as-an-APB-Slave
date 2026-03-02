package fpu_apb_package;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `define DASH_LINE "---------------------------------------------------------------------------------"


  //PACKAGE PARAMETERS
  parameter int SEQUENCES = 50000; //number of sequences to run in the test
  parameter int CLK_PERIOD = 10;

  //DETECTING NEW FPU OPERATION
  bit detect_new_fpu_operation;
  //ENUM FOR ADDRESSES
  typedef enum int {OP1_ADDR = 32'hFFFF0000,
                    OP2_ADDR = 32'hFFFF0004,
                    OPERATION_SELECT_ADDR = 32'hFFFF0008,
                    FLAGS_ADDR = 32'hFFFF000C,
                    RESULT_ADDR = 32'hFFFF0010
  } addr_e;

  //ENUM FOR INDECIES FOR RAL
  typedef enum int {OP1,
                    OP2,
                    OPERATION_SELECT,
                    FLAGS,
                    RESULT
  } signals_id_e;

  //==================================================================================
  // CLASSES
  //==================================================================================

  //FPU classes
  `include "../FPU_tb/fpu_config.sv"
  `include "../FPU_tb/fpu_seq_item.sv"
  `include "../FPU_tb/fpu_sequencer.sv"
  `include "../FPU_tb/fpu_driver.sv"
  `include "../FPU_tb/fpu_monitor_in.sv"
  `include "../FPU_tb/fpu_monitor_out.sv"
  `include"../FPU_tb/fpu_agent.sv"
  `include "../FPU_tb/fpu_scoreboard.sv"
  `include "../FPU_tb/fpu_coverage.sv"

  //RAL classes
  `include "../RAL/ral_reg_bank_seq_item.sv"
  `include "../RAL/ral_reg_bank_model.sv"
  `include "../RAL/ral_reg_bank_block.sv"
  `include "../RAL/ral_reg_bank_monitor.sv"
  `include "../RAL/ral_reg_bank_agent.sv"
  `include "../RAL/ral_reg_bank_scoreboard.sv"

  //FPU_APB classes
  `include "fpu_apb_config.sv"
  `include "fpu_apb_seq_item.sv"
  `include "fpu_apb_sequences.sv"
  `include "fpu_apb_sequencer.sv"
  `include "fpu_apb_driver.sv"
  `include "fpu_apb_monitor_in.sv"
  `include "fpu_apb_monitor_out.sv"
  `include "fpu_apb_agent.sv"
  `include "fpu_apb_coverage.sv"
  `include "fpu_apb_env.sv"
  `include "fpu_apb_tests.sv"

endpackage


