class fpu_apb_sequence extends uvm_sequence #(fpu_apb_seq_item);
  //REGISTERATION
  `uvm_object_utils(fpu_apb_sequence)

  //CONSTRUCTOR
  function new (string name = "fpu_apb_sequence");
    super.new(name);
  endfunction

  //==============================================================================
  //BODY
  //==============================================================================
  // The sequence of addresses of OP1 to .... RESULT
  bit wr_en; // high > write, low > read
  addr_e addr;
  int enum_total_num;
  bit [7:0] op1_exp, op2_exp;
  task body ;
    enum_total_num = addr.num();
    addr = addr.first();
    repeat (fpu_apb_package::SEQUENCES) begin
      repeat (enum_total_num) begin
        req = fpu_apb_seq_item::type_id::create("req");

        if((addr == fpu_apb_package::FLAGS_ADDR) || (addr == fpu_apb_package::RESULT_ADDR))
          wr_en = 0;
        else
          wr_en = 1;

        start_item(req);
          assert(req.randomize() with {
            PADDR == addr;
            PWRITE == wr_en;
            //if one of the operands is denormalized and other is underflow,
            //the operation select should not be multiplication, to avoid illegal operand exception in the Designed FPU.
            if (PADDR == fpu_apb_package::OPERATION_SELECT_ADDR) {
              if ((op2_exp != 0 && op1_exp == 0) || (op2_exp == 0 && op1_exp != 0))
              {
                PWDATA[2:0] != 3'b010;
              }
              else {
                PWDATA[2:0] dist {[0:2] :/ 999, [3:7]:/ 1};
              }
            }
          }
          )
            else `uvm_fatal(get_name(), "RANDOMIZATION FAILED IN ADDR SEQUENCE");
        finish_item(req);
        op1_exp = (addr == fpu_apb_package::OP1_ADDR) ? req.PWDATA[30:23] : op1_exp;
        op2_exp = (addr == fpu_apb_package::OP2_ADDR) ? req.PWDATA[30:23] : op2_exp;
        addr = addr.next();
      end
    end
  endtask

endclass


