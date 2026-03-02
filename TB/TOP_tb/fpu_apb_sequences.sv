class fpu_apb_base_sequence extends uvm_sequence #(fpu_apb_seq_item);
  //REGISTERATION
  `uvm_object_utils(fpu_apb_base_sequence)

  //CONSTRUCTOR
  function new (string name = "fpu_apb_base_sequence");
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
  virtual task body ;
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

class fpu_apb_corner_sequence extends fpu_apb_base_sequence;
  `uvm_object_utils(fpu_apb_corner_sequence)

  function new (string name = "fpu_apb_corner_sequence");
    super.new(name);
  endfunction

  task body;
    super.body();
    //DIRECTED SEQUENCE
    direct_seq(32'h0000_0000, 32'hffff_ffff, 3'b010); // Not a number checking scenario (addition)
    direct_seq(32'hffff_ffff, 32'h0fff_ffff, 3'b010); // Not a number checking scenario (multplication)
    direct_seq(32'hFF7F_FFFF, 32'hFF7F_FFFF, 3'b000); // Adding minimum values to check -ve infinity scenario
    direct_seq(32'h7F7F_FFFF, 32'h7F7F_FFFF, 3'b000); // Adding maxmium values to check +ve infinity scenario
    direct_seq(32'h7F7F_FFFF, 32'hFF7F_FFFF, 3'b000); // Adding maximum value to minimum value to check zero scenario
    direct_seq(32'h7F7f_FFFF, 32'h3f80_0000, 3'b010); // Multiplying maximum value with one to check maximum value scenario
    direct_seq(32'hFF7F_FFFF, 32'h3f80_0000, 3'b010); // Multiplying minimum value with one to check minimum value scenario
    direct_seq(32'h0000_0000, 32'h0000_0000, 3'b010); // Multiplying zero with zero
  endtask

  task direct_seq(bit [31:0] op1, bit [31:0] op2, bit [2:0] operation_select);
    req = fpu_apb_seq_item::type_id::create("req");
    start_item(req);
      assert(req.randomize() with {
        PADDR == fpu_apb_package::OP1_ADDR;
        PWRITE == 1;
        PWDATA == op1;
      })
        else `uvm_fatal(get_name(), "RANDOMIZATION FAILED IN OP1 SEQUENCE");
    finish_item(req);

    req = fpu_apb_seq_item::type_id::create("req");
    start_item(req);
      assert(req.randomize() with {
        PADDR == fpu_apb_package::OP2_ADDR;
        PWRITE == 1;
        PWDATA == op2;
      })
        else `uvm_fatal(get_name(), "RANDOMIZATION FAILED IN OP2 SEQUENCE");
    finish_item(req);


    req = fpu_apb_seq_item::type_id::create("req");
    start_item(req);
      assert(req.randomize() with {
        PADDR == fpu_apb_package::OPERATION_SELECT_ADDR;
        PWRITE == 1;
        PWDATA[2:0] == operation_select;
      })
        else `uvm_fatal(get_name(), "RANDOMIZATION FAILED IN OPERATION SELECT SEQUENCE");
    finish_item(req);

    req = fpu_apb_seq_item::type_id::create("req");
    start_item(req);
      assert(req.randomize() with {
        PADDR == fpu_apb_package::FLAGS_ADDR;
        PWRITE == 0;
      })
        else `uvm_fatal(get_name(), "RANDOMIZATION FAILED IN FLAGS SEQUENCE");
    finish_item(req);

    req = fpu_apb_seq_item::type_id::create("req");
    start_item(req);
      assert(req.randomize() with {
        PADDR == fpu_apb_package::RESULT_ADDR;
        PWRITE == 0;
      })
        else `uvm_fatal(get_name(), "RANDOMIZATION FAILED IN RESULT SEQUENCE");
    finish_item(req);
  endtask


endclass
