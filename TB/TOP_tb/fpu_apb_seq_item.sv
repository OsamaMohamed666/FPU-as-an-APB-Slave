class fpu_apb_seq_item extends uvm_sequence_item;
  //REGISTERATION
  `uvm_object_utils(fpu_apb_seq_item)

  //CONSTRUCTOR
  function new (string name = "fpu_apb_seq_item");
    super.new(name);
  endfunction

  //DATA MEMBERS
  rand  bit             RSTN;
  rand  bit             PSEL;
  rand  bit             PWRITE;
  rand  bit             PENABLE;
  rand  bit      [31:0] PADDR;
  rand  bit      [31:0] PWDATA;

  logic          [31:0] PRDATA;
  logic                 PREADY;
  logic                 PSLVERR;

  // RESPONSE INFO
  bit op_select_phase;
  bit [7:0] op1_exponent;
  bit [7:0] op2_exponent;


  //==================================================================================
  // CONSTRAINTS
  //==================================================================================
  //1) PUT PSEL HIGH TO ACTIVATE THE FPU SLAVE
 constraint slave_select_c {
    soft PSEL == 1;
  }
  //2) INCREASING THE CHANCE OF HITTING THE USABLE ADDRESSES
  // rand int usable_addresses;
  // constraint addresses_c {
  //   solve usable_addresses before PADDR;
  //   usable_addresses inside {32'hFFFF0000, 32'hFFFF0004, 32'hFFFF0008, 32'hFFFF000C, 32'hFFFF0010};
  //   // addresses of: op1, op2, operation_select, flags, output result, respectively.
  //   PADDR dist {usable_addresses :/ 99, !usable_addresses :/ 1};
  // }

  //3) INCREASING THE CHANCE OF HITING USABLE OPERTIONS
  // constraint opertion_select_c{
  //   solve PADDR before PWDATA;
  //   if(PADDR == 32'hFFFF0008) {
  //     PWDATA[2:0] dist {[0:2] :/ 98, [3:7]:/ 2};
  //     if (PWDATA[2:0] == 3'b010) {
  //       (PWDATA[30:23] != 0); }
  //     }
  //   }




endclass
