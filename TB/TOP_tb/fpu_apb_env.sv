class fpu_apb_env extends uvm_env;
  //REGISTERATION
  `uvm_component_utils(fpu_apb_env)

  //==================================================================================
  // Classes Handles
  //==================================================================================

  //RAL Classes
  ral_reg_bank_block m_ral_block;
  ral_reg_bank_agent m_ral_reg_bank_agent;
  ral_reg_bank_scoreboard m_ral_reg_bank_sb;

  // FPU Classes
  //-----------------------------------------------------------------------------------
  fpu_config m_fpu_config;
  fpu_agent m_fpu_agent;
  fpu_coverage m_fpu_cov;

  // FPU_APB Classes
  //-----------------------------------------------------------------------------------
  fpu_apb_config m_fpu_apb_config;
  fpu_apb_agent m_apb_agent;
  fpu_apb_coverage m_apb_cov;

  // Common Classes between FPU and FPU_APB
  //-----------------------------------------------------------------------------------
  fpu_scoreboard m_sb;

  //CONSTRUCTOR
  function new (string name = "fpu_apb_env", uvm_component parent);
    super.new(name,parent);
  endfunction

  //FUNCTION: BUILD PHASE
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    //RAL
    //--------------------------------------------------------------------------------
    m_ral_block = ral_reg_bank_block::type_id::create("m_ral_block", this);
    m_ral_block.build();
    m_ral_block.reset();
    m_ral_block.lock_model();
    m_ral_block.map.set_auto_predict(0);
    //send RAL model to every place
    uvm_config_db#(ral_reg_bank_block)::set(this, "*", "ral_reg_bank_block", m_ral_block);
    //RAL Agent and Scoreboard
    m_ral_reg_bank_agent = ral_reg_bank_agent::type_id::create("m_ral_reg_bank_agent", this);
    m_ral_reg_bank_sb = ral_reg_bank_scoreboard::type_id::create("m_ral_reg_bank_sb", this);

    // FPU
    //--------------------------------------------------------------------------------
    m_fpu_agent = fpu_agent::type_id::create("m_fpu_agent",this);
    m_fpu_cov = fpu_coverage::type_id::create("m_fpu_cov",this);
    // Configuration
    m_fpu_config = fpu_config::type_id::create("m_fpu_config", this);
    uvm_config_db#(fpu_config)::set(this, "m_fpu_agent", "fpu_config", m_fpu_config);

    // FPU_APB
    //--------------------------------------------------------------------------------
    m_apb_agent = fpu_apb_agent::type_id::create("m_apb_agent",this);
    m_apb_cov = fpu_apb_coverage::type_id::create("m_apb_cov",this);
    // Configuration
    m_fpu_apb_config = fpu_apb_config::type_id::create("m_fpu_apb_config", this);
    uvm_config_db#(fpu_apb_config)::set(this, "m_apb_agent", "fpu_apb_config", m_fpu_apb_config);

    // Common Classes
    //--------------------------------------------------------------------------------
    m_sb = fpu_scoreboard::type_id::create("m_sb",this);
  endfunction

  //FUNCTION: CONNECT PHASE
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    //RAL:Connecting monitor ap to scoreboard ap
    //--------------------------------------------------------------------------------
    m_ral_reg_bank_agent.m_monitor.item_collect_port.connect(m_ral_reg_bank_sb.item_collect_export);

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
