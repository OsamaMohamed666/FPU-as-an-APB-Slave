class ral_reg_bank_model extends uvm_reg;

  `uvm_object_utils(ral_reg_bank_model)

  //Reg field model for the registers
  uvm_reg_field data_32bits;

  function new(string name = "ral_reg_bank_model");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction


  virtual function void build();
    this.data_32bits = uvm_reg_field::type_id::create("data_32bits");
    data_32bits.configure(this,32,0,"RW",0,32'b0,1,1,1);
  endfunction
endclass
