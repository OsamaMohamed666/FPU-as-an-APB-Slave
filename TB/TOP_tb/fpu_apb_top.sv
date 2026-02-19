`include "uvm_macros.svh"
module fpu_apb_top;
  import uvm_pkg::*;
  import fpu_apb_package::*;

  bit CLK;
  //CLOCK GENERATOR
  always #((fpu_apb_package::CLK_PERIOD)/2) CLK =~CLK;
  initial begin
    CLK=0;
    // Dump waves
    $dumpfile("fpu_top.vcd");
    $dumpvars;
  end

  // INTERFACES INSTANTIATION
  fpu_apb_if INTF(CLK);
  fpu_if fpu_intf(CLK);

  //DUT INSTANTIATION
  FPU_apb DUT(
  .CLK(CLK),
  .RSTN(INTF.RSTN),
  .PADDR(INTF.PADDR),
  .PWDATA(INTF.PWDATA),
  .PWRITE(INTF.PWRITE),
  .PSEL(INTF.PSEL),
  .PENABLE(INTF.PENABLE),
  .PRDATA(INTF.PRDATA),
  .PREADY(INTF.PREADY),
  .PSLVERR(INTF.PSLVERR)
  );
  bit rstn;

bit [31:0] OP1;
bit [31:0] OP2;
bit [2:0]  OP_select;


logic  data_valid;
logic  zero_flag;
logic  INF_flag;
logic  NAN_flag;

logic [31:0] Result;

  //ASSIGNING FPU INTERFACE SIGNALS TO FPU APB INTERNAL SIGNALS
  assign fpu_intf.rstn = DUT.FPU1.rstn;
  assign fpu_intf.OP1 = DUT.FPU1.OP1;
  assign fpu_intf.OP2 = DUT.FPU1.OP2;
  assign fpu_intf.OP_select = DUT.FPU1.OP_select;
  assign fpu_intf.data_valid = DUT.FPU1.data_valid;
  assign fpu_intf.zero_flag = DUT.FPU1.zero_flag;
  assign fpu_intf.INF_flag = DUT.FPU1.INF_flag;
  assign fpu_intf.NAN_flag = DUT.FPU1.NAN_flag;
  assign fpu_intf.Result = DUT.FPU1.Result;

  // UVM CONFIGURATION
  initial begin
    uvm_config_db#(virtual fpu_apb_if)::set(null,"*","vif",INTF);
    uvm_config_db#(virtual fpu_if)::set(null,"*","fpu_vif",fpu_intf);
  end

  //RUNNING UVM TEST
  initial begin
    run_test("fpu_apb_test");
  end
endmodule
