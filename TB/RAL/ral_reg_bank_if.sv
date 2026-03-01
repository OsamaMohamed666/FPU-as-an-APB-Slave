interface ral_reg_bank_if(
  input clk
);
  //INPUTS
  bit                        rstn;

  //APB SLAVE SIGNALS
  bit                        enable_register;
  bit        [2:0]           register_addr;
  bit        [31:0]          PWDATA;
  bit                        write_enable;
  bit                        read_enable;
  logic      [31:0]          PRDATA;

  //FPU SIGNALS
  logic       [31:0]           OP1;
  logic       [31:0]           OP2;
  logic       [2:0]            OP_select;


endinterface
