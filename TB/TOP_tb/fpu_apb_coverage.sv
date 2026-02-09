class fpu_apb_coverage extends uvm_component;
  `uvm_component_utils(fpu_apb_coverage)
  
  // SEQUENCE ITEM QUEUES
  fpu_apb_seq_item m_seq_item_in
                  ,m_seq_item_out;

   //ANALYSIS PORTS (IMPELEMENTATION) HANDELS
  uvm_analysis_imp_MON_IN #(fpu_apb_seq_item,fpu_apb_coverage) item_collect_export_in;
  uvm_analysis_imp_MON_OUT #(fpu_apb_seq_item,fpu_apb_coverage) item_collect_export_out;

  //COVERAGE VARIABLES
  covergroup cg @(posedge clk);
    //1) COVERING THE ADDRESSES
    cp_addresses coverpoint m_seq_item_in.PADDR {
      bins OP1_ADDR = {32'hFFFF0000};
      bins OP2_ADDR = {32'hFFFF0004};
      bins OP_SEL_ADDR = {32'hFFFF0008};
      bins FLAGS_ADDR = {32'hFFFF000C};
      bins RESULT_ADDR = {32'hFFFF0010};
    }
    //2) COVERING THE OPERATIONS
    cp_operations coverpoint m_seq_item_in.PWDATA[2:0] {
      bins ADD_OP = 3'b000;
      bins SUB_OP = 3'b001;
      bins MUL_OP = 3'b010;
      bins others = default;
    }
  endgroup : cg

  //FUNCTION: CONSTRUCTOR
  function new (string name = "fpu_apb_coverage", uvm_component parent);
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
