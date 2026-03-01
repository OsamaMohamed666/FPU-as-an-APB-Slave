class ral_reg_bank_block extends uvm_reg_block;

  `uvm_object_utils(ral_reg_bank_block)

  //Handles for the model class for 5 registers
  signals_id_e id;
  ral_reg_bank_model fpu_regs[];
  // ral_reg_bank_model op1;
  // ral_reg_bank_model op2;
  // ral_reg_bank_model operation_select;
  // ral_reg_bank_model flags;
  // ral_reg_bank_model fpu_result;

  //Handle for the map
  uvm_reg_map map;

  function new(string name = "ral_reg_bank_block");
    super.new(name,UVM_NO_COVERAGE);
  endfunction

  function void build();
    //adding hdl path
    add_hdl_path("fpu_apb_top.DUT.reg1");

    //creating map
    //              (map_name, base address, bus width, endianness, offset)
    map = create_map("map", 'h0, 4, UVM_LITTLE_ENDIAN, 0);

    //creating the regs
    //id = id.first();
    fpu_regs=new[id.num()];
    foreach (fpu_regs[i]) begin
      id = signals_id_e'(i);
      fpu_regs[i] = ral_reg_bank_model::type_id::create(id.name());
      fpu_regs[i].configure(this, null, $sformatf("mem[%0d]", i));
      fpu_regs[i].build();
      map.add_reg(fpu_regs[i],i,"RW");
    end


  endfunction
endclass
