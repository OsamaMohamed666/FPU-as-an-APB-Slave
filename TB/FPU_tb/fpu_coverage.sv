class fpu_coverage extends uvm_component;
  // FACTORY REGISTERATION
  `uvm_component_utils(fpu_coverage)

  // SEQ ITEMS QUEUES
  fpu_seq_item  m_seq_item_in,
                m_seq_item_out;

  //ANALYSIS PORTS (IMPELEMENTATION) HANDELS
  uvm_analysis_imp_MON_IN #(fpu_seq_item,fpu_coverage) item_collect_export_in;
  uvm_analysis_imp_MON_OUT #(fpu_seq_item,fpu_coverage) item_collect_export_out;

  //==================================================================================
  // COVERAGE GROUP
  //==================================================================================
  //INPUT GROUP
  covergroup cg_inputs;
    //OPERAND ONE
    cp_op1: coverpoint m_seq_item_in.OP1 {
      bins  all_ones = {32'hffff_ffff};
      bins  zero     = {32'h0};
      bins  minimum_value = {32'hFF7F_FFFF};
      bins  maximum_value = {32'hFF7F_FFFF};
      bins  others  = default;
    }

    //OPERAND TWO
    cp_op2: coverpoint m_seq_item_in.OP2 {
      bins  all_ones = {32'hffff_ffff};
      bins  zero     = {32'h0};
      bins  minimum_value = {32'hFF7F_FFFF};
      bins  maximum_value = {32'h7F7FFFFF};
      bins  others  = default;
    }

  endgroup

  //OPERATION GROUP
  covergroup cg_operation_select;
    cp_op_select: coverpoint m_seq_item_in.OP_select{
      bins operations[] = {[0:2]};
      bins operations_transitions[] = ([0:2] => [0:2]);
    }
  endgroup

  //OUTPUT GROUP
  covergroup cg_outputs;
    //FPU RESULT
    cp_fpu_result: coverpoint m_seq_item_out.Result {
      bins  all_ones = {32'hffff_ffff};
      bins  zero     = {32'h0};
      bins  minimum_value = {32'hFF7F_FFFF};
      bins  maximum_value = {32'h7F7FFFFF};
      bins  others  = default;
    }

    //DATA VALID
    cp_data_validflag: coverpoint m_seq_item_out.data_valid;
  endgroup

  //FLAGS GROUP
  covergroup cg_flags;
    cp_zero_flag: coverpoint m_seq_item_out.zero_flag
      {
        bins zero_f[2] = {0,1};
      }
    cp_infinite_flag: coverpoint m_seq_item_out.INF_flag
      {
        bins inf_f[2] = {0,1};
      }
    cp_not_a_number_flag: coverpoint m_seq_item_out.NAN_flag
      {
        bins nan_f[2] = {0,1};
      }
  endgroup

  //FUNCTION: CONSTRUCTOR
  function new (string name = "fpu_coverage", uvm_component parent);
    super.new(name,parent);
    item_collect_export_in = new ("item_collect_export_in", this);
    item_collect_export_out = new ("item_collect_export_out", this);
    cg_inputs  = new() ;
    cg_operation_select = new();
    cg_outputs = new();
    cg_flags   = new() ;
  endfunction

  //FUNCTION: BUILD PHASE
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  //FUNCTION: WRITE IN
  //FOR INPUTS
  function void write_MON_IN (fpu_seq_item req);
    m_seq_item_in = req;
    cg_inputs.sample();
    cg_operation_select.sample();
  endfunction

  //FOR OUTPUTS
  function void write_MON_OUT(fpu_seq_item req);
    m_seq_item_out = req;
    cg_outputs.sample();
    cg_flags.sample();
  endfunction

endclass


