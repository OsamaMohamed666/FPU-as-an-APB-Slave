class fpu_env extends uvm_env;
  `uvm_component_utils(fpu_env)

  // CLASSES HANDLES
  fpu_agent m_fpu_agent;
  fpu_scoreboard m_fpu_sb;
  fpu_coverage m_fpu_cov;

  // CONSTRUCTOR
  function new(string name = "fpu_env", uvm_component parent);
    super.new(name, parent);
  endfunction

  // FUNCTION: BUILD PHASE
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_fpu_agent = fpu_agent::type_id::create("m_fpu_agent", this);
    m_fpu_sb = fpu_scoreboard::type_id::create("m_fpu_sb", this);
    m_fpu_cov = fpu_coverage::type_id::create("m_fpu_cov", this);

  endfunction

  //FUNCTION: CONNECT PHASE
  function void connect_phase(uvm_phase phase);
    // CONNECT MONITORS AP TO SCOREBOARD AP
    m_fpu_agent.m_monitor_in.item_collect_port_in.connect(m_fpu_sb.item_collect_export_in);
    m_fpu_agent.m_monitor_out.item_collect_port_out.connect(m_fpu_sb.item_collect_export_out);

    // CONNECT MONITORS AP TO COVERAGE AP
    m_fpu_agent.m_monitor_in.item_collect_port_in.connect(m_fpu_cov.item_collect_export_in);
    m_fpu_agent.m_monitor_out.item_collect_port_out.connect(m_fpu_cov.item_collect_export_out);
  endfunction


endclass
