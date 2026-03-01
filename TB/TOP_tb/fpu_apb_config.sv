class fpu_apb_config extends uvm_object;
  `uvm_object_utils(fpu_apb_config)

  uvm_active_passive_enum is_active;

  function new(string name = "fpu_apb_config");
    super.new(name);
    is_active = UVM_ACTIVE; // Default to active mode
  endfunction
endclass
