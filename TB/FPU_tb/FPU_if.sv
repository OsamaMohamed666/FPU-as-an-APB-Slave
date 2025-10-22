`include "uvm_macros.svh"
import uvm_pkg::*;

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

//Modport for driver
modport driver_mp (clocking cb, input clk, output rstn);


//ASSERTIONS

//1) Reset checking
property reset_chk;
  @(posedge clk)
  !rstn |-> (Result==32'b0);
endproperty

assert property(reset_chk)
  else `uvm_error("ASSERTIONS" ," RESET STATE IS VIOLATED")
reset_chk_p1: cover property (reset_chk);

//2) Checking not a number flag is hitted by op1 and op2
property op1_op2_NAN;
  @(negedge clk) disable iff  (!rstn)  (OP_select ==0 || OP_select ==1 || OP_select ==2)
  |-> ($rose(OP1[30:23]==8'hff) || $rose(OP2[30:23]==8'hff)) ##0 ($rose(OP1[22:0] !=0) || $rose(OP1[22:0] !=0))
  |-> NAN_flag;
endproperty

assert property(op1_op2_NAN)
  else `uvm_error("ASSERTIONS" ," OPERANDS NOT A NUMBER CHECKING IS VIOLATED");
op1_op2_NAN_p2: cover property (op1_op2_NAN);

// //3) Checking infinite flag is hitted by op1 and op2
// property op1_op2_INF;
//   @(negedge clk) disable iff  (!rstn)  (OP_select ==0 || OP_select ==1 || OP_select ==2)
//   |-> ($rose(OP1[30:23]==8'hff) || $rose(OP2[30:23]==8'hff)) ##0 ($rose(OP1[22:0] ==0) || $rose(OP1[22:0] ==0))
//   ##0 !NAN_flag |-> INF_flag; // checking that op1 or op2 isnot a nan as nan is the dominant flag
// endproperty

// assert property(op1_op2_INF)
//   else `uvm_error("ASSERTIONS" ," INFINITE OPERANDS CHECKING IS VIOLATED");
// op1_op2_INF_p3: cover property (op1_op2_INF) $display("The prop property 3 is hit");

//3) Checking not a number flag is hitted by Result
property result_NAN;
  @(negedge clk) disable iff  (!rstn)
  $rose(Result[30:23]==8'hff) ##0 $rose(Result[22:0] !=0)
  |-> NAN_flag;
endproperty
  assert property(result_NAN)
  else `uvm_error("ASSERTIONS" ," RESULT NOT A NUMBER CHECKING IS VIOLATED");
result_NAN_p4: cover property(result_NAN);

//4) Checking INF flag is hitted by Result
property result_INF;
  @(negedge clk) disable iff  (!rstn)
  $rose(Result[30:23]==8'hff) ##0 $rose(Result[22:0] == 23'b0)
  |-> INF_flag;
endproperty

assert property(result_INF)
  else `uvm_error("ASSERTIONS" ," RESULT INFINITE  CHECKING IS VIOLATED");
result_INF_p5: cover property(result_INF);


endinterface
