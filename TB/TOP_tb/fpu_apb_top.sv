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

  // INTERFACE INSTANTIATION
  fpu_apb_if INTF(CLK);

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

  // UVM CONFIGURATION
  initial begin
    uvm_config_db#(virtual fpu_apb_if)::set(null,"*","vif",INTF);
  end

  //RUNNING UVM TEST
  initial begin
    run_test("fpu_apb_test");
  end
endmodule
