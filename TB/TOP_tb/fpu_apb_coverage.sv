class fpu_apb_coverage extends uvm_component;
  `uvm_component_utils(fpu_apb_coverage)

  // SEQUENCE ITEM QUEUES
  fpu_apb_seq_item m_seq_item_in;

   //ANALYSIS PORTS (IMPELEMENTATION) HANDELS
  uvm_analysis_imp_MON_IN #(fpu_apb_seq_item,fpu_apb_coverage) item_collect_export_in;

  //COVERAGE INPUTS ONLY AS OUTPUT IS ALREADY COVERED IN THE FPU_COVERAGE.
  covergroup cg_inputs;
    //1) COVERING THE ADDRESSES
    cp_addresses : coverpoint m_seq_item_in.PADDR {
      bins op1_addr = {32'hFFFF0000};
      bins op2_addr = {32'hFFFF0004};
      bins op_sel_addr = {32'hFFFF0008};
      bins flags_addr = {32'hFFFF000C};
      bins result_addr = {32'hFFFF0010};
    }
    //2) COVERING THE OPERATIONS
    cp_operations : coverpoint m_seq_item_in.PWDATA[2:0] {
      bins add_op = {3'b000};
      bins sub_op = {3'b001};
      bins mul_op = {3'b010};
      bins others = default;
    }
    //3) COVERING THE PENABLE SIGNAL
    cp_penable : coverpoint m_seq_item_in.PENABLE {
      bins penable_low = {1'b0};
      bins penable_high = {1'b1};
    }

    //4) COVERING THE PWRITE SIGNAL
    cp_pwrite : coverpoint m_seq_item_in.PWRITE {
      bins pwrite_low = {1'b0};
      bins pwrite_high = {1'b1};
    }
  endgroup

  //FUNCTION: CONSTRUCTOR
  function new (string name = "fpu_apb_coverage", uvm_component parent);
    super.new(name,parent);
    item_collect_export_in = new ("item_collect_export_in", this);
    cg_inputs  = new() ;
  endfunction

  //FUNCTION: BUILD PHASE
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  //FUNCTION: WRITE IN
  //FOR INPUTS
  function void write_MON_IN (fpu_apb_seq_item req);
    m_seq_item_in = req;
    cg_inputs.sample();
  endfunction

endclass
