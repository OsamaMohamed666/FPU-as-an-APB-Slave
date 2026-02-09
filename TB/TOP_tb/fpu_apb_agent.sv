class fpu_apb_agent extends uvm_agent;
  //REGISTERATION
  `uvm_component_utils(fpu_apb_agent)

  //CLASSES HANDELS
  fpu_apb_sequencer m_sequencer;
  fpu_apb_driver m_driver;
  fpu_apb_monitor_in m_monitor_in;
  fpu_apb_monitor_out m_monitor_out;

  //CONSTRUCTOR
  function new (string name = "fpu_apb_agent", uvm_component parent);
    super.new(name,parent);
  endfunction

  //BUILD PHASE
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_sequencer = fpu_apb_sequencer::type_id::create("m_sequencer",this);
    m_driver = fpu_apb_driver::type_id::create("m_driver",this);
    m_monitor_in = fpu_apb_monitor_in::type_id::create("m_monitor_in",this);
    m_monitor_out = fpu_apb_monitor_out::type_id::create("m_monitor_out",this);
  endfunction

  //CONNECT PHASE
  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
  endfunction

endclass
