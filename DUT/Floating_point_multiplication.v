module FPU_MULT
  (
  input               clk,
  input               rstn,
  input        [31:0] OP1,
  input        [31:0] OP2,
  input               mult_select,

  output       [31:0] Result_comb,
  output reg          valid
  );

//***********************Decompostion Signals***********************
wire        sign1,sign2;
wire [7:0]  Exponent1,Exponent2;
reg  [23:0] Fraction1;
wire [23:0] Fraction2;

//***********************Addition of exponents Signals***********************
reg signed [9:0] Exponent_add,Exponent_add_biased,Exponent_add_reg;

//***********************Fraction Decomposition Signals***********************
reg  [23:0] Fraction1_reg;

wire [11:0] Fraction2_1st;
wire [11:0] Fraction2_2nd;
reg  [11:0] Fraction2_2nd_reg;

//***********************Multiply Fractions Signals***********************
reg [47:0] Fraction_mult;
reg [35:0] Fraction_mult_1st_comb, Fraction_mult_1st_reg;
reg [35:0] Fraction_mult_intermediate;
reg [47:0] Fraction_mult_shift;

//***********************Normalization Signals***********************
reg [24:0] Fraction_normalized;
reg [7:0]  Exponent_normalized;

//***********************Sign Determination Signals***********************
reg sign_res,sign_reg;

//***********************Denormalize Signals***********************
reg denorm;
reg denorm_reg;
reg [8:0] denorm_shift_val ;

//***********************Output temprory Signals***********************
reg valid_1st;
//wire [31:0] Result_comb;


//***********************Floating point Decompostion***********************
assign sign1 = OP1[31] ;
assign sign2 = OP2[31] ;

assign Exponent1 = OP1[30:23];
assign Exponent2 = OP2[30:23];


assign Fraction2 = (Exponent2 == 0)? {1'b0,OP2[22:0]}: {1'b1,OP2[22:0]};
assign Fraction2_1st = Fraction2[11:0];
assign Fraction2_2nd = Fraction2[23:12];


//***********************Sign Detection***********************
always@(sign1,sign2)begin
  if(sign1^sign2)begin
    sign_res=1'b1;
  end

  else begin
    sign_res=1'b0;
  end
end


//***********************Adding Exponents***********************
always @(Exponent1,Exponent2) begin
  Exponent_add=(Exponent1+Exponent2)-127;
end

//***********************Multiply Fractions***********************
always @(Fraction1,Fraction2_1st,Exponent_add) begin
  //Flushed to zero case
  if(Exponent_add < -23) begin
    Fraction1 = 0;
    Fraction_mult_1st_comb= 0;
    Exponent_add_biased= 0;
    denorm= 0;
  end

  //Denormalized case
  else if (Exponent_add < 1) begin
    Fraction1 = {1'b1,OP1[22:0]};
    Fraction_mult_1st_comb = Fraction1 * Fraction2_1st;
    Exponent_add_biased = 0;
    denorm = 1'b1;
  end

  //Round to infinite case
  else if (Exponent_add > 254) begin
    Fraction1 = 0;
    Fraction_mult_1st_comb = 0;
    Exponent_add_biased = 10'hff;
    denorm = 0;
  end

 //Normalized case
  else begin
    Fraction1 = {1'b1,OP1[22:0]};
    Fraction_mult_1st_comb = Fraction1 * Fraction2_1st;
    Exponent_add_biased = Exponent_add;
    denorm = 0;
  end
end



always@(negedge rstn or posedge clk)begin
  if(!rstn)begin
    Fraction_mult_1st_reg<=36'b0;
    sign_reg<=0;
    Exponent_add_reg<=0;
    Fraction2_2nd_reg<=0;
    Fraction1_reg<=0;
    valid_1st<=0;
    denorm_reg<=0;
    denorm_shift_val<=0;
  end

  else if(mult_select) begin
    Fraction_mult_1st_reg<=Fraction_mult_1st_comb;
    sign_reg<=sign_res;
    Exponent_add_reg<=Exponent_add_biased;
    Fraction2_2nd_reg<=Fraction2_2nd;
    Fraction1_reg<=Fraction1;
    valid_1st<=1;
    denorm_reg<=denorm;
    denorm_shift_val<= !Exponent_add? 'b1 : ~Exponent_add + 2'b10;
  end

  else begin
    Fraction_mult_1st_reg<=36'b0;
    sign_reg<=0;
    Exponent_add_reg<=0;
    Fraction2_2nd_reg<=0;
    Fraction1_reg<=0;
    valid_1st<=0;
    denorm_reg<=0;
    denorm_shift_val<=0;
  end
end



//***********************Multiply Fractions***********************
always@(*)begin
  Fraction_mult_intermediate = Fraction1_reg * Fraction2_2nd_reg;
  Fraction_mult_shift = {Fraction_mult_intermediate,12'b0};
  Fraction_mult = denorm_reg? ((Fraction_mult_shift + Fraction_mult_1st_reg) >> denorm_shift_val) : (Fraction_mult_shift + Fraction_mult_1st_reg);
end


//***********************Normalization***********************
always@(Fraction_mult,Exponent_add_reg,denorm_reg)begin
  //denormalization special case
  if(denorm_reg && Fraction_mult[46]==1'b1)begin
    Fraction_normalized = Fraction_mult[47:23];
    Exponent_normalized = Exponent_add_reg+1;
  end

  else if(Fraction_mult[47] == 1'b1)begin
    Fraction_normalized = {1'b0,Fraction_mult[47:24]};
    Exponent_normalized = Exponent_add_reg+1;
  end

  else begin
    Fraction_normalized = Fraction_mult[47:23];
    Exponent_normalized = Exponent_add_reg;
  end
end



//***********************Result***********************
assign Result_comb = (mult_select)?((&Exponent_normalized)? {sign_reg,31'h7f800000} :
    {sign_reg,Exponent_normalized,Fraction_normalized[22:0]}) : 32'b0;


//***********************Data Valid***********************
localparam idle_s = 1'b0,
           after_valid_s = 1'b1;
reg cs,ns;
always@(posedge clk or negedge rstn)begin
  if(!rstn)
    cs<=idle_s;
  else
    cs<=ns;
  end

// Valid is high for one cycle
always@(*)begin
  valid= 0;
  case (cs)
  idle_s        : if(mult_select)
                    ns= after_valid_s;
                  else
                    ns = idle_s;

  after_valid_s : begin
                    valid= 1;
                    ns= idle_s;
                  end
  default       : begin
                    valid= 0;
                    ns=idle_s;
                  end
  endcase
end

endmodule
