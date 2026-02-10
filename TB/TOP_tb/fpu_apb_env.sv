class fpu_apb_env extends uvm_env;
  //REGISTERATION
  `uvm_component_utils(fpu_apb_env)

  //CLASSES HANDLE
  fpu_apb_agent m_agent;
  fpu_scoreboard m_fpu_sb;
  fpu_apb_coverage m_fpu_cov;

  //CONSTRUCTOR
  function new (string name = "fpu_apb_env", uvm_component parent);
    super.new(name,parent);
  endfunction

  //FUNCTION: BUILD PHASE
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_agent = fpu_apb_agent::type_id::create("m_agent",this);
    m_fpu_sb = fpu_scoreboard::type_id::create("m_fpu_sb",this);
    m_fpu_cov = fpu_apb_coverage::type_id::create("m_fpu_cov",this);
  endfunction

  //FUNCTION: CONNECT PHASE
  function void connect_phase(uvm_phase phase);
    // Connect monitors ap to scoreboard ap
    m_agent.m_monitor_in.fpu_item_collect_port_in.connect(m_fpu_sb.item_collect_export_in);
    m_agent.m_monitor_out.item_collect_port_out.connect(m_fpu_sb.item_collect_export_out);
    // Connect monitors ap to coverage ap
    m_agent.m_monitor_in.apb_item_collect_port_in.connect(m_fpu_cov.item_collect_export_in);
  endfunction
endclass
