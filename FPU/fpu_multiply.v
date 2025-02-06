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
  input [size-1:0] a;
  input [size-1:0] b;

  output [size-1:0] result;

  



endmodule
