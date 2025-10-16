class fpu_sequence extends uvm_sequence #(fpu_seq_item);
  // REGISTERATION
  `uvm_object_utils(fpu_sequence)

  // SEQUENCE ITEM HANDLE
  fpu_seq_item req;

  //CONSTRUCTOR
  function new (string name = "fpu_sequence");
    super.new(name);
  endfunction

  //TASK : BODY
  task body;
    repeat (fpu_package::SEQUENCES) begin
      req = fpu_seq_item::type_id::create("req");
      start_item(req);

      if(!req.randomize()) // with {req.OP_select inside{0,1,2};})
        `uvm_fatal (get_name(), "FPU RANDOMZATION FAILED");
      finish_item(req);
    end
  endtask
endclass
