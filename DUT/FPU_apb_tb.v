module FPU_apb_tb();

parameter APB_ADDR_WIDTH = 32;

   reg                        CLK_tb;
   reg                        RSTN_tb;

   reg    [APB_ADDR_WIDTH-1:0] PADDR_tb;
   reg                  [31:0] PWDATA_tb;
   reg                         PWRITE_tb;
   reg                         PSEL_tb;
   reg                         PENABLE_tb;


    wire                [31:0] PRDATA_tb;
    wire                       PREADY_tb;
    wire                       PSLVERR_tb;      






reg [31:0] DATA;
reg [31:0] ADDR;

////////DUT///////////

FPU_APB     #(.APB_ADDR_WIDTH(APB_ADDR_WIDTH)) 

FPU1(.CLK(CLK_tb),
	 .RSTN(RSTN_tb),
	 .PADDR(PADDR_tb),
	 .PWDATA(PWDATA_tb),
	 .PWRITE(PWRITE_tb),
	 .PSEL(PSEL_tb),
	 .PENABLE(PENABLE_tb),
	 .PRDATA(PRDATA_tb),
	 .PREADY(PREADY_tb),
	 .PSLVERR(PSLVERR_tb)


	);

///////////////CLK Generation//////////////////
initial begin
	CLK_tb=1'b0;
	forever begin
		#10; CLK_tb=~CLK_tb;
	end
end



////////////Test stimulus////////////

initial begin
 
 RSTN_tb=1'b0;
 #20;
 RSTN_tb=1'b1; 


 ADDR='hFFFF0000; DATA=32'b0_10000001_00100000000000000000000;
 Write_transfer(ADDR,DATA);

ADDR='hFFFF0004; DATA=32'b0_10000000_11100000000000000000000;
 Write_transfer(ADDR,DATA);

ADDR='hFFFF0008;DATA=32'b0;
Write_transfer(ADDR,DATA);
#40 
ADDR='hFFFF0010;
Read_transfer(ADDR);
$display ("3.75  4.5 at @%0t",$time);
$display("add result is %h",PRDATA_tb,$time);

ADDR='hFFFF0000; DATA=32'b0_10000001_00100000000000000000000;
 Write_transfer(ADDR,DATA);

ADDR='hFFFF0004; DATA=32'b0_10000000_11100000000000000000000;
 Write_transfer(ADDR,DATA);

ADDR='hFFFF0008;DATA=32'b1;
Write_transfer(ADDR,DATA);

 
ADDR='hFFFF0010;
Read_transfer(ADDR);
$display ("3.75  4.5 at @%0t",$time);
$display("add result is %h",PRDATA_tb,$time);

ADDR='hFFFF0000; DATA=32'b0_10000001_00100000000000000000000;
 Write_transfer(ADDR,DATA);

ADDR='hFFFF0004; DATA=32'b0_10000000_11100000000000000000000;
 Write_transfer(ADDR,DATA);

ADDR='hFFFF0008;DATA=32'b0;
Write_transfer(ADDR,DATA);

ADDR='hFFFF0010;
Read_transfer(ADDR);
$display ("3.75  4.5 at @%0t",$time);
$display("add result is %h",PRDATA_tb,$time);

ADDR='hFFFF0000; DATA=32'b1_01111110_10011001100110011001101;
$display ("data 2nd is %0h", DATA);
Write_transfer(ADDR,DATA);

ADDR='hFFFF0004; DATA=32'b0_10000000_11011001100110011001101;
$display ("data 2nd is %0h", DATA);
Write_transfer(ADDR,DATA);

ADDR='hFFFF0008; DATA=32'b00010;
Write_transfer(ADDR,DATA);

ADDR='hFFFF0010;
Read_transfer(ADDR);
//PENABLE_tb=1'b0;
$display ("-0.8 * 3.2 = 2.56 at @%0t",$time);

$display("Mult result is %h",PRDATA_tb,$time);


#250;
$stop; 
	
end

task Write_transfer;
   
   input [31:0] ADDR;
   input [31:0] DATA;
   
   begin
   	@(posedge CLK_tb)  PADDR_tb=ADDR; PWRITE_tb=1'b1; PSEL_tb=1'b1;
   	                   PWDATA_tb=DATA;PENABLE_tb=1'b0;

   	@(posedge CLK_tb)  PENABLE_tb=1'b1;
   	@(posedge CLK_tb)  PENABLE_tb=1'b0;
	

   	//wait(PREADY_tb==1'b1); 
    
    ////Write transfer with no wait///////
    //@(posedge CLK_tb)  PENABLE_tb=1'b0;PSEL_tb=1'b0;                   
   end

  endtask

  task Read_transfer;
         input [31:0] ADDR;
         begin
         	@(posedge CLK_tb) PADDR_tb='hFFFF0010; PWRITE_tb=1'b0; PSEL_tb=1'b1;
         	                  PWDATA_tb=0; PENABLE_tb=1'b0;

         	@(posedge CLK_tb) PENABLE_tb=1'b1;
              
            wait(PREADY_tb==1'b1);
         	end                   
  endtask

  endmodule
