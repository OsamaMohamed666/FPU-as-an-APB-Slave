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

//Clocking Block
clocking cb @(posedge clk);
  default input #1step output #((fpu_package::CLK_PERIOD)/2);

  //Outputs
  output OP1;
  output OP2;
  output OP_select;

  //Inputs
  input data_valid;
  input zero_flag;
  input INF_flag;
  input NAN_flag;
  input Result;
endclocking

// Modport for driver
modport driver_mp (clocking cb, input clk, output rstn);

endinterface
