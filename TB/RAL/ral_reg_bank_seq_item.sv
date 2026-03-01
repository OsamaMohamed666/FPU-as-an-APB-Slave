class ral_reg_bank_seq_item extends uvm_sequence_item;

  `uvm_object_utils(ral_reg_bank_seq_item)

  function new(string name = "ral_reg_bank_seq_item");
    super.new(name);  
  endfunction

  //DATA MEMBERS FOR THE SEQUENCE ITEM
  //INPUTS
  bit                        rstn;

  //APB SLAVE SIGNALS
  bit                        enable_register; // PSEL&&PENABLE
  bit        [2:0]           register_addr;
  bit        [31:0]          PWDATA;
  bit                        write_enable;
  bit                        read_enable;
  logic      [31:0]          PRDATA;

  //FPU SIGNALS
  logic       [31:0]           OP1;
  logic       [31:0]           OP2;
  logic       [2:0]            OP_select;

  //REFERENCE SIGNAL
  bit        [31:0]          actual_mem_data;
endclass
