`include "uvm_macros.svh"
import uvm_pkg::*;
interface fpu_apb_if(input bit CLK);
//INPUTS
bit               RSTN;
bit        [31:0] PADDR;
bit        [31:0] PWDATA;
bit               PWRITE;
bit               PSEL;
bit               PENABLE;
//OUTPUTS
logic      [31:0] PRDATA;
logic             PREADY;
logic             PSLVERR;

//CLOCKING BLOCK
clocking cb @(posedge CLK);
  default input #1step output #((fpu_apb_package::CLK_PERIOD)/2);
  output      PADDR;
  output      PWDATA;
  output      PWRITE;
  output      PSEL;
  output      PENABLE;

  input       PRDATA;
  input       PREADY;
  input       PSLVERR;
endclocking

// DRIVER MODPORT
modport driver_mp (clocking cb, input CLK, output RSTN);

endinterface
