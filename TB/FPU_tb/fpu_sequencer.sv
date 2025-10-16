class fpu_sequencer extends uvm_sequencer #(fpu_seq_item);
  //REGISTRATION
  `uvm_component_utils(fpu_sequencer)

  //CONSTRUCTOR
  function new (string name = "fpu_sequencer", uvm_component parent);
    super.new(name,parent);
  endfunction

  //BUILD PHASE
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
  endfunction

endclass
