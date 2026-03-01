class fpu_apb_test extends uvm_test;
  `uvm_component_utils(fpu_apb_test)

  // Environment and sequence handles
  fpu_apb_env    m_fpu_apb_env;
  fpu_apb_sequence m_fpu_apb_seq;

  //Configuration object handle
  fpu_config m_fpu_config;
  fpu_apb_config m_fpu_apb_config;

  //CONSTRUCTOR
  function new (string name = "fpu_apb_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  //BUILD PHASE
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_fpu_apb_env = fpu_apb_env::type_id::create("m_fpu_apb_env",this);

    //Configuration for FPU_APB Agent
    m_fpu_apb_config = fpu_apb_config::type_id::create("m_fpu_apb_config", this);
    m_fpu_apb_config.is_active = UVM_ACTIVE; // Set the FPU_APB agent to active mode
    uvm_config_db#(fpu_apb_config)::set(this, "m_fpu_apb_env", "fpu_apb_config", m_fpu_apb_config);

    //Configuration for FPU Agent
    m_fpu_config = fpu_config::type_id::create("m_fpu_config", this);
    m_fpu_config.is_active = UVM_PASSIVE; // Set the FPU agent to passive mode
    uvm_config_db#(fpu_config)::set(this, "m_fpu_apb_env", "fpu_config", m_fpu_config);
  endfunction

  //RUN PHASE
  task run_phase(uvm_phase phase);
    m_fpu_apb_seq = fpu_apb_sequence::type_id::create("m_fpu_apb_seq");

    phase.raise_objection(this);
      m_fpu_apb_seq.start(m_fpu_apb_env.m_apb_agent.m_sequencer);
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

      //COVERAGE REPORTS
    `uvm_info("REPORT PHASE",$sformatf(" COVERAGE of FPU_APB inputs is %0.2f%%", m_fpu_apb_env.m_apb_cov.cg_inputs.get_coverage()),UVM_LOW);

    `uvm_info("REPORT PHASE",$sformatf(" coverage of FPU inputs is %0.2f%%", m_fpu_apb_env.m_fpu_cov.cg_inputs.get_coverage()),UVM_LOW);
    `uvm_info("REPORT PHASE",$sformatf(" coverage of FPU operations is %0.2f%%", m_fpu_apb_env.m_fpu_cov.cg_operation_select.get_coverage()),UVM_LOW);
    `uvm_info("REPORT PHASE",$sformatf(" coverage of FPU outputs is %0.2f%%",m_fpu_apb_env.m_fpu_cov.cg_outputs.get_coverage()),UVM_LOW);
    `uvm_info("REPORT PHASE",$sformatf(" coverage of FPU flags is %0.2f%%", m_fpu_apb_env.m_fpu_cov.cg_flags.get_coverage()),UVM_LOW);
  endfunction

endclass
