module fpu_multiply #(parameter
  double = 0
) (
  a,
  b,
  result
);
  localparam  size = (double == 0 ? 32 : 64);
  localparam exponent = (double == 0 ? 8: 11);
  localparam mantissa = (double == 0 ? 23 : 52);
  localparam bias = (double == 0 ? 127 : 1023);
  input [size-1:0] a;
  input [size-1:0] b;

  output [size-1:0] result;

  wire sign_a;
  wire [exponent-1:0] exp_a;
  wire [mantissa:0] frac_a;

  wire sign_b;
  wire [exponent-1:0] exp_b;
  wire [mantissa:0] frac_b;


  assign sign_a = a[size-1];
  assign sign_b = b[size-1];
  assign exp_a = a[size-2:size-2-exponent + 1];
  assign exp_b = b[size-2:size-2-exponent + 1];

  assign frac_a = ((exp_a == 0)) ? {1'b0, a[size-2-exponent:0]} : {1'b1, a[size-2-exponent:0]};
  assign frac_b = ((exp_b == 0)) ? {1'b0, b[size-2-exponent:0]} : {1'b1, b[size-2-exponent:0]};

  reg new_sign_bit;
  reg [exponent:0] new_exp;
  reg [(mantissa+1)*2-1:0] diff_mantissa;

  reg found;

  always @(*) begin
    new_sign_bit = sign_a ^ sign_b;
    new_exp = exp_a + exp_b;
    diff_mantissa = {{(mantissa+1){1'b0}}, frac_a} * {{(mantissa+1){1'b0}}, frac_b} ;

    //Start normalization
    if (diff_mantissa) begin
      new_exp = new_exp -bias + 1;
      found = 0;
      for (integer i = 0; i <=  (mantissa + 1)*2 - 1; i = i + 1) begin
        if (~found) begin
          if (diff_mantissa[(mantissa + 1)*2 - 1]) begin
              found = 1;
          end else begin
            diff_mantissa = diff_mantissa << 1;
            new_exp = new_exp - 1;
          end
        end
      end
    end else begin
      new_exp = 0;
    end
  end

  assign result = {new_sign_bit, new_exp[exponent-1:0], diff_mantissa[(mantissa+1)*2-2:mantissa+1]};

endmodule
