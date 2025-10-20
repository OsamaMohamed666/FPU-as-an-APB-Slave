module Normalize_add
//normalization phase
  (
  input             normalize_enable,
  input      [25:0] Alu_result,
  input      [7:0]  higher_Exponent,

  output reg [7:0]  Exponent_normalized,
  output reg [23:0] Fraction_normalized
  );

reg [5:0] count;
reg [4:0] shift_value;
reg [25:0] alu_shifted_result;

always @ (*)begin
  alu_shifted_result = 0;
  shift_value = 0;
  if(normalize_enable==1'b1)begin
    count=0;
    if (!(|Alu_result)) begin
      Exponent_normalized= 0;
      Fraction_normalized=0;
    end

    else if(Alu_result[25]==1'b1)begin
      Exponent_normalized= higher_Exponent+1;
      Fraction_normalized= Alu_result[24:1];
    end
    else begin
      // Getting place of first bit "1" from MSB
      casex(Alu_result)
        26'b001xxxxxxxxxxxxxxxxxxxxxxx:count=23;
        26'b0001xxxxxxxxxxxxxxxxxxxxxx:count=22;
        26'b00001xxxxxxxxxxxxxxxxxxxxx:count=21;
        26'b000001xxxxxxxxxxxxxxxxxxxx:count=20;
        26'b0000001xxxxxxxxxxxxxxxxxxx:count=19;
        26'b00000001xxxxxxxxxxxxxxxxxx:count=18;
        26'b000000001xxxxxxxxxxxxxxxxx:count=17;
        26'b0000000001xxxxxxxxxxxxxxxx:count=16;
        26'b00000000001xxxxxxxxxxxxxxx:count=15;
        26'b000000000001xxxxxxxxxxxxxx:count=14;
        26'b0000000000001xxxxxxxxxxxxx:count=13;
        26'b00000000000001xxxxxxxxxxxx:count=12;
        26'b000000000000001xxxxxxxxxxx:count=11;
        26'b0000000000000001xxxxxxxxxx:count=10;
        26'b00000000000000001xxxxxxxxx:count=9;
        26'b000000000000000001xxxxxxxx:count=8;
        26'b0000000000000000001xxxxxxx:count=7;
        26'b00000000000000000001xxxxxx:count=6;
        26'b000000000000000000001xxxxx:count=5;
        26'b0000000000000000000001xxxx:count=4;
        26'b00000000000000000000001xxx:count=3;
        26'b000000000000000000000001xx:count=2;
        26'b0000000000000000000000001x:count=1;
        26'b00000000000000000000000001:count=0;
        default:count=0;
      endcase

      shift_value=24-count;
      alu_shifted_result = Alu_result<<(shift_value);
      // Normalized case
      if(higher_Exponent>shift_value) begin
        Exponent_normalized= higher_Exponent-(shift_value);
        Fraction_normalized=alu_shifted_result;
      end
      // Denormalized case
      else begin
        Exponent_normalized=0;
        Fraction_normalized=alu_shifted_result >> (shift_value - higher_Exponent + 1'b1);
      end
    end

  end
  else begin
    Fraction_normalized=Alu_result;
    if(&Fraction_normalized) //special case if Rounding to inf number so inf flag raised
      Exponent_normalized = higher_Exponent+1;
    else
      Exponent_normalized= higher_Exponent;
  end
end


endmodule

