`include "uvm_macros.svh"
module fpu_top;
  import uvm_pkg::*;
  import fpu_package::*;

  bit clk;
  //bit rstn;

  always #5 clk = ~clk;
  initial begin
    clk = 0;
    //rstn = 0;
    //#10 rstn = 1;
  end

  fpu_if intf(.clk(clk)); //, .rstn(rstn));

  FPU DUT(
  .clk(clk),
  .rstn(intf.rstn),
  .OP1(intf.OP1),
  .OP2(intf.OP2),
  .OP_select(intf.OP_select),
  .data_valid(intf.data_valid),
  .zero_flag(intf.zero_flag),
  .INF_flag(intf.INF_flag),
  .NAN_flag(intf.NAN_flag),
  .Result(intf.Result)
  );

  initial begin
    // configure virtual interface
    uvm_config_db#(virtual fpu_if)::set(null, "*", "vif", intf);
     // Dump waves
    $dumpfile("fpu_top.vcd");
    $dumpvars;
  end

  // run the test
  initial begin
    run_test("fpu_test");
  end
endmodule
