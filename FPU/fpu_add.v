module fpu_add #(parameter
  double = 0
)(
  a,
  b,
  result,
  exception
);
  localparam  size = (double == 0 ? 32 : 64);
  localparam exponent = (double == 0 ? 8: 11);
  localparam mantissa = (double == 0 ? 23 : 52);
  input exception;

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

  assign frac_a = ((exp_a == 0) && (frac_a == 0)) ? {1'b0, a[size-2-exponent:0]} : {1'b1, a[size-2-exponent:0]};
  assign frac_b = ((exp_b == 0) && (frac_b == 0)) ? {1'b0, b[size-2-exponent:0]} : {1'b1, b[size-2-exponent:0]};

  reg [exponent - 1:0] exp_diff;
  reg [mantissa + 1: 0] aligned_frac_a;
  reg [mantissa + 1 : 0] aligned_frac_b;

  wire exp_a_gt_exp_b;
  assign exp_a_gt_exp_b = (exp_a > exp_b);

  reg [mantissa + 1: 0] diff_mantissa;
  reg new_sign_bit;
  reg [exponent - 1:0] new_exp;
  reg found;

  always @(*) begin
      exp_diff = (exp_a_gt_exp_b) ? (exp_a - exp_b) : (exp_b - exp_a);
      aligned_frac_a = (exp_a_gt_exp_b) ? {1'b0, frac_a} : ({1'b0, frac_a} >> exp_diff);
      aligned_frac_b = (exp_a_gt_exp_b) ? ({1'b0, frac_b} >> exp_diff) : {1'b0, frac_b};
      if (sign_a == sign_b) begin
        diff_mantissa = aligned_frac_a + aligned_frac_b;
        new_sign_bit = (sign_a == 0) ? 0: 1;
        new_exp = (exp_a_gt_exp_b) ? exp_a : exp_b;
      end else begin
            diff_mantissa = (aligned_frac_a > aligned_frac_b) ? (aligned_frac_a - aligned_frac_b) :  (aligned_frac_b - aligned_frac_a);
            new_sign_bit = (((aligned_frac_a > aligned_frac_b ) & sign_a) | ((aligned_frac_b > aligned_frac_a ) & sign_b)) ? 1 : 0;
            new_exp = (exp_a_gt_exp_b) ? exp_a : exp_b;
            if (diff_mantissa == 0) begin
              new_exp = 0;
            end
      end
      //Normalize after
      if (diff_mantissa) begin
        found = 0;
        if (diff_mantissa[mantissa+1]) begin
          diff_mantissa = diff_mantissa >> 1;
          new_exp = new_exp + 1;
        end else begin
          for (integer i = 0; i < mantissa; i = i + 1) begin
            if (~found) begin
              if (diff_mantissa[mantissa]) begin
                found = 1;
              end else begin
                diff_mantissa = diff_mantissa << 1;
                new_exp = new_exp - 1;
              end
            end
          end
        end
      end

  end

  assign result = {new_sign_bit, new_exp, diff_mantissa[mantissa-1:0]};

endmodule
