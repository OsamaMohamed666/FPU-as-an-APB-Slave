class fpu_apb_sequence extends uvm_sequence #(fpu_apb_seq_item);
  //REGISTERATION
  `uvm_object_utils(fpu_apb_sequence)

  //CONSTRUCTOR
  function new (string name = "fpu_apb_sequence");
    super.new(name);
  endfunction

  //BODY
  task body;
    rsp = fpu_apb_seq_item::type_id::create("rsp");
    repeat (fpu_apb_package::SEQUENCES) begin
      req = fpu_apb_seq_item::type_id::create("req");

      start_item(req);
      //Check if its the operation select phase to apply specific constraints
      if(rsp.op_select_phase) begin
        `uvm_info(get_type_name(), $sformatf("\nexponent1 %b, exponent2 %b", rsp.op1_exponent, rsp.op2_exponent),UVM_HIGH);
        `uvm_info(get_type_name(), "\nRE-RANDOMIZING THE SEQUENCE ITEM WITH OP SELECT CONSTRAINTS!\n", UVM_HIGH);
        assert(req.randomize() with {
          PWDATA[2:0] dist {[0:2] :/ 98, [3:7]:/ 2};

          //if one of the operands is denormalized and other is underflow,
          //the operation select should not be multiplication, to avoid illegal operand exception in the Designed FPU.
          if ((rsp.op2_exponent != 0 && rsp.op1_exponent == 0) || (rsp.op2_exponent == 0 && rsp.op1_exponent != 0))
          {
            PWDATA[2:0] != 3'b010;
          }
        }
        )
          else  `uvm_fatal(get_name(),"RANDOMIZATION  FAILED IN OP SELECT PHASE");
      end

      //If not in operation select phase, randomize normally
      else begin
        assert(req.randomize())
          else  `uvm_fatal(get_name(),"RANDOMIZATION FAILED");
      end
      finish_item(req);

      get_response(rsp);
        `uvm_info(get_type_name(), $sformatf("OP SELECT PHASE CHECKING"), UVM_MEDIUM);
    end
  endtask

endclass
