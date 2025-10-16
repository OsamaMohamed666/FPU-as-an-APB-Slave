interface fpu_if (input bit clk); //, bit rstn);

bit rstn;

bit [31:0] OP1;
bit [31:0] OP2;
bit [2:0]  OP_select;


logic  data_valid;
logic  zero_flag;
logic  INF_flag;
logic  NAN_flag;

logic [31:0] Result;

//Clocking Blocks for driver and monitors

endinterface
