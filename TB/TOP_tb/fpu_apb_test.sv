class fpu_apb_test extends uvm_test;
  `uvm_component_utils(fpu_apb_test)

  // Environment and sequence handles
  fpu_apb_env    m_fpu_apb_env;
  fpu_apb_sequence m_fpu_apb_seq;

  //CONSTRUCTOR
  function new (string name = "fpu_apb_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  //BUILD PHASE
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_fpu_apb_env = fpu_apb_env::type_id::create("m_fpu_apb_env",this);
  endfunction

  //RUN PHASE
  task run_phase(uvm_phase phase);
    m_fpu_apb_seq = fpu_apb_sequence::type_id::create("m_fpu_apb_seq");

    phase.raise_objection(this);
      m_fpu_apb_seq.start(m_fpu_apb_env.m_agent.m_sequencer);
    phase.drop_objection(this);

    phase.phase_done.set_drain_time(this,20);
  endtask

  // END OF ELABORATION PHASE
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

  //REPORT PHASE
  virtual function void report_phase(uvm_phase phase);
    uvm_report_server svr;
    super.report_phase(phase);
    svr = uvm_report_server::get_server();

    if(svr.get_severity_count(UVM_FATAL)+svr.get_severity_count(UVM_ERROR)>0) begin
      `uvm_info("Report_Phase", "---------------------------------------", UVM_NONE)
      `uvm_info("Report_Phase", "----TEST FAIL----", UVM_NONE)
      `uvm_info("Report_Phase", "---------------------------------------", UVM_NONE)
    end

    else begin
      `uvm_info("Report_Phase", "---------------------------------------", UVM_NONE)
      `uvm_info("Report_Phase", "---- TEST PASS ----", UVM_NONE)
      `uvm_info("Report_Phase", "---------------------------------------", UVM_NONE)
    end
  endfunction

endclass
