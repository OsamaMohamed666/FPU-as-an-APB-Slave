`include "Normalize_add.v"
`include "Fpu_add.v"
`include "Floating_point_multiplication.v"
module FPU
  (
  input                    clk,rstn,
  input       [31:0]       OP1,
  input       [31:0]       OP2,
  input       [2:0]        OP_select,
  output reg  [31:0]       Result,
  output reg               data_valid,
  output                   zero_flag,
  output                   INF_flag,
  output                   NAN_flag
  );

//***********************Operation Select Signals***********************
reg add_select, sub_select,
    mult_select;

//***********************Output Select Signals***********************
wire   [31:0]  Add_Result,
              MULT_Result;

wire           Add_valid,Mult_valid;

//***********************Logic Block To Select The Operation***********************
always@(*)begin
  add_select=1'b0;
  sub_select=1'b0;
  mult_select=1'b0;

  case(OP_select)
  3'b000  : add_select  = 1'b1;
  3'b001  : sub_select  = 1'b1;
  3'b010  : mult_select = 1'b1;
  default : begin
              mult_select = 1'b0;
              add_select  = 1'b0;
              sub_select  = 1'b0;
            end
  endcase
end


//***********************Instantiation of ADD or SUB two floating point numbers Module***********************
Fpu_add Add1(
.OP1(OP1),
.OP2(OP2),
.add_select(add_select),
.sub_select(sub_select),
.Result_comb(Add_Result),
.valid(Add_valid)
);


//***********************Instantiation of Multiplying two floating point numbers Module***********************
FPU_MULT MULT1(.clk(clk),
.rstn(rstn),
.OP1(OP1),
.OP2(OP2),
.mult_select(mult_select),
.Result_comb(MULT_Result),
.valid(Mult_valid)
);


//***********************Muxing the output of logic blocks***********************
//Taking in care if the input is not a valid number or a string
always@(*)begin
  if (&OP1[30:23] && &OP2[30:23] && (add_select || sub_select || mult_select))begin
    //When op1 is Not a number, the result will be the same.
    if (!(|OP1[22:0]))
      Result = OP1;
    // When op2 is not a number or both are infinity, the result will be the same.
    else
      Result = OP2;
  end

  else if (&OP1[30:23] && (add_select || sub_select || mult_select))
    Result = OP1;

  else if (&OP2[30:23] && (add_select || sub_select || mult_select))
    Result = OP2;

  else if(OP_select[1])
    Result=MULT_Result;

  else
    Result=Add_Result;
end

//***********************Data Valid Selection***********************
always@(*)begin
  if(mult_select==1'b1)begin
    data_valid=Mult_valid;
  end

  else if ((add_select || sub_select))begin
    data_valid=Add_valid;
  end

  else begin
    data_valid=1'b0;
  end
end

//***********************Output Flags***********************
assign zero_flag = !(|Result) ;
assign INF_flag = (&Result[30:23]) && (!(|Result[22:0]))  ;
assign NAN_flag = (&Result[30:23]) && (|Result[22:0]) ;

endmodule


