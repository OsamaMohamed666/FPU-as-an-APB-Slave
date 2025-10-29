class fpu_apb_sequencer extends uvm_sequencer #(fpu_apb_seq_item);
  //REGISTERATION
  `uvm_component_utils(fpu_apb_sequencer)

  //CONSTRUCTOR
  function new (string name = "fpu_apb_sequncer", uvm_component parent);
    super.new(name,parent);
  endfunction

  //BUILD PHASE
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
  endfunction

endclass
