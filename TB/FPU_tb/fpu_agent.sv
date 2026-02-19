class fpu_agent extends uvm_agent;
  `uvm_component_utils(fpu_agent)

  // Class handles
  fpu_sequencer m_sequencer;
  fpu_driver m_driver;
  fpu_monitor_in m_monitor_in;
  fpu_monitor_out m_monitor_out;
  fpu_config m_config;

  // Constructor
  function new(string name = "fpu_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_config = fpu_config::type_id::create("m_config", this);
    m_monitor_in = fpu_monitor_in::type_id::create("m_monitor_in", this);
    m_monitor_out = fpu_monitor_out::type_id::create("m_monitor_out", this);

    if (!uvm_config_db#(fpu_config)::get(this, "", "fpu_config", m_config)) begin
      `uvm_fatal(get_full_name(), "Failed to get the fpu_config")
    end

    if(m_config.is_active == UVM_ACTIVE) begin
      m_sequencer = fpu_sequencer::type_id::create("m_sequencer", this);
      m_driver = fpu_driver::type_id::create("m_driver", this);
    end

  endfunction

  // Connect phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(m_config.is_active == UVM_ACTIVE) begin
      m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    end
  endfunction

endclass
