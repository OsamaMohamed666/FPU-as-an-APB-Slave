class fpu_seq_item extends uvm_sequence_item;
  //REGISTERATION
  `uvm_object_utils(fpu_seq_item)

  //CONSTRUCTOR
  function new (string name = "fpu_seq_item");
    super.new(name);
  endfunction

  //DATA MEMBERS
  rand bit rstn;

  rand bit [31:0] OP1;
  rand bit [31:0] OP2;
  rand bit [2:0]  OP_select;

  logic  data_valid;
  logic  zero_flag;
  logic  INF_flag;
  logic  NAN_flag;

  //FPU Result
  logic [31:0] Result;

  //==================================================================================
  // Constraints
  //==================================================================================
  constraint operands_c {
    solve OP1 before OP2;
    OP1 dist { 32'hffff_ffff :/ 1, 32'h0 :/ 1, 32'h7f7f_ffff :/ 1, 32'hff7f_ffff :/ 1, [32'h1 : 32'hffff_fffe] :/ 96};
    OP2 dist { 32'hffff_ffff :/ 1, 32'h0 :/ 1, 32'h7f7f_ffff :/ 1, 32'hff7f_ffff :/ 1, OP1 :/ 3, [32'h1 : 32'hffff_fffe] :/ 93};
  }


  // decreasing the probability of choosing default selection
  constraint selection_c {
    OP_select dist { 3'b0 := 33, 3'b001 := 33, 3'b010 := 33, [3'b011 : 3'b111]:= 1};
  }


  constraint multiply_c {
    (OP_select==3'b010) -> (OP1[30:23] !=0  && OP2[30:23] !=0);
  }

  constraint reset_c {
    soft rstn == 1'b1;
  }


endclass
