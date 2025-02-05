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
  wire [mantissa-1:0] frac_a;

  wire sign_b;
  wire [exponent-1:0] exp_b;
  wire [mantissa-1:0] frab_b;

  assign sign_a = a[size-1];
  assign sign_b = b[size-1];
  assign exp_a = a[size-2:size-2-exponent + 1];
  assign exp_b = a[size-2:size-2-exponent + 1];
  assign frac_a = a[size-2-exponent:0];
  assign frac_b = a[size-2-exponent:0];

  assign result = frac_a;
endmodule
