class fpu_apb_env extends uvm_env;
  //REGISTERATION
  `uvm_component_utils(fpu_apb_env)

  //==================================================================================
  // Classes Handles
  //==================================================================================
  // FPU Classes
  //-----------------------------------------------------------------------------------
  fpu_config m_fpu_config;
  fpu_agent m_fpu_agent;
  fpu_coverage m_fpu_cov;
  // FPU_APB Classes
  //-----------------------------------------------------------------------------------
  fpu_apb_agent m_apb_agent;
  fpu_apb_coverage m_apb_cov;
  // Common Classes
  //-----------------------------------------------------------------------------------
  fpu_scoreboard m_sb;

  //CONSTRUCTOR
  function new (string name = "fpu_apb_env", uvm_component parent);
    super.new(name,parent);
  endfunction

  //FUNCTION: BUILD PHASE
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // FPU Classes
    m_fpu_agent = fpu_agent::type_id::create("m_fpu_agent",this);
    m_fpu_cov = fpu_coverage::type_id::create("m_fpu_cov",this);
    // FPU_APB Classes
    m_apb_agent = fpu_apb_agent::type_id::create("m_apb_agent",this);
    m_apb_cov = fpu_apb_coverage::type_id::create("m_apb_cov",this);
    // Common Classes
    m_sb = fpu_scoreboard::type_id::create("m_sb",this);
  endfunction

  //FUNCTION: CONNECT PHASE
  function void connect_phase(uvm_phase phase);
    //Common:Connecting monitors ap to scoreboard ap
    //--------------------------------------------------------------------------------
    m_apb_agent.m_monitor_in.fpu_item_collect_port_in.connect(m_sb.item_collect_export_in);
    m_apb_agent.m_monitor_out.item_collect_port_out.connect(m_sb.item_collect_export_out);

    //FPU:Connecting monitors ap to coverage ap
    //--------------------------------------------------------------------------------
    m_fpu_agent.m_monitor_in.item_collect_port_in.connect(m_fpu_cov.item_collect_export_in);
    m_fpu_agent.m_monitor_out.item_collect_port_out.connect(m_fpu_cov.item_collect_export_out);

    //FPU_APB:Connecting monitor ap to coverage ap
    //--------------------------------------------------------------------------------
    m_apb_agent.m_monitor_in.apb_item_collect_port_in.connect(m_apb_cov.item_collect_export_in);
  endfunction
endclass
