
class fpu_test extends uvm_test;
  `uvm_component_utils(fpu_test)

  // Environment handle
  fpu_env m_fpu_env;
  fpu_sequence m_fpu_seq;

  // Constructor
  function new(string name = "fpu_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_fpu_seq = fpu_sequence::type_id::create("m_fpu_seq");
    m_fpu_env = fpu_env::type_id::create("m_fpu_env", this);
  endfunction

  // run phase
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    m_fpu_seq.start(m_fpu_env.m_fpu_agent.m_sequencer);
    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this,20);
  endtask

endclass
