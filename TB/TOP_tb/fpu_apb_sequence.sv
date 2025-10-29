class fpu_apb_sequence extends uvm_sequence #(fpu_apb_seq_item);
  //REGISTERATION
  `uvm_object_utils(fpu_apb_sequence)

  //CONSTRUCTOR
  function new (string name = "fpu_apb_sequence");
    super.new(name);
  endfunction

  //BODY
  task body;
    repeat (fpu_apb_package::SEQUENCES) begin
      req = fpu_apb_seq_item::type_id::create("req");

      start_item(req);
      assert(req.randomize())
        else  `uvm_fatal(get_name(),"RANDOMIZATION FAILD");
      finish_item(req);
    end
  endtask

endclass
