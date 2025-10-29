class fpu_apb_seq_item extends uvm_sequence_item;
  //REGISTERATION
  `uvm_object_utils(fpu_apb_seq_item)

  //CONSTRUCTOR
  function new (string name = "fpu_apb_seq_item");
    super.new(name);
  endfunction

  //DATA MEMBERS
  rand  bit             RSTN;
  rand  bit      [31:0] PADDR;
  rand  bit      [31:0] PWDATA;
  rand  bit             PWRITE;
  rand  bit             PSEL;
  rand  bit             PENABLE;

  logic      [31:0] PRDATA;
  logic             PREADY;
  logic             PSLVERR;

  //==================================================================================
  // CONSTRAINTS
  //==================================================================================

endclass
