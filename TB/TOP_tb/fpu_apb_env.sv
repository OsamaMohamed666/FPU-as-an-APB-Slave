class fpu_apb_env extends uvm_env;
  //REGISTERATION
  `uvm_component_utils(fpu_apb_env)

  //AGENT HANDLE
  fpu_apb_agent m_agent;

  //CONSTRUCTOR
  function new (string name = "fpu_apb_env", uvm_component parent);
    super.new(name,parent);
  endfunction

  //BUILD PHASE
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_agent = fpu_apb_agent::type_id::create("m_agent",this);
  endfunction
endclass
