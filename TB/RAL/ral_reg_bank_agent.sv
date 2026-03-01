class ral_reg_bank_agent extends uvm_agent;

  `uvm_component_utils(ral_reg_bank_agent)

  ral_reg_bank_monitor m_monitor;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      m_monitor = ral_reg_bank_monitor::type_id::create("m_monitor", this);
  endfunction
endclass
